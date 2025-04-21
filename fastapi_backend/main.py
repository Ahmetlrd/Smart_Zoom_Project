# FastAPI uygulamasını başlatıyoruz
from fastapi import FastAPI

# auth işlemlerini ayrı dosyada yaptım, oradan router'ı buraya alıyorum
from auth import router as auth_router

# Uygulama objesini oluşturuyorum
app = FastAPI()

# auth ile ilgili endpointleri uygulamaya dahil ediyorum
app.include_router(auth_router)
