from fastapi import FastAPI, Request, APIRouter
from fastapi.responses import JSONResponse
import json
import threading
import firebase_admin
from firebase_admin import credentials, messaging, firestore

# 🔐 Firebase Admin başlat
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

app = FastAPI()
router = APIRouter()

# 🔗 Firestore bağlantısı
db = firestore.client()

# 🔔 Bildirim gönderme fonksiyonu


def send_fcm(token: str, title: str, body: str, data: dict = {}):
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data=data,
        token=token
    )
    try:
        response = messaging.send(message)
        print(f"🔥 FCM gönderildi: {response}")
    except Exception as e:
        print(f"⛔ FCM gönderimi başarısız: {e}")

# 👤 Katılımcı event’ini arka planda işleyen fonksiyon


def handle_participant_joined(email: str, meeting_id: str):
    try:
        doc_id = email.replace("@", "_").replace(".", "_")
        user_ref = db.collection("users").document(doc_id)
        doc = user_ref.get()

        if not doc.exists:
            print(f"⛔ User not found in Firestore: {email} (doc_id: {doc_id})")
            return

        user_data = doc.to_dict()
        print(f"📥 Firestore user data for {email}: {user_data}")

        fcm_token = user_data.get("fcmToken")
        if not fcm_token:
            print(f"⛔ FCM token missing in Firestore document: {email}")
            return

        send_fcm(
            token=fcm_token,
            title="Zoom Toplantısı Başladı",
            body="Toplantıya katıldınız, özet çıkarmak ister misiniz?",
            data={"action": "start_summary", "meeting_id": str(meeting_id)}
        )
    except Exception as e:
        print(f"⛔ Exception in background handler for {email}: {e}")


# 🧠 Zoom Webhook endpoint
@router.post("/zoom/webhook")
async def zoom_webhook(request: Request):
    try:
        data = await request.json()

        # ✅ Challenge doğrulama (Zoom ilk bağlantıda test gönderir)
        if "plainToken" in data:
            return {"plainToken": data["plainToken"]}

        event = data.get("event")
        payload = data.get("payload", {}).get("object", {})
        meeting_id = payload.get("id")

        print(f"\n📩 Zoom Event Received: {event}")
        print(json.dumps(data, indent=2))

        # 🚀 meeting.started
        if event == "meeting.started":
            print(f"✅ Meeting started → ID: {meeting_id}")
            return {"status": "meeting_started_logged"}

        # 🛑 meeting.ended
        elif event == "meeting.ended":
            print(f"✅ Meeting ended → ID: {meeting_id}")
            return {"status": "meeting_ended_logged"}

        # 👤 participant_joined
        elif event == "meeting.participant_joined":
            email = (
                payload.get("participant", {}).get("email")
                or payload.get("email")
            )
            if not email:
                return JSONResponse(content={"error": "email missing"}, status_code=400)

            print(f"👤 Participant joined: {email} in meeting {meeting_id}")

            # 🔁 Arka planda işleyici başlat
            threading.Thread(
                target=handle_participant_joined,
                args=(email, meeting_id)
            ).start()

            return {"status": "participant_background_started"}

        # 👋 participant_left
        elif event == "meeting.participant_left":
            email = (
                payload.get("participant", {}).get("email")
                or payload.get("email")
            )
            print(
                f"👋 Participant left: {email or 'bilinmiyor'} in meeting {meeting_id}")
            return {"status": "participant_left_logged"}

        # 🔍 Diğer event’ler
        return {"status": "unhandled_event"}

    except Exception as e:
        print(f"⛔ Genel webhook hata: {e}")
        return JSONResponse(content={"error": str(e)}, status_code=500)

# 📲 Flutter'dan gelen token'ı Firestore'a kaydeder


@router.post("/save-token")
async def save_token(request: Request):
    body = await request.json()
    email = body.get("email")
    token = body.get("token")

    if not (email and token):
        return JSONResponse(content={"error": "invalid input"}, status_code=400)

    doc_id = email.replace("@", "_").replace(".", "_")
    user_ref = db.collection("users").document(doc_id)

    try:
        user_ref.set({
            "fcmToken": token,
            "fcmUpdatedAt": firestore.SERVER_TIMESTAMP
        }, merge=True)
        print(f"✅ FCM token kaydedildi: {email}")
        return {"status": "saved"}
    except Exception as e:
        print(f"⛔ Firestore yazma hatası: {e}")
        return JSONResponse(content={"error": "write_failed"}, status_code=500)

# 🔗 Endpoint'leri bağla
app.include_router(router)
