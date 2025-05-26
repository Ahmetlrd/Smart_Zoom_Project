from fastapi import FastAPI, Request, APIRouter
from fastapi.responses import JSONResponse
import json
import firebase_admin
from firebase_admin import credentials, messaging

# 🔐 Firebase hizmet hesabı JSON'unu yükle
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

app = FastAPI()

# In-memory token database
token_db = {}

# 🔐 Bu kullanıcı e-posta’sı eşleşiyorsa bildirim gönderilecek
AUTHORIZED_EMAIL = "ahmet.cavusoglu@sabanciuniv.edu"

# 📲 Bildirim gönderme fonksiyonu
def send_fcm(token: str, title: str, body: str, data: dict = {}):
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data=data,
        token=token
    )
    try:
        response = messaging.send(message)
        print(f"🔥 FCM sent to {token} → {response}")
    except Exception as e:
        print(f"⛔ FCM gönderimi başarısız: {e}")

# 🔁 Zoom webhook endpoint
async def zoom_webhook(request: Request):
    data = await request.json()

    # ✅ Zoom challenge doğrulaması
    if "plainToken" in data:
        return {"plainToken": data["plainToken"]}

    # 🎯 Event türü ve e-posta
    event = data.get("event")
    print(f"\n📩 Zoom Event Received: {event}")
    print("📦 Full Payload:")
    print(json.dumps(data, indent=2))

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

        # 🔍 Token al
        token = token_db.get(participant_email)
        if not token:
            print(f"⛔ Token bulunamadı: {participant_email}")
            return JSONResponse(content={"status": "no_token"}, status_code=400)

        # 🔔 Bildirim gönder
        send_fcm(
            token=token,
            title="Zoom Toplantısı Başladı",
            body="Toplantıya girdiniz gibi görünüyor, özet çıkarmak ister misiniz?",
            data={"action": "start_summary", "meeting_id": str(meeting_id)}
        )

    return {"status": "ok"}

# 🔐 Flutter'dan token kaydı için endpoint
async def save_token(request: Request):
    body = await request.json()
    email = body.get("email")
    token = body.get("token")

    if email and token:
        token_db[email] = token
        print(f"✅ Token kaydedildi → {email} = {token}")
        return {"status": "saved"}
    else:
        return JSONResponse(content={"error": "Invalid input"}, status_code=400)

# Router tanımı
router = APIRouter()
router.add_api_route("/zoom/webhook", zoom_webhook, methods=["POST"])
router.add_api_route("/save-token", save_token, methods=["POST"])
