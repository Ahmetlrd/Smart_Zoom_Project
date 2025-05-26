from fastapi import FastAPI, Request, APIRouter
from fastapi.responses import JSONResponse
import json
import firebase_admin
from firebase_admin import credentials, messaging

# 🔐 Firebase hizmet hesabı JSON'unu yükle
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# FastAPI app (opsiyonel ama local test için kullanılabilir)
app = FastAPI()

# 🔐 Bu kullanıcı e-posta’sı eşleşiyorsa bildirim gönderilecek
AUTHORIZED_EMAIL = "ahmet.cavusoglu@sabanciuniv.edu"

# 📲 Bildirim gönderme fonksiyonu
def send_fcm(token: str, title: str, body: str, data: dict = {}):
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data=data,
        token=token
    )
    response = messaging.send(message)
    print(f"🔥 FCM sent to {token} → {response}")

# 🧪 Test için sabit FCM token (gerçekte Firestore’dan alınmalı)
TEST_USER_TOKEN = "YOUR_FCM_DEVICE_TOKEN_HERE"

# ✅ Webhook endpoint
async def zoom_webhook(request: Request):
    data = await request.json()

    # ✅ Zoom webhook doğrulaması (Challenge)
    if "plainToken" in data:
        return {"plainToken": data["plainToken"]}

    # 🔍 Event türü al
    event = data.get("event")
    print(f"\n📩 Zoom Event Received: {event}")
    print("📦 Full Payload:")
    print(json.dumps(data, indent=2))

    # 📧 Kullanıcı email’i kontrol et
    participant_email = (
        data.get("payload", {}).get("object", {}).get("participant", {}).get("email")
        or data.get("payload", {}).get("object", {}).get("email")
    )

    if participant_email and participant_email != AUTHORIZED_EMAIL:
        print(f"⛔ Event not from our user: {participant_email} → ignoring.")
        return JSONResponse(content={"status": "ignored"})

    if event in ["meeting.started", "meeting.participant_joined"]:
        meeting_id = data["payload"]["object"]["id"]
        print(f"🚀 Event matched: {event} → meeting_id: {meeting_id}")

        # 🔔 Kullanıcıya bildirim gönder
        send_fcm(
            token=TEST_USER_TOKEN,
            title="Zoom Toplantısı Başladı",
            body="Toplantıya girdiniz gibi görünüyor, özet çıkarmak ister misiniz? Tıklayın.",
            data={"action": "start_summary", "meeting_id": str(meeting_id)}
        )

    return {"status": "ok"}

# ✅ APIRouter ile dışa aktar
router = APIRouter()
router.add_api_route("/zoom/webhook", zoom_webhook, methods=["POST"])
