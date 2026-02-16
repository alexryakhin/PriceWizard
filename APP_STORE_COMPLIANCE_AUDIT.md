# PriceWizard – App Store Compliance Audit

**Date:** February 2026  
**Platform:** macOS (Mac App Store)  
**Bundle ID:** dor.PriceWizard

---

## 1. Summary

| Area | Status | Notes |
|------|--------|--------|
| **Sandbox & entitlements** | ✅ Compliant | Sandbox on, network client + user-selected read-only |
| **Privacy & data** | ✅ Addressed | PrivacyInfo.xcprivacy added (no tracking, no collected data); see Review notes in publishing guide |
| **External services** | ✅ Documented | Apple ASC API + Frankfurter (exchange rates) |
| **Payments** | ➖ N/A | No in-app purchase in app yet; $2 one-time is via App Store price |
| **Guideline 2.1 (App completeness)** | ✅ | App is functional and focused |
| **Guideline 5.1 (Privacy)** | ✅ | Privacy manifest + App Privacy questionnaire + Review notes (see APP_STORE_PUBLISHING_GUIDE.md) |
| **Guideline 4.2 (Minimum functionality)** | ✅ | Clear utility for subscription price management |

---

## 2. Entitlements & Sandbox

**Current entitlements** (`PriceWizard.entitlements`):

- `com.apple.security.app-sandbox` = true ✅
- `com.apple.security.network.client` = true ✅
- `com.apple.security.files.user-selected.read-only` = true ✅

**Verdict:** Appropriate for a Mac App Store build. You only need outbound HTTPS and read-only access to the user-selected .p8 file.

**Recommendation:** Keep as-is. Do not add keychain access group entitlements unless you need shared keychain; the app uses the default keychain, which is allowed.

---

## 3. Privacy & Data Handling

### 3.1 Data you use

| Data | Where | Purpose |
|------|--------|--------|
| **API credentials** (Key ID, Issuer ID, .p8 content) | Keychain (on-device only) | App Store Connect API auth |
| **App/subscription/price data** | From Apple’s API; not stored long-term | Show and update subscription prices |
| **Exchange rates** | Fetched from api.frankfurter.dev; not stored persistently | USD conversion for preview |

Nothing is sent to your own servers. No analytics, crash reporting, or third-party SDKs were found in the codebase.

### 3.2 Gaps for App Store / Privacy

1. **Keychain usage**  
   Apple expects a clear reason when you access sensitive data. Even though there’s no dedicated “Keychain Usage Description” key on macOS like on iOS, App Store Connect’s **App Privacy** and **Review notes** should explain:
   - That you store App Store Connect API credentials in the Keychain.
   - That this is only for authenticating with Apple’s API on the user’s behalf.

2. **Network usage**  
   You use:
   - `https://api.appstoreconnect.apple.com` (App Store Connect API)
   - `https://api.frankfurter.dev` (exchange rates)

   In **App Store Connect → App Privacy** you should declare:
   - “Data used to track you”: none.
   - “Data collected” (if any): if you don’t collect any data that leaves the device in a way that identifies the user or device, you can often report “No data collected.” If you’re unsure, declare the minimum (e.g. “Other usage data” for network requests to the above endpoints) and clarify in Review notes.

3. **Privacy manifest (PrivacyInfo.xcprivacy)**  
   **Done.** Added `PriceWizard/PrivacyInfo.xcprivacy` with `NSPrivacyTracking` = false and `NSPrivacyCollectedDataTypes` = empty array (no data collection, no tracking).

**Recommendations:**

- Add a **Privacy** section in the App Store description (e.g. “Credentials stored only in your Mac’s Keychain; we don’t collect or transmit your data to our servers”). **Draft in APP_STORE_PUBLISHING_GUIDE.md §5.**
- In **App Store Connect → App Privacy**, answer the questionnaire honestly (no tracking; no or minimal “collected” data). **Steps in APP_STORE_PUBLISHING_GUIDE.md §10.**
- In **Review notes**, use the full template in **APP_STORE_PUBLISHING_GUIDE.md §9** (keychain, network endpoints, no data to developer).

---

## 4. External Services & Third-Party Code

| Service | URL | Purpose |
|--------|-----|--------|
| App Store Connect API | api.appstoreconnect.apple.com | Official Apple API; required for the app’s purpose ✅ |
| Frankfurter | api.frankfurter.dev | Exchange rates for USD conversion |

**Recommendations:**

- In **Review notes**, name both endpoints and state that Frankfurter is used only for non-personal exchange-rate data.
- If Frankfurter’s terms or availability change, the app already has a fallback (hardcoded rates in `ExchangeRateService`), which is good for reliability and compliance (no surprise dependency on a single third party).

---

## 5. Sensitive Capabilities

- **File access:** Only via `fileImporter` and `startAccessingSecurityScopedResource()` for the .p8 file. Correct for sandbox ✅  
- **No camera, microphone, location, contacts, etc.** ✅  
- **No in-app purchase or StoreKit** in the current build; the “$2 one-time” is the App Store list price, not an IAP ✅  

---

## 6. App Store Review Guidelines (Mac) – Relevant Points

- **2.1 (App completeness):** App is complete and functional; no placeholder or broken features observed ✅  
- **2.3.8 (Third-party login):** No third-party sign-in; you use the user’s own API key ✅  
- **4.2 (Minimum functionality):** Clear utility for developers/publishers managing subscription pricing ✅  
- **5.1.1 (Privacy – Data collection):** You must declare in App Privacy what (if anything) is collected; with current design, “none” or minimal is appropriate if you don’t send data off-device for tracking or profiling ✅  
- **5.1.2 (Data use):** No evidence of using data for tracking; keychain and API usage are for core functionality ✅  

Nothing in the codebase suggests guideline violations (e.g. private API use, hidden features, or misleading behavior).

---

## 7. Pricing: $2 One-Time vs $40/Year Competitors

- **App Store allows** one-time purchase as the only offer; you are not required to offer a subscription.
- **$2 one-time is compliant** and often simpler for users and for you (no subscription management, no StoreKit).
- **Competitors at $40/year** are a business choice; undercutting on price is not an App Store compliance issue.
- **What you must do:**  
  - In the app and on the product page, describe exactly what the user gets (e.g. “One-time purchase for full access” or “Lifetime access”).  
  - Do not promise “free updates forever” unless you intend to support the app long-term; “one-time purchase” is enough.

No extra compliance steps are required for a $2 one-time price vs a $40/year subscription, as long as the description is accurate.

---

## 8. Action Checklist Before Submission

- [x] **Privacy manifest:** `PriceWizard/PrivacyInfo.xcprivacy` added (no tracking, no collected data).
- [x] **Copyright:** `INFOPLIST_KEY_NSHumanReadableCopyright` set to “© 2026 Alexander Riakhin” in the target.
- [ ] **App Store Connect → App Privacy:** Complete the questionnaire (no tracking; no or minimal data collection). See APP_STORE_PUBLISHING_GUIDE.md §10.
- [ ] **Review notes:** Use the template in APP_STORE_PUBLISHING_GUIDE.md §9 (keychain, network, no data to developer).
- [ ] **App description:** Use the draft in APP_STORE_PUBLISHING_GUIDE.md §5 (includes Privacy line).
- [ ] **Support URL:** Set in App Store Connect (required for Mac). See APP_STORE_PUBLISHING_GUIDE.md §8.

---

## 9. Verdict

**Publishable:** Yes, with the privacy and metadata updates above. The app is straightforward, uses only necessary permissions, and does not collect or track users. The main risks are **rejection for incomplete App Privacy information** or **vague Review notes**; addressing Section 8 should mitigate those. A **$2 one-time price is fully compliant** and does not require any special justification compared to competitors’ $40/year subscriptions.
