# SmartZoom

SmartZoom is a secure, Zoom-integrated platform designed to enhance online meeting experiences by providing advanced analytics, summaries, and seamless workflows for teams and individuals.

---

## 🚀 Overview

SmartZoom connects directly with your Zoom account via OAuth, enabling you to log in securely and manage your meetings effortlessly.  
It processes your recorded meetings, transcribes the audio, and generates concise, readable summaries using state-of-the-art AI.

The platform is designed with security, usability, and scalability in mind — ideal for teams that care about both productivity and privacy.

---

## 🔷 Key Features

✨ **Secure Zoom Login**  
Log in to SmartZoom using your Zoom account credentials — no extra accounts or passwords to manage.

✨ **Meeting Recordings Management**  
Automatically detects and retrieves your Zoom meeting recordings securely from your designated folder.

✨ **Transcription & Summarization**  
Uses cutting-edge AI models (Whisper & GPT) to transcribe and summarize meetings for easy review and sharing.

✨ **Organized History**  
Your meeting summaries and transcripts are stored securely in the cloud and are easily searchable.

✨ **Notifications**  
Get notified when your meeting summary is ready.

---

## 🔷 Technical Architecture

- **Frontend:** Flutter (macOS & Mobile-ready)
- **Backend:** FastAPI
- **Storage:** Firebase Firestore
- **Authentication:** Zoom OAuth
- **Hosting:** AWS (with HTTPS & secure configuration)

---

## 🔷 Security & Compliance

✅ All data is encrypted in transit (HTTPS) and at rest.  
✅ OAuth ensures secure authentication without storing user credentials.  
✅ Meeting data and summaries are stored only within company-controlled Firebase and are never shared with third parties.  
✅ Development follows a secure SDLC, including internal code reviews and regular security tests.

---

## 🛠️ Development & Deployment

- Source code managed on GitHub
- Developed and maintained using VSCode
- Regular internal reviews to ensure code quality and security
- CI/CD pipeline and optional security scanning (SAST/DAST)

---

## 📋 Roadmap

- [x] OAuth-based login
- [x] Meeting transcription & summarization
- [x] Secure storage & retrieval
- [ ] User-customizable summary prompts
- [ ] Team-level collaboration features

---

## 👤 Author & Contact

Developed and maintained by the SmartZoom Team.  
For questions, support, or feedback:  
📧 **support@smartzoom.net**  
🌐 [https://smartzoom.net](https://smartzoom.net)

---

## 📄 License

© SmartZoom — All rights reserved.
