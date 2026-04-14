# PriceWizard

Set PPP-aware prices for App Store **subscriptions and in-app purchases**, bulk-edit **localized display names and descriptions**, and apply everything from one screen—without clicking through App Store Connect territory by territory.

**[Download on the App Store](https://apps.apple.com/app/id6759319356)**

---

## What PriceWizard does

- **Connects to App Store Connect** with your API key and talks directly to Apple’s API.  
- **Lets you pick a US base price** and preview the resulting price in every territory (local currency + USD) for subscriptions and in-app purchases.  
- **Applies Apple-, Netflix-, or Spotify-style regional pricing** based on purchasing power, with the option to override per territory.  
- **Updates prices safely in one go** – skipping territories that already match your target price and avoiding dates that already have a scheduled price change.  
- **Edits subscription and IAP metadata per locale** – display names and descriptions, with optional machine translation before you save to App Store Connect.  

Use it to run pricing experiments, keep product copy consistent across locales, and tune affordability by market—without fighting App Store Connect.

---

## Requirements

- **iOS 17** or later  
- **macOS 15** or later  
- **App Store Connect API key** (Key ID, Issuer ID, and `.p8` file) with **App Manager** or **Admin** access  

---

## Getting an API key

1. Open [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **App Store Connect API**.  
2. Create a key (or use an existing one).  
3. Download the `.p8` file once (Apple doesn’t show it again).  
4. Note the **Key ID** and **Issuer ID** on the same page.  

PriceWizard will ask for **Key ID**, **Issuer ID**, and the **.p8 file** when you connect. Credentials are stored only in your device’s Keychain (iOS or Mac).

---

## How PriceWizard decides prices

At a high level:

- You select a **US base price** for your subscription or in-app purchase product.  
- You choose a **pricing mode**:
  - **Apple Equalization** – follow Apple’s own regional equalization logic.  
  - **Netflix-style** – tilt more toward affordability in lower-income countries.  
  - **Spotify-style** – a balanced PPP-inspired profile commonly used by subscription apps.  
- PriceWizard computes suggested prices per territory, shows you the matrix, and lets you **override any country** before applying.

When you hit apply:

- Territories that already have the target price are **skipped**.  
- Dates that already have a scheduled price change are **left untouched**.  
- Only the prices you actually intend to change are updated.

---

## Privacy

We don’t operate a backend that stores your App Store data. Your API key stays in your device’s Keychain. The app talks to Apple’s API, RevenueCat (purchase validation), optional Firebase Remote Config, a public exchange-rate service for USD preview, and—if you use machine translation—Google’s translation service from your device. The static marketing pages in this folder load Google Analytics; see `privacy.html`.

---

## Website / SEO

The site includes `robots.txt`, `sitemap.xml`, canonical URLs, Open Graph and Twitter Card meta tags, and JSON-LD (homepage). The live URL is **https://alexryakhin.github.io/PriceWizard**. If you change domain or path, search for that URL and replace it in `robots.txt`, `sitemap.xml`, and each HTML file (canonical, og:url, og:image, twitter:image, and the ld+json script on the homepage).

---

## License

© 2026 Alexander Riakhin. All rights reserved.
