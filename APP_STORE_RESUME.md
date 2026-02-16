# PriceWizard – App Store Résumé

**One-line pitch:** Set subscription prices for all territories from one screen—no more clicking through 175 countries in App Store Connect.

---

## What it does

PriceWizard is a **Mac app** for developers and publishers who sell **auto-renewable subscriptions** on the App Store. It connects to **App Store Connect** with your API key and lets you:

- **Pick a US base price** (e.g. $9.99) and see a **preview table** of the new price in every territory (with local currency and USD equivalent).
- Choose **Apple Equalization** (Apple’s own tier mapping), **Netflix-style**, or **Spotify-style** regional indices and adjust per-territory if needed.
- **Apply all prices in one go** to App Store Connect (with progress and skip-if-unchanged), and avoid applying on a date that already has a scheduled change.

**Who it’s for:** Indie and small teams who manage subscription pricing and don’t want to update 175 territories by hand in the web UI.

---

## Key features

| Feature | Description |
|--------|-------------|
| **App Store Connect API** | Sign in with your API key (Key ID, Issuer ID, .p8); credentials stored only in the Mac Keychain. |
| **Base price** | Choose from .99 (and &lt;50 .49) US price points; full tier list limited so the picker stays fast. |
| **Preview** | Table of all territories with current price, new price, currency, and USD equivalent. |
| **Index modes** | Apple Equalization, Netflix, or Spotify regional multipliers; optional per-territory overrides. |
| **Apply** | One-time apply with progress bar; skips territories already at the target price; blocks applying on an already-scheduled start date. |
| **Privacy** | No analytics, no account with us, no data sent to the developer. |

---

## Technical snapshot

- **Platform:** macOS 15+, SwiftUI, native.
- **Network:** Only `api.appstoreconnect.apple.com` (Apple) and `api.frankfurter.dev` (exchange rates, with fallback).
- **Data:** API key in Keychain; no collection or tracking.
- **Distribution:** Mac App Store; one-time purchase.

---

## Positioning

- **Price:** One-time purchase (e.g. $2). Competitors often charge ~$40/year for similar tools.
- **Differentiator:** Simple, focused, one-time fee, no subscription.

Use this résumé for the App Store description, for reviewers, or for a short landing page.
