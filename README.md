# Memoriz 📖 — Faith through Flutter

**Memoriz** is a premium, open-source scripture engagement and memorization application built with Flutter. It's designed for those who want to go beyond casual reading and move towards deep, consistent retention of the Word using modern technology.

> *"Thy word have I hid in mine heart, that I might not sin against thee."* — **Psalm 119:11**

---

## 🛡️ The Mission (Free & Non-Profit)
Memoriz is a labor of love. It is **100% free** and intended to be a resource for the global Christian community. 
**Crucial Note:** This application is not for profit. It should not be sold, monetized, or used for any commercial gain whatsoever. It is a gift from the community, to the community.

---

## ✨ Key Features

*   **Spaced Repetition Engine:** Intelligent study sessions that prioritize verses based on your recall history (Struggling, Almost There, Got It).
*   **Interactive Recitation:** Type out verses word-for-word. The app provides instant visual feedback, comparing your typing against the scripture.
*   **Premium Verse Sharing:** Turn your daily devotion into a work of art. Capture beautiful, high-resolution scripture cards with custom backgrounds for social sharing.
*   **Continuous Meditation:** Customizable recurring notifications (every 3 hours) to keep your mind set on things above throughout the day.
*   **True Bible Persistence:** Pick up exactly where you left off. The app remembers your translation, book, chapter, and even the exact verse you were reading—even after a restart.
*   **Deep-Link Notifications:** Tap a "Daily Bread" notification to jump straight into a beautiful, immersive modal of the scripture.
*   **Reliable Alarms:** Uses native Android/iOS background services to ensure your daily study reminders always fire.

---

## 🛠️ Technical Stack

*   **Framework:** [Flutter](https://flutter.dev/) 
*   **State Management:** [Riverpod](https://riverpod.dev/) (Robust, predictable state)
*   **Local Persistence:** [sqflite](https://pub.dev/packages/sqflite) + [Shared Preferences]
*   **Theming:** Glassmorphic UI with dynamic gradients and custom `GoogleFonts`.
*   **Images:** Dynamic background generation and RepaintBoundary for high-quality sharing.

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (Latest stable)
*   Android Studio / Xcode

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/SahrDauda/Memoriz.git
    cd memoriz
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```

---

## 🏗️ Architecture Overview

Memoriz follows a clean, provider-based architecture:
*   **`lib/providers`**: Business logic and state (Bible, Settings, Navigation).
*   **`lib/services`**: OS-level integrations (Notifications, Alarms, TTS).
*   **`lib/data`**: SQLite repository pattern and seed data.
*   **`lib/screens`**: UI components focusing on premium UX and performance.

---

## 🤝 Contributing & Feedback

This is a **"Building in Public"** project. We are constantly improving!
*   If you're a developer, pull requests are welcome (especially for new translations or cloud backup).
*   If you're a user, tell us how it's helping you and what features you'd like to see next!

---

## 👨‍💻 Author

**Emmanuel (Sahr) Dauda**
*   [LinkedIn](https://www.linkedin.com/in/emmanuel-dauda/)
*   Mission: Solving business (and spiritual) problems with clean, production-grade tech.

---

## ⚖️ License
This project is open-source and available under the MIT License.
