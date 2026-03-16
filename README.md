# PriceWizard

Localize your App Store subscription prices by purchasing power and update 175+ countries from one safe bulk apply – no more clicking through App Store Connect by hand.

**[Download on the App Store](https://apps.apple.com/app/id6759319356)**

---

## What PriceWizard does

- **Connects to App Store Connect** with your API key and talks directly to Apple’s API.  
- **Lets you pick a US base price** and preview the resulting price in every territory (local currency + USD).  
- **Applies Apple-, Netflix-, or Spotify-style regional pricing** based on purchasing power, with the option to override per territory.  
- **Updates prices safely in one go** – skipping territories that already match your target price and avoiding dates that already have a scheduled price change.  

Use it to run pricing experiments, make your app more affordable in lower-income countries, and stop undercharging in high-income ones, without fighting App Store Connect.

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

PriceWizard will ask for **Key ID**, **Issuer ID**, and the **.p8 file** when you connect. Credentials are stored only in your Mac’s Keychain.

---

## How PriceWizard decides prices

At a high level:

- You select a **US base price** for your subscription.  
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

We don’t collect or receive your data. Your API key stays in your Mac’s Keychain. The app talks only to Apple’s API and to a public exchange-rate service for USD conversion.

---

## Website / SEO

The site includes `robots.txt`, `sitemap.xml`, canonical URLs, Open Graph and Twitter Card meta tags, and JSON-LD (homepage). The live URL is **https://alexryakhin.github.io/PriceWizard**. If you change domain or path, search for that URL and replace it in `robots.txt`, `sitemap.xml`, and each HTML file (canonical, og:url, og:image, twitter:image, and the ld+json script on the homepage).

---

## License

© 2026 Alexander Riakhin. All rights reserved.
