# Giriş işlemleri için router oluşturuyorum
from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse, JSONResponse
import httpx
import os
from jose import jwt
from dotenv import load_dotenv

# .env dosyasını yüklüyorum, oradaki gizli bilgileri buradan çekeceğim
load_dotenv()

# router objesini oluşturuyorum, bunu main.py'de kullanacağım
router = APIRouter()

# .env dosyasından client bilgilerini alıyorum
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
REDIRECT_URI = os.getenv("REDIRECT_URI")

# JWT oluşturmak için secret key ve algoritma belirliyorum
JWT_SECRET = "zoom-secret"
JWT_ALGORITHM = "HS256"

# Kullanıcı login butonuna bastığında çalışacak endpoint
@router.get("/auth/login")
def login():
    # Zoom login ekranının URL'sini oluşturuyorum
    zoom_auth_url = (
        f"https://zoom.us/oauth/authorize?response_type=code"
        f"&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}"
    )
    # Kullanıcıyı Zoom'a yönlendiriyorum
    return RedirectResponse(zoom_auth_url)

# Zoom login'den sonra geri dönüş yapıldığında çalışan endpoint
@router.get("/auth/callback")
async def callback(request: Request):
    # Zoom bize bir code parametresi gönderiyor, onu alıyorum
    code = request.query_params.get("code")
    if not code:
        # code yoksa hata dönüyorum
        return JSONResponse(content={"error": "No code received"}, status_code=400)

    # Zoom'dan access token almak için API çağrısı yapıyorum
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
        # access_token'ı alıyorum
        token_data = token_response.json()
        access_token = token_data.get("access_token")

        # Kullanıcı bilgilerini almak için Zoom API'ye istek atıyorum
        user_response = await client.get(
            "https://api.zoom.us/v2/users/me",
            headers={"Authorization": f"Bearer {access_token}"},
        )
        user_info = user_response.json()

        # Kullanıcı bilgilerini JWT haline getiriyorum (frontend'e döneceğim)
        jwt_token = jwt.encode({
            "email": user_info.get("email"),
            "name": user_info.get("first_name", "") + " " + user_info.get("last_name", "")
        }, JWT_SECRET, algorithm=JWT_ALGORITHM)

    # Kullanıcı Flutter uygulamasına geri dönüyor, token'ı custom URL ile yolluyorum
    return RedirectResponse(url=f"zoomai://auth-callback?token={jwt_token}")
