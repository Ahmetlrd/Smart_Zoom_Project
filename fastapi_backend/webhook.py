from fastapi import FastAPI, Request, APIRouter
from fastapi.responses import JSONResponse
import json
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

# 🧠 Zoom Webhook endpoint
async def zoom_webhook(request: Request):
    data = await request.json()

    # ✅ Challenge doğrulama (Zoom ilk doğrulamada gönderiyor)
    if "plainToken" in data:
        return {"plainToken": data["plainToken"]}

    # 📩 Zoom eventi alındı
    event = data.get("event")
    print(f"\n📩 Zoom Event Received: {event}")
    print("📦 Full Payload:")
    print(json.dumps(data, indent=2))

    participant_email = (
        data.get("payload", {}).get("object", {}).get("participant", {}).get("email")
        or data.get("payload", {}).get("object", {}).get("email")
    )

    if not participant_email:
        print("⛔ Katılımcı e-postası bulunamadı.")
        return JSONResponse(content={"error": "No email found"}, status_code=400)

    if event in ["meeting.started", "meeting.participant_joined"]:
        meeting_id = data["payload"]["object"]["id"]
        print(f"🚀 Event matched: {event} → meeting_id: {meeting_id}, email: {participant_email}")

        # 🔍 Firestore'dan FCM token çek
        doc_id = participant_email.replace("@", "_").replace(".", "_")
        user_ref = db.collection("users").document(doc_id)
        doc = user_ref.get()

        if not doc.exists:
            print(f"⛔ Firestore'da kullanıcı bulunamadı: {doc_id}")
            return JSONResponse(content={"error": "User not found"}, status_code=404)

        user_data = doc.to_dict()
        fcm_token = user_data.get("fcmToken")

        if not fcm_token:
            print(f"⛔ FCM token yok: {participant_email}")
            return JSONResponse(content={"error": "FCM token not found"}, status_code=400)

        # 🔔 Bildirimi gönder
        send_fcm(
            token=fcm_token,
            title="Zoom Toplantısı Başladı",
            body="Toplantıya katıldınız, özet çıkarmak ister misiniz?",
            data={"action": "start_summary", "meeting_id": str(meeting_id)}
        )

    return {"status": "ok"}

# 📲 Flutter'dan gelen token'ı Firestore'a kaydeder
async def save_token(request: Request):
    body = await request.json()
    email = body.get("email")
    token = body.get("token")

    if email and token:
        doc_id = email.replace("@", "_").replace(".", "_")
        user_ref = db.collection("users").document(doc_id)
        try:
            await user_ref.set({
                "fcmToken": token,
                "fcmUpdatedAt": firestore.SERVER_TIMESTAMP
            }, merge=True)
            print(f"✅ FCM token kaydedildi: {email}")
            return {"status": "saved"}
        except Exception as e:
            print(f"⛔ Firestore yazma hatası: {e}")
            return JSONResponse(content={"error": "write_failed"}, status_code=500)
    else:
        return JSONResponse(content={"error": "invalid_input"}, status_code=400)

# 🔗 Endpoint'leri bağla
router.add_api_route("/zoom/webhook", zoom_webhook, methods=["POST"])
router.add_api_route("/save-token", save_token, methods=["POST"])
app.include_router(router)
