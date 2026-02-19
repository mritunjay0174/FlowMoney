# FlowMoney Flutter - Setup & Run Guide

## Prerequisites

### 1. Install Flutter SDK (Windows)
1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Download `flutter_windows_3.x.x-stable.zip`
3. Extract to `C:\flutter` (no spaces in path!)
4. Add `C:\flutter\bin` to your System PATH:
   - Search "Environment Variables" in Windows
   - Edit System Variables → Path → New → `C:\flutter\bin`
5. Open new terminal and run: `flutter doctor`

### 2. Install Android Studio (for Android)
1. Download: https://developer.android.com/studio
2. Install Android Studio
3. Open SDK Manager → Install Android SDK (API 34)
4. Create Virtual Device (emulator): Pixel 7 Pro, API 34
5. Run: `flutter doctor` → should show Android toolchain ✓

### 3. Install VS Code (recommended editor)
1. Download: https://code.visualstudio.com/
2. Install Flutter extension: `Ext: Flutter`
3. Install Dart extension: `Ext: Dart`

---

## Running the App

### Step 1 - Navigate to project
```bash
cd "FlowMoney_Flutter"
```

### Step 2 - Get packages
```bash
flutter pub get
```

### Step 3 - Start emulator
Open Android Studio → Device Manager → ▶ Start Pixel 7 emulator

### Step 4 - Run app
```bash
flutter run
```

Or press F5 in VS Code with the emulator running.

---

## Build APK (for physical Android device)

```bash
flutter build apk --release
```

The APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`

Transfer to your phone and install it directly.

---

## Build for iOS (requires Mac)

On a Mac with Xcode installed:
```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and archive it.

---

## App Features

| Feature | Description |
|---------|-------------|
| 🧠 Smart Suggestions | Gaussian time-proximity scoring learns your habits |
| 📊 Analytics | Line chart, pie chart, bar chart, calendar heatmap |
| 💰 Budgets | Weekly/monthly/yearly budgets with 80% alert |
| 📤 CSV Export | Share your data as CSV |
| 📊 Excel Export | Share your data as .xlsx |
| 🔔 Notifications | Budget alert notifications |
| 🎨 Design | Indigo/Emerald/Rose palette, Material 3 |
| 💾 Local DB | SQLite (no internet required) |

---

## Project Structure

```
lib/
├── main.dart              ← Entry point
├── app.dart               ← MaterialApp + theme
├── models/                ← Data classes (Transaction, Budget, etc.)
├── services/              ← Database, Export, Notifications
├── viewmodels/            ← Business logic (Provider)
├── views/                 ← All UI screens
│   ├── onboarding/        ← 4-page onboarding flow
│   ├── dashboard/         ← Home screen
│   ├── add_transaction/   ← Add transaction sheet
│   ├── analytics/         ← Charts & heatmap
│   ├── budget/            ← Budget management
│   ├── transactions/      ← Transaction history
│   └── settings/          ← App settings
├── design/                ← Colors, theme, spacing
└── extensions/            ← Dart extension methods
```

---

## Customization

### Change app name
Edit `pubspec.yaml` → `name:` and both platform files.

### Change primary color
Edit `lib/design/app_colors.dart` → `primary` constant.

### Add Google Play Store icon
Replace files in `android/app/src/main/res/mipmap-*/`
with your 512×512 icon (use: https://easyappicon.com/)

---

## Troubleshooting

**`flutter pub get` fails**
→ Check internet connection, or run `flutter pub cache repair`

**Emulator not showing**
→ Open Android Studio → Device Manager → Start the emulator first

**`flutter doctor` shows issues**
→ Follow each item's fix instructions exactly

**App crashes on start**
→ Run `flutter run --verbose` to see detailed logs
