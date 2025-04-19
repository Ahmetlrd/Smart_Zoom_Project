from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse, JSONResponse
import httpx
import os
from jose import jwt
from dotenv import load_dotenv

load_dotenv()
router = APIRouter()

CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
REDIRECT_URI = os.getenv("REDIRECT_URI")
JWT_SECRET = "zoom-secret"
JWT_ALGORITHM = "HS256"

@router.get("/auth/login")
def login():
    zoom_auth_url = (
        f"https://zoom.us/oauth/authorize?response_type=code"
        f"&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}"
    )
    return RedirectResponse(zoom_auth_url)

@router.get("/auth/callback")
async def callback(request: Request):
    code = request.query_params.get("code")
    if not code:
        return JSONResponse(content={"error": "No code received"}, status_code=400)

    async with httpx.AsyncClient() as client:
        token_response = await client.post(
            "https://zoom.us/oauth/token",
            auth=(CLIENT_ID, CLIENT_SECRET),
            data={
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": REDIRECT_URI
            },
            headers={"Content-Type": "application/x-www-form-urlencoded"},
        )
        token_data = token_response.json()
        access_token = token_data.get("access_token")

        user_response = await client.get(
            "https://api.zoom.us/v2/users/me",
            headers={"Authorization": f"Bearer {access_token}"},
        )
        user_info = user_response.json()

        jwt_token = jwt.encode({
            "email": user_info.get("email"),
            "name": user_info.get("first_name", "") + " " + user_info.get("last_name", "")
        }, JWT_SECRET, algorithm=JWT_ALGORITHM)

    # 👉 Flutter uygulamasına dön
    return RedirectResponse(url=f"zoomai://auth-callback?token={jwt_token}")
