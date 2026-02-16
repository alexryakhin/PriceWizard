# PriceWizard

A Mac app to set **App Store subscription prices** for all territories from one screen—no more updating 175 countries by hand in App Store Connect.

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

## What it does

- **Connect** with your App Store Connect API key.  
- **Pick a US base price** and see a **preview** of the new price in every territory (local currency + USD).  
- **Choose a mode:** Apple Equalization, Netflix-style, or Spotify-style regional pricing; override per territory if needed.  
- **Apply** all changes in one go. The app skips territories that already have the target price and won’t apply on a date that already has a scheduled price change.  

---

## Privacy

We don’t collect or receive your data. Your API key stays in your Mac’s Keychain. The app talks only to Apple’s API and to a public exchange-rate service for USD conversion.

---

## Other docs

| Document | Purpose |
|----------|---------|
| [APP_STORE_RESUME.md](APP_STORE_RESUME.md) | One-pager for the app (listing, reviewers, landing). |
| [APP_STORE_PUBLISHING_GUIDE.md](APP_STORE_PUBLISHING_GUIDE.md) | App Store Connect: name, subtitle, keywords, description, review notes, etc. |
| [APP_STORE_COMPLIANCE_AUDIT.md](APP_STORE_COMPLIANCE_AUDIT.md) | App Store compliance and privacy audit. |

---

## License

© 2026 Alexander Riakhin. All rights reserved.
