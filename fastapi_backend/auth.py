# auth.py
from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse, JSONResponse
import httpx
import os
from jose import jwt
from dotenv import load_dotenv

load_dotenv()

router = APIRouter()

CLIENT_ID = os.getenv("CLIENT_ID")  # Zoom OAuth client ID
CLIENT_SECRET = os.getenv("CLIENT_SECRET")  # Zoom OAuth client secret
REDIRECT_URI = os.getenv("REDIRECT_URI")  # Redirect URI defined in Zoom App
JWT_SECRET = "zoom-secret"  # Secret for encoding JWT tokens
JWT_ALGORITHM = "HS256"  # Algorithm for JWT encoding

# Temporarily store tokens (in-memory; should be stored securely in production)
ACCESS_TOKEN = None
REFRESH_TOKEN = None

# Redirect user to Zoom's authorization page
@router.get("/auth/login")
def login():
    zoom_auth_url = (
        f"https://zoom.us/oauth/authorize?response_type=code"
        f"&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}"
    )
    return RedirectResponse(zoom_auth_url)

# Callback endpoint Zoom redirects to after user authorization
@router.get("/auth/callback")
async def callback(request: Request):
    global ACCESS_TOKEN, REFRESH_TOKEN

    code = request.query_params.get("code")  # Extract authorization code from query
    if not code:
        return JSONResponse(content={"error": "No code received"}, status_code=400)

    # Exchange code for access and refresh tokens
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
        ACCESS_TOKEN = token_data.get("access_token")
        REFRESH_TOKEN = token_data.get("refresh_token")

        # Fetch user info using the access token
        user_response = await client.get(
            "https://api.zoom.us/v2/users/me",
            headers={"Authorization": f"Bearer {ACCESS_TOKEN}"},
        )
        user_info = user_response.json()

        # Create and return a JWT token with basic user info
        jwt_token = jwt.encode({
            "email": user_info.get("email"),
            "name": user_info.get("first_name", "") + " " + user_info.get("last_name", "")
        }, JWT_SECRET, algorithm=JWT_ALGORITHM)

    # Redirect back to mobile app with access and refresh tokens
    return RedirectResponse(url=f"zoomai://auth-callback?token={jwt_token}&access_token={ACCESS_TOKEN}&refresh_token={REFRESH_TOKEN}")

# Endpoint to refresh access token using the saved refresh token
@router.get("/auth/refresh")
async def refresh_token():
    global ACCESS_TOKEN, REFRESH_TOKEN

    if REFRESH_TOKEN is None:
        return JSONResponse(content={"error": "No refresh token available"}, status_code=400)

    async with httpx.AsyncClient() as client:
        refresh_response = await client.post(
            "https://zoom.us/oauth/token",
            auth=(CLIENT_ID, CLIENT_SECRET),
            data={
                "grant_type": "refresh_token",
                "refresh_token": REFRESH_TOKEN
            },
            headers={"Content-Type": "application/x-www-form-urlencoded"},
        )
        if refresh_response.status_code != 200:
            return JSONResponse(content={"error": "Failed to refresh token"}, status_code=500)

        new_data = refresh_response.json()
        ACCESS_TOKEN = new_data.get("access_token")
        REFRESH_TOKEN = new_data.get("refresh_token")  # Update refresh token if it changed

        return {
            "access_token": ACCESS_TOKEN,
            "refresh_token": REFRESH_TOKEN
        }
