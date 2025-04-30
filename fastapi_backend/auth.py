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

# Temporarily store refresh_token (should be stored securely in production)
REFRESH_TOKEN = None

# Redirect user to Zoom's authorization page


@router.get("/auth/login")
def login():
    # Construct the Zoom OAuth URL and redirect the user to Zoom's login screen
    zoom_auth_url = (
        f"https://zoom.us/oauth/authorize?response_type=code"
        f"&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}"
    )
    return RedirectResponse(zoom_auth_url)

# Callback endpoint Zoom redirects to after user authorization


@router.get("/auth/callback")
async def callback(request: Request):
    global REFRESH_TOKEN

    # Extract the authorization code returned by Zoom
    code = request.query_params.get("code")
    if not code:
        return JSONResponse(content={"error": "No code received"}, status_code=400)

    # Exchange the authorization code for access and refresh tokens
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
        REFRESH_TOKEN = token_data.get(
            "refresh_token")  # Save the refresh token

        # Use the access token to fetch the user's information from Zoom
        user_response = await client.get(
            "https://api.zoom.us/v2/users/me",
            headers={"Authorization": f"Bearer {access_token}"},
        )
        user_info = user_response.json()

        # Create and return a short-lived JWT containing basic user info
        jwt_token = jwt.encode({
            "email": user_info.get("email"),
            "name": user_info.get("first_name", "") + " " + user_info.get("last_name", "")
        }, JWT_SECRET, algorithm=JWT_ALGORITHM)

    # Redirect the user back to the Flutter app with the JWT as a URL parameter
    return RedirectResponse(
        url=f"zoomai://auth-callback?token={jwt_token}&refresh_token={REFRESH_TOKEN}"
    )


# Endpoint to refresh access token using the saved refresh token
@router.get("/auth/refresh")
async def refresh_token():
    global REFRESH_TOKEN

    # If we don't have a refresh token yet, return an error
    if REFRESH_TOKEN is None:
        return JSONResponse(content={"error": "No refresh token available"}, status_code=400)

    # Use the refresh token to request a new access token
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
        # Update the stored refresh token
        REFRESH_TOKEN = new_data.get("refresh_token")

        # Return the new access token to the client
        return {"access_token": new_data.get("access_token")}
