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
JWT_SECRET = "zoom-secret"  # bu gizli bir string, değiştirebilirsin
JWT_ALGORITHM = "HS256"

# 1. Login → Zoom yetkilendirme sayfasına yönlendir
@router.get("/auth/login")
def login():
    zoom_oauth_url = (
        f"https://zoom.us/oauth/authorize"
        f"?response_type=code"
        f"&client_id={CLIENT_ID}"
        f"&redirect_uri={REDIRECT_URI}"
    )
    return RedirectResponse(zoom_oauth_url)

# 2. Callback → Zoom'dan gelen code ile access token al
@router.get("/auth/callback")
async def callback(request: Request):
    code = request.query_params.get("code")

    async with httpx.AsyncClient() as client:
        # Access token alma
        token_response = await client.post(
            "https://zoom.us/oauth/token",
            params={
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": REDIRECT_URI
            },
            auth=(CLIENT_ID, CLIENT_SECRET),
        )

        token_data = token_response.json()
        access_token = token_data.get("access_token")

        # Kullanıcı bilgisi çekme
        user_response = await client.get(
            "https://api.zoom.us/v2/users/me",
            headers={"Authorization": f"Bearer {access_token}"},
        )
        user_info = user_response.json()

    # JWT token oluşturma (kullanıcı bilgisiyle)
    payload = {
        "email": user_info["email"],
        "name": user_info["first_name"] + " " + user_info["last_name"],
    }

    jwt_token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

    # JSON ile Flutter'a gönder (test için tarayıcıda da görebilirsin)
    return JSONResponse(content={"token": jwt_token})
