# App Store Connect – PriceWizard Publishing Guide

Use this when creating or editing your app listing in App Store Connect.

---

## 1. App Information (General)

| Field | Value |
|-------|--------|
| **Name** | PriceWizard |
| **Subtitle** | Subscription prices for all territories |
| **Category** | Primary: **Developer Tools** (or **Productivity**). Secondary: optional. |
| **Content Rights** | You own the rights / have the right to use the content. |
| **Age Rating** | 4+ (no restricted content). |

---

## 2. Name

**Exactly 30 characters or fewer (App Store shows this under the icon).**

**Recommended:**  
`PriceWizard`

(10 characters; fits easily.)

---

## 3. Subtitle

**Exactly 30 characters or fewer. Shown under the name in search and on the product page.**

**Recommended:**  
`Subscription prices for all territories`

(42 characters — too long. Use one of these.)

- `Set subscription prices in one go` (32 — trim to 30)
- `Subscription prices in one go` (29) ✅
- `Manage subscription pricing by region` (36 — trim)
- `Bulk subscription price manager` (29) ✅

**Pick one (≤30 chars):**

- **Option A:** `Subscription prices in one go`
- **Option B:** `Bulk subscription price manager`

---

## 4. Keywords

**100 characters total, comma-separated, no spaces after commas. No repeat of app name. Used for search.**

**Suggested (99 characters):**  
`app store connect,subscription,pricing,territories,in-app purchase,iap,developer,asc api,bulk,localization`

**Alternative (shorter):**  
`app store connect,subscription,pricing,territories,iap,developer,bulk price`

Replace or add terms based on what you want to rank for (e.g. “revenue”, “prices by country”).

---

## 5. Description (up to 4,000 characters)

**Paste this and adjust as needed:**

```
PriceWizard sets your App Store subscription prices for every territory from one screen—no more updating 175 countries by hand.

FOR DEVELOPERS WITH SUBSCRIPTIONS

• Connect with your App Store Connect API key (Key ID, Issuer ID, .p8 file). Your key stays in your Mac’s Keychain; we never see it.
• Pick a US base price and see a full preview: new price per territory, in local currency and USD.
• Choose Apple Equalization, Netflix-style, or Spotify-style regional pricing and tweak any territory.
• Apply all changes in one go. The app skips territories that already have the target price and won’t let you apply on a date that already has a scheduled change.

ONE-TIME PURCHASE

No subscription. Pay once and use the app. No account with us—just your Apple ID and your App Store Connect API key.

PRIVACY

We don’t collect or receive your data. Credentials are stored only in your Mac’s Keychain. The app talks only to Apple’s API and to a public exchange-rate service for USD conversion.

Requires: macOS 15 or later. An App Store Connect API key with App Manager (or Admin) access.
```

**Character count:** ~1,100. You have room to add support URL, requirements, or a short “What’s new” for updates.

---

## 6. Promotional Text (optional)

**170 characters. Can be changed anytime without a new version. Use for sales or news.**

**Example:**  
`Set subscription prices for all territories in one go. One-time purchase—no subscription. Connect with your App Store Connect API key.`

---

## 7. What’s New (version release notes)

**For version 1.0 (e.g. 4,000 characters max):**

```
• Connect with your App Store Connect API key and manage subscription prices for all territories.
• Preview prices with Apple Equalization, Netflix-style, or Spotify-style regional indices.
• Apply prices in bulk with progress; skip unchanged territories; avoid conflicting with scheduled price changes.
• Your credentials stay in your Mac’s Keychain; we don’t collect or receive your data.
```

For future updates, keep this short (2–5 bullet points).

---

## 8. Support URL (required for Mac)

**Must be a valid URL.** Use a page that explains how to get an API key and how to contact you.

**Examples:**
- `https://github.com/YOUR_USERNAME/PriceWizard#readme`
- `https://yourapp.com/pricewizard-support`
- `mailto:your-support@email.com` (some developers use this; a webpage is usually better)

**Add to description if helpful:**  
“Support: [your URL]”

---

## 9. Review Notes (paste into App Store Connect)

**Paste this in the “Notes for Review” (or equivalent) field so Review understands the app:**

```
PriceWizard is a Mac app for developers who manage App Store subscription pricing. It uses the official App Store Connect API.

AUTHENTICATION
Users sign in with their own App Store Connect API key (Key ID, Issuer ID, and .p8 file). The app stores these in the system Keychain only for signing API requests. We do not collect, transmit, or have access to user credentials.

NETWORK
The app connects only to:
1. https://api.appstoreconnect.apple.com — official App Store Connect API (apps, subscription groups, subscriptions, price points, equalizations, territories, create subscription prices).
2. https://api.frankfurter.dev — public API for USD exchange rates (used for “New Price (USD)” in the preview table). There is a built-in fallback if the request fails.

No analytics, no third-party SDKs, no data sent to the developer. No account with us—only the user’s Apple ID and their App Store Connect API key.

TESTING
To test, the reviewer will need an App Store Connect API key with access to at least one app that has a subscription group. Create one at App Store Connect → Users and Access → Integrations → App Store Connect API. The app will prompt for Key ID, Issuer ID, and the .p8 file.
```

---

## 10. App Privacy (questionnaire in App Store Connect)

Answer in the **App Privacy** section:

- **Do you or your third-party partners collect data from this app?**  
  → **No** (we don’t collect data that leaves the device to us or to partners).

If the questionnaire forces you to pick “Yes” for “data collected” (e.g. “networking” or “other”):
- Choose the minimal option (e.g. “Other data” or “Product interaction” only if you must).
- Set: **Not used for tracking**, **Not linked to identity**, purpose **App functionality**.
- In Review notes, repeat: “We do not collect or receive user data; credentials stay in Keychain; only Apple API and exchange-rate API are used.”

- **Do you or your third-party partners use data for tracking?**  
  → **No.**

---

## 11. Pricing

- **Price:** Choose **one-time** (e.g. $2 or your chosen tier).
- **No in-app purchase** required for the current build; the app is fully usable after the one-time purchase.

---

## 12. Screenshots & Preview (Mac App Store)

**Requirements:**  
At least one screenshot (often 1280×800 or 1440×900 for Mac). Optional: app preview video.

**Suggested screens:**
1. Auth/setup (Key ID, Issuer ID, .p8).
2. Main workflow: app list → subscription → base price + preview table.
3. Price Change Options + Apply (with “Next scheduled change” and progress if visible).

Add short captions if the UI isn’t obvious (e.g. “Pick a base price and see all territories”).

---

## 13. Pre-submission checklist

- [ ] Name (≤30 chars), Subtitle (≤30 chars), Keywords (≤100 chars, no spaces after commas).
- [ ] Description and “What’s New” filled in.
- [ ] Support URL set and valid.
- [ ] Review notes pasted.
- [ ] App Privacy completed (no tracking; no or minimal data collection).
- [ ] Price set (one-time).
- [ ] At least one Mac screenshot (and optional preview).
- [ ] Build uploaded and selected for the version.
- [ ] Copyright in Xcode matches (e.g. © 2026 [Your Name]).
- [ ] PrivacyInfo.xcprivacy is in the app bundle (no tracking, no collected data).

Once this is done, submit for review.
