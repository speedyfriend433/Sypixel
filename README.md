# Sypixel 

<p align="center"><img src="https://github.com/user-attachments/assets/66740af9-4fe7-4f6f-9107-16796167cab1" width="150"></p>

**View Hypixel stats on the go with Sypixel, a native iOS app built with SwiftUI!**

Sypixel allows you to quickly search for Hypixel players and view their general statistics, game-specific stats, online status, and more, all presented with a familiar Minecraft-inspired theme.

---

## 🌟 Features

*   **Player Search:** Find any Hypixel player by their username or UUID.
*   **Detailed Player Profiles:**
    *   View rank, network level, karma, achievement points.
    *   See first and last login/logout times.
    *   Check current online status, including the game and mode they are playing.
    *   (Planned/Implemented) View social media links.
*   **Game Statistics:**
    *   Currently supports stats for:
        *   Bed Wars
        *   SkyWars
        *   Murder Mystery
        *   Duels
    *   (More games to be added!)
*   **Minecraft-Inspired UI:** A custom theme designed to feel familiar to Hypixel players.
*   **API Key Management:** Securely save your Hypixel API key within the app.
*   **Built with SwiftUI:** Modern, declarative UI for a smooth iOS experience.
*   (Planned) Recent Games Viewer
*   (Planned) Guild Information
*   (Planned) Resource Viewer (Game types, achievements etc.)

---

## 📸 Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/92d7e3c5-93a8-40e1-8cda-dfca856cd608" width="200" alt="Player Search Screen">
       
  <img src="https://github.com/user-attachments/assets/d5814fd8-4994-43cf-995f-161dd7498152" width="200" alt="Player Detail Screen">
</p>

---

## 🛠️ Built With

*   **SwiftUI:** For the user interface and app structure.
*   **Swift:** The programming language used.
*   **Hypixel Public API:** For fetching all player and game data.
*   **Mojang API:** For converting usernames to UUIDs.

---

## 🚀 Getting Started

### Prerequisites

*   Xcode 14.0 or later
*   iOS 16.0 or later (adjust if your deployment target is different)
*   A Hypixel API Key (get one by typing `/api new` in the Hypixel server chat in Minecraft)

### Installation & Running

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/speedyfriend433/Sypixel.git
    cd Sypixel
    ```
2.  **Open the project in Xcode:**
    Open `Sypixel.xcodeproj`.
3.  **Configure API Key:**
    *   Run the app on a simulator or a physical device.
    *   Navigate to the "Settings" tab within the Sypixel app.
    *   Enter your Hypixel API key and tap "Save API Key".
4.  **Build and Run:**
    Select your target device/simulator and click the Run button (or `Cmd+R`).

---

## 📋 Project Structure (Brief Overview)

*   `SypixelApp.swift`: Main app entry point.
*   `MainTabView.swift`: Root view containing the TabBar.
*   **Core/**
    *   `Models/`: `Codable` structs for API responses (e.g., `Player.swift`, `PlayerStatus.swift`).
    *   `Networking/`: `HypixelAPIService.swift` for handling API calls.
    *   `Styling/`: `AppColors.swift`, `AppFonts.swift` for UI theming.
    *   `Utilities/`: Helper classes like `APIKeyManager.swift`.
*   **Features/**
    *   `PlayerSearch/`: UI and ViewModel for player searching.
    *   `PlayerDetail/`: UI and ViewModel for displaying player details.
    *   `Settings/`: UI for API key management.
*   `Assets.xcassets`: App icons, custom colors.

---

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute, please feel free to fork the repository, make your changes, and submit a pull request.

If you find any bugs or have feature requests, please open an issue on GitHub.

Some areas for future development:
*   Displaying player avatars/heads.
*   Showing recent games.
*   Guild search and information.
*   Displaying more detailed stats for all game modes.
*   Caching API responses for resources (games, achievements).
*   UI/UX enhancements and further theming.

---

## 🧑‍💻 Author

*   **speedyfriend67**
*   Email: <speedyfriend433@gmail.com>
*   GitHub: [speedyfriend67](https://github.com/speedyfriend433)

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

```text
MIT License

Copyright (c) 2023 speedyfriend67

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgements

The Hypixel Network for their fantastic server and public API.

Mojang Studios for the Minecraft username-to-UUID API.

The SwiftUI community for continuous learning and inspiration.
