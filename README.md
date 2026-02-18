# PriceWizard

A **free** Mac app to set **App Store subscription prices** for all territories from one screen - no more updating 175 countries by hand in App Store Connect.

---

## Requirements

- **macOS 15** or later  
- **App Store Connect API key** (Key ID, Issuer ID, and `.p8` file) with **App Manager** or **Admin** access  

---

## Getting an API key

1. Open [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **App Store Connect API**.  
2. Create a key (or use an existing one).  
3. Download the `.p8` file once (Apple doesn’t show it again).  
4. Note the **Key ID** and **Issuer ID** on the same page.  

PriceWizard will ask for **Key ID**, **Issuer ID**, and the **.p8 file** when you connect. Credentials are stored only in your Mac’s Keychain.

---

## Build and run

1. Open `PriceWizard.xcodeproj` in Xcode.  
2. Select the **PriceWizard** scheme and a Mac destination.  
3. **Product → Run** (⌘R).  

No extra dependencies; the project uses only the macOS SDK.

---

## Fastlane (metadata)

For managing App Store metadata (name, description, keywords, etc.) from the repo:

1. **Install:** `bundle install` (from project root).
2. **Set Apple ID:** `export DELIVER_USERNAME=your@email.com` or edit `fastlane/Appfile` and set `apple_id`.
3. **Lanes:**
   - `bundle exec fastlane metadata_download` - pull current metadata from App Store Connect into `fastlane/metadata`.
   - `bundle exec fastlane metadata_upload` - push `fastlane/metadata` to App Store Connect.
   - `bundle exec fastlane metadata_check` - run precheck (validates metadata before submit).
   - `bundle exec fastlane metadata_init` - initialize or refresh metadata folder from App Store Connect.

Edit `fastlane/metadata/en-US/*.txt` and `fastlane/metadata/copyright.txt` as needed. Update `support_url.txt` with your real support URL before upload.

---

## What it does

- **Connect** with your App Store Connect API key.  
- **Pick a US base price** and see a **preview** of the new price in every territory (local currency + USD).  
- **Choose a mode:** Apple Equalization, Netflix-style, or Spotify-style regional pricing; override per territory if needed.  
- **Apply** all changes in one go. The app skips territories that already have the target price and won’t apply on a date that already has a scheduled price change.  

---

## Privacy

We don’t collect or receive your data. Your API key stays in your Mac’s Keychain. The app talks only to Apple’s API and to a public exchange-rate service for USD conversion.

---

## License

© 2026 Alexander Riakhin. All rights reserved.
