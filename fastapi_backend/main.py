# FastAPI uygulamasını başlatıyoruz
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from webhook import router as webhook_router


# auth işlemlerini ayrı dosyada yaptım, oradan router'ı buraya alıyorum
from auth import router as auth_router

# Uygulama objesini oluşturuyorum
app = FastAPI()
app.include_router(webhook_router)

# auth ile ilgili endpointleri uygulamaya dahil ediyorum
app.include_router(auth_router)
@app.get("/", response_class=HTMLResponse)
async def homepage():
    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>SmartZoom AI Summary</title>
        <link rel="icon" type="image/png" href="favicon.png">
        <style>
            body {
                margin: 0;
                font-family: 'Poppins', sans-serif;
                height: 100vh;
                background: linear-gradient(135deg, #1976d2, #64b5f6);
                overflow: hidden;
                display: flex;
                justify-content: center;
                align-items: center;
                color: white;
                text-align: center;
            }

            h1 {
                font-size: 3rem;
                margin-bottom: 20px;
                animation: fadeSlideIn 1s ease-out forwards;
            }

            p {
                font-size: 1.5rem;
                opacity: 0.8;
                animation: fadeSlideIn 1.5s ease-out forwards;
            }

            @keyframes fadeSlideIn {
                from { opacity: 0; transform: translateY(50px); }
                to { opacity: 1; transform: translateY(0); }
            }

            .particle {
                position: absolute;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.3);
                animation: float 10s infinite linear;
                pointer-events: none;
            }

            @keyframes float {
                0% { transform: translateY(0) translateX(0); opacity: 0.6; }
                50% { opacity: 0.3; }
                100% { transform: translateY(-200px) translateX(50px); opacity: 0; }
            }
        </style>
    </head>
    <body>
        <div>
            <h1>AI-Powered Meeting Summaries</h1>
            <p>Turn hours of meetings into actionable insights in seconds</p>
        </div>

        <script>
            function createParticle() {
                const particle = document.createElement('div');
                particle.classList.add('particle');
                const size = Math.random() * 10 + 5;
                particle.style.width = size + 'px';
                particle.style.height = size + 'px';
                particle.style.left = Math.random() * 100 + 'vw';
                particle.style.top = Math.random() * 100 + 'vh';
                particle.style.animationDuration = (Math.random() * 10 + 5) + 's';
                document.body.appendChild(particle);

                setTimeout(() => {
                    particle.remove();
                }, 15000);
            }

            setInterval(createParticle, 300);
        </script>
    </body>
    </html>
    """