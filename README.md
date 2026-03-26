# Memoriz 📖

**Memoriz** is a premium, open-source scripture engagement and memorization application built with Flutter. It's designed for those who want to go beyond casual reading and move towards deep, consistent retention of the Word.

> *"This is eternal life, that they may know you, and your son Jesus Christ, whom you have sent."* — **John 17:3**

---

## ✨ Key Features

*   **Interactive Typing Recitation:** Challenges the mind by requiring users to type out verses rather than just oral recitation.
*   **Side-by-Side Comparison:** Instant visual auditing that compares your typed input against the original scripture to highlight differences.
*   **Spaced Repetition Engine:** Intelligent study sessions that prioritize verses based on your recall history (Struggling, Almost There, Got It).
*   **Persistent Interval Notifications:** Customizable 3-hour recurring alerts that deliver 3 random scriptures for constant meditation.
*   **Reliable Background Alarms:** Rock-solid alarm delivery using Android's native services for consistent daily reminders.
*   **Custom Audio Support:** Personalize your study alarms with your own devotional audio or music.

---

## 🛠️ Technical Stack

*   **Framework:** [Flutter](https://flutter.dev/) (Cross-platform Mobile)
*   **State Management:** [Riverpod](https://riverpod.dev/) (Predictable & testable state)
*   **Local Persistence:** [sqflite](https://pub.dev/packages/sqflite) (SQLite for efficient scripture indexing)
*   **Architecture:** Clean Architecture principles with a focus on long-term maintainability.
*   **UI/UX:** Modern, premium aesthetic with dynamic gradients and micro-animations.

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (v3.10.8 or higher)
*   Android Studio / Xcode

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/[your-username]/memoriz.git
    cd memoriz
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    # For Android
    flutter run
    ```

---

## 🏗️ Architecture Overview

Memoriz follows a modular approach:
*   **`lib/providers`**: Handles all business logic and state transitions using Riverpod.
*   **`lib/domain/engine`**: Houses the Spaced Repetition logic.
*   **`lib/services`**: Manages OS-level integrations (Notifications, Alarms, Permissions).
*   **`lib/data`**: Repository pattern for local SQLite data management.

---

## 🤝 Contributing

This is a "Building in Public" project! I welcome feedback, bug reports, and pull requests.
*   Check out the [Issues](https://github.com/[your-username]/memoriz/issues) page for any known bugs or planned features.
*   Feel free to fork the repo and submit a PR for new features (e.g., more translations, cloud sync, etc.).

---

## 👨‍💻 Author

**Emmanuel (Sahr) Dauda**
*   [LinkedIn](https://www.linkedin.com/in/emmanuel-dauda/)
*   Mission: Solving business (and spiritual) problems with clean, production-grade tech.

---

## ⚖️ License
This project is open-source and available under the MIT License.
