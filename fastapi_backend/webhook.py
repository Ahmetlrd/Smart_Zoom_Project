from fastapi import FastAPI, Request, APIRouter
from fastapi.responses import JSONResponse
import json
import threading
import firebase_admin
from firebase_admin import credentials, messaging, firestore
from datetime import datetime

# Initialize Firebase Admin
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

app = FastAPI()
router = APIRouter()

# Firestore client
db = firestore.client()

def send_fcm(token: str, title: str, body: str, data: dict = {}):
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data=data,
        token=token
    )
    try:
        response = messaging.send(message)
        print(f"FCM sent: {response}")
    except Exception as e:
        print(f"FCM sending failed: {e}")

def handle_participant_joined(email: str, meeting_id: str):
    try:
        doc_id = email.replace("@", "_").replace(".", "_")
        user_ref = db.collection("users").document(doc_id)
        doc = user_ref.get()

        if not doc.exists:
            print(f"User not found in Firestore: {email} (doc_id: {doc_id})")
            return

        user_data = doc.to_dict()
        print(f"Firestore user data for {email}: {user_data}")

        platform = user_data.get("platform")
        fcm_token = user_data.get("fcmToken")

        # Update meeting status in Firestore
        user_ref.set({
            "meetingStatus": {
                "isJoined": True,
                "meetingId": str(meeting_id),
                "joinedAt": datetime.utcnow().isoformat()
            }
        }, merge=True)
        print(f"[Firestore] MeetingStatus: isJoined=True -> {email}")

        # Send FCM if token is available
        if fcm_token:
            send_fcm(
                token=fcm_token,
                title="Zoom Meeting Started",
                body="You have joined the meeting. Would you like to generate a summary?",
                data={"action": "start_summary", "meeting_id": str(meeting_id)}
            )
        else:
            print(f"Notification skipped: FCM token not available or platform is macOS ({platform})")

    except Exception as e:
        print(f"Exception in background handler for {email}: {e}")

def handle_participant_left(email: str, meeting_id: str):
    try:
        doc_id = email.replace("@", "_").replace(".", "_")
        user_ref = db.collection("users").document(doc_id)

        # Update meeting status in Firestore
        user_ref.set({
            "meetingStatus": {
                "isJoined": False,
                "meetingId": str(meeting_id)
            }
        }, merge=True)
        print(f"[Firestore] MeetingStatus: isJoined=False -> {email}")
    except Exception as e:
        print(f"Exception in background handler for {email}: {e}")

@router.post("/zoom/webhook")
async def zoom_webhook(request: Request):
    try:
        data = await request.json()
        if "plainToken" in data:
            return {"plainToken": data["plainToken"]}

        event = data.get("event")
        payload = data.get("payload", {}).get("object", {})
        meeting_id = payload.get("id")

        print(f"Zoom Event Received: {event}")
        print(json.dumps(data, indent=2))

        if event == "meeting.started":
            print(f"Meeting started -> ID: {meeting_id}")
            return {"status": "meeting_started_logged"}

        elif event == "meeting.ended":
            print(f"Meeting ended -> ID: {meeting_id}")
            return {"status": "meeting_ended_logged"}

        elif event == "meeting.participant_joined":
            email = (
                payload.get("participant", {}).get("email")
                or payload.get("email")
            )
            if not email:
                return JSONResponse(content={"error": "email missing"}, status_code=400)

            print(f"Participant joined: {email} in meeting {meeting_id}")

            threading.Thread(
                target=handle_participant_joined,
                args=(email, meeting_id)
            ).start()

            return {"status": "participant_background_started"}

        elif event == "meeting.participant_left":
            email = (
                payload.get("participant", {}).get("email")
                or payload.get("email")
            )
            print(
                f"Participant left: {email or 'unknown'} in meeting {meeting_id}")

            threading.Thread(
                target=handle_participant_left,
                args=(email, meeting_id)
            ).start()

            return {"status": "participant_left_background"}

        return {"status": "unhandled_event"}

    except Exception as e:
        print(f"General webhook error: {e}")
        return JSONResponse(content={"error": str(e)}, status_code=500)

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
        print(f"FCM token saved: {email}")
        return {"status": "saved"}
    except Exception as e:
        print(f"Firestore write error: {e}")
        return JSONResponse(content={"error": "write_failed"}, status_code=500)

app.include_router(router)

@router.post("/save-platform")
async def save_platform(request: Request):
    body = await request.json()
    email = body.get("email")
    platform = body.get("platform")

    if not (email and platform):
        return JSONResponse(content={"error": "invalid input"}, status_code=400)

    doc_id = email.replace("@", "_").replace(".", "_")
    user_ref = db.collection("users").document(doc_id)

    try:
        user_ref.set({
            "platform": platform,
            "platformUpdatedAt": firestore.SERVER_TIMESTAMP
        }, merge=True)
        print(f"Platform info saved: {email} -> {platform}")
        return {"status": "saved"}
    except Exception as e:
        print(f"Firestore write error (platform): {e}")
        return JSONResponse(content={"error": "write_failed"}, status_code=500)
