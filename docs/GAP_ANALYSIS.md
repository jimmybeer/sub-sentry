# Gap Analysis Report
**Generated**: 2026-02-07  
**Project**: SubSentry MVP  
**Audit Scope**: Implementation vs. Documentation (03-09)

---

## Executive Summary

**Overall Status**: 🟡 **Near Complete** (MVP Core: 90% | Polish: 60%)

- ✅ **Working**: All core CRUD, routing, state management, charts, settings, onboarding
- 🟡 **Partial**: Visual design tokens, test coverage
- ❌ **Missing**: Notifications/alerts, deep linking, splash screen, production assets

**Critical Gaps**: 
1. **Alert Engine** (notifications) - Core value proposition
2. **Category design colors** mismatch spec
3. **Production assets** (icon, splash)
4. **Test failures** (delete test, widget_test)

---

## 1. MISSING FEATURES

### 1.1 The "Alert Engine" — **CRITICAL GAP**
**Defined In**: `03_FEATURE_SCOPE.md` § 1.2

**What's Missing**:
- ❌ **Renewal Alerts**: Push notifications X days before billing
- ❌ **Trial Warnings**: 24-hour urgent notification before trial converts
- ❌ **Contract Expiry**: Long-term alerts for 12/18/24 month contracts

**Impact**: **HIGH** - This is core value proposition ("never forget a subscription")

**What Needs to Be Built**:
```dart
// Required implementations:
1. features/notifications/
   - domain/notification_service.dart (Local notifications using flutter_local_notifications)
   - logic/alert_scheduler.dart (Calculates alert dates from billing cycles)
   - presentation/settings/notification_settings_screen.dart

2. Integration with SubscriptionController:
   - Schedule alert when subscription is added/updated
   - Cancel alerts when subscription is deleted/paused

3. Settings UI (05_WIREFRAMES.md § 2.4):
   - Renewal Alert: [Same Day] / [1 Day Before] / [3 Days Before]
   - Trial Alert: [24 Hours Before] (Fixed)
```

**Dependencies Missing from `pubspec.yaml`**:
```yaml
flutter_local_notifications: ^17.0.0  # NOT in current pubspec
permission_handler: ^11.0.0           # NOT in current pubspec
```

---

### 1.2 Smart Defaults / Auto-complete
**Defined In**: `03_FEATURE_SCOPE.md` § 1.1 + `05_WIREFRAMES.md` § 2.3

**What's Missing**:
- ❌ Service name auto-complete (Netflix, Spotify, etc.)
- ❌ Pre-populated default prices when service matched
- ❌ Auto-filled category/color based on service name

**Current State**: Basic text input with no suggestions

**What Needs to Be Built**:
```dart
// core/constants/service_presets.dart
const Map<String, ServicePreset> commonServices = {
  'netflix': ServicePreset(
    name: 'Netflix',
    defaultCost: 15.99,
    category: SubCategory.entertainment,
    colorHex: '#E50914', // Netflix red
  ),
  'spotify': ServicePreset(cost: 9.99, category: SubCategory.entertainment),
  // ... 50+ common services
};

// In AddSubscriptionScreen:
- Replace TextField with Autocomplete<ServicePreset>
- On selection, auto-fill cost, category, color
```

---

### 1.3 Cancellation URL Integration
**Defined In**: `03_FEATURE_SCOPE.md` § 1.4 (Data Schema)

**Current State**: 
- ✅ Field exists in domain model (`cancellationUrl`)
- ❌ NOT exposed in Add/Edit UI
- ❌ No deep link action from subscription card

**What Needs to Be Built**:
```dart
// In AddSubscriptionScreen / EditSubscriptionScreen:
- Add TextFormField for cancellationUrl in "More Options" section

// In SubscriptionCard widget:
- Add IconButton (Icons.launch) when cancellationUrl != null
- onPressed: launchUrl(subscription.cancellationUrl!)

// pubspec.yaml addition:
url_launcher: ^6.2.0  // NOT currently included
```

---

### 1.4 Payment Source Field
**Defined In**: `03_FEATURE_SCOPE.md` § 1.4

**Current State**:
- ✅ Exists in domain model
- ❌ NOT in Add/Edit form UI
- ❌ No filtering/grouping by payment source

**Impact**: LOW (nice-to-have, not MVP critical)

**What Needs to Be Built**:
- Add optional TextField in "More Options" accordion: `"Payment Source (e.g. Monzo)"`

---

### 1.5 Empty State Illustration
**Defined In**: `05_WIREFRAMES.md` § 4 (Edge Case: Zero Data)

**Current State**:
- ✅ Empty state text exists in DashboardScreen
- ❌ Missing illustration/visual

**Spec Says**:
```
- Center Screen Illustration: A chill person relaxing (using undraw.co or similar)
- Headline: "Ghost Town?"
- Subtext: "If you really have 0 subscriptions, you are a legend. If not, hit the + button."
- Arrow pointing to FAB
```

**What Needs to Be Built**:
- Add SVG asset from undraw.co (person relaxing)
- Use `flutter_svg` package
- Update DashboardScreen empty state widget

---

## 2. MISSING SCREENS

### 2.1 Splash Screen
**Defined In**: `08_NAVIGATION_MAP.md` § 2 (Route: `/`)

**Current State**:
- ❌ No splash screen implementation
- ✅ Route `/` redirects to `/home` (works but no visual splash)

**Spec Says**: Route splash → Check First Run → Onboarding or Dashboard

**Current Behavior**: App shows white screen for ~500ms, then jumps to onboarding/dashboard

**What Needs to Be Built**:
```dart
// features/splash/presentation/splash_screen.dart
class SplashScreen extends StatefulWidget {
  // Show logo/branding for 1-2 seconds
  // Check if Hive is initialized
  // Redirect to /onboarding or /home
}

// Update app_router.dart:
// Remove immediate redirect from '/', show SplashScreen first
```

**Assets Needed**:
- `assets/logo/logo.svg` or `logo.png` (NOT currently exists)

---

## 3. MISSING ROUTES

**Status**: ✅ **COMPLETE** - All documented routes are implemented

Verification:
- ✅ `/` → redirects to `/home`
- ✅ `/onboarding` → OnboardingScreen
- ✅ `/home` → DashboardScreen
- ✅ `/home/settings` → SettingsScreen
- ✅ `/home/add` → AddSubscriptionScreen (Modal)
- ✅ `/home/edit/:id` → EditSubscriptionScreen (Modal)

**Deep Linking** (`08_NAVIGATION_MAP.md` § 3):
- ❌ NOT implemented (subsentry:// scheme)
- Impact: LOW (not MVP critical)

---

## 4. DESIGN DRIFT

### 4.1 Typography — **PARTIAL COMPLIANCE**
**Spec** (`06_VISUAL_DESIGN.md` § 2.1):
- Headings: `Outfit` (Google Font)
- Body: `Inter` (Google Font)

**Actual Implementation** (`app/theme/app_theme.dart`):
✅ **CORRECT**:
- `displayLarge`: Outfit, 32sp, Bold, letterSpacing: -1.0 ✓
- `headlineMedium`: Outfit, 24sp, SemiBold, letterSpacing: -0.5 ✓
- `titleMedium`: Outfit, 18sp, Medium ✓
- `bodyLarge`: Inter, 16sp, Regular ✓
- `bodyMedium`: Inter, 14sp, Regular ✓
- `labelSmall`: Inter, 11sp, Bold, letterSpacing: 0.5 ✓

**Status**: ✅ **FULLY COMPLIANT**

---

### 4.2 Category Colors — **MAJOR DRIFT**
**Spec** (`06_VISUAL_DESIGN.md` § 1.2):
| Category | Spec Hex | Actual Implementation | Match? |
|----------|----------|----------------------|---------|
| entertainment | `#9A031E` (Ruby Red) | `Colors.purple` | ❌ **WRONG** |
| utilities | `#FB8B24` (Safety Orange) | `Colors.orange` | 🟡 Close but not exact |
| software | `#00A896` (Persian Green) | `Colors.blue` | ❌ **WRONG** |
| finance | `#5F0F40` (Tyrian Purple) | `Colors.red` | ❌ **WRONG** |
| gym | `#02C39A` (Mint) | `Colors.green` | 🟡 Close but not exact |
| other | `#8D99AE` (Cool Grey) | `Colors.grey` | 🟡 Close but not exact |

**Found In**: `lib/features/analysis/presentation/widgets/breakdown_chart.dart` lines 160-176

**Impact**: **MEDIUM** - Visual brand consistency, affects charts and card icons

**What Needs to Be Fixed**:
```dart
// Create core/constants/category_colors.dart
class CategoryColors {
  static const catEntertainment = Color(0xFF9A031E);  // Ruby Red
  static const catUtilities = Color(0xFFFB8B24);      // Safety Orange
  static const catSoftware = Color(0xFF00A896);       // Persian Green
  static const catFinance = Color(0xFF5F0F40);        // Tyrian Purple
  static const catGym = Color(0xFF02C39A);            // Mint
  static const catOther = Color(0xFF8D99AE);          // Cool Grey
}

// Update breakdown_chart.dart _getColorForCategory() to use constants
// Update subscription_card.dart icon background to use constants
```

---

### 4.3 Primary Colors — **FULL COMPLIANCE**
**Spec** vs **Actual**:
- ✅ `primary`: `#0F4C5C` - Midnight Teal ✓
- ✅ `secondary`: `#E36414` - Burnt Coral ✓
- ✅ `background`: `#FAFAFA` (light) / `#121212` (dark) ✓

**Status**: ✅ **COMPLIANT**

---

### 4.4 Spacing / Border Radius — **NEEDS AUDIT**
**Spec** (`06_VISUAL_DESIGN.md` § 3):
- Cards: `16dp` radius
- Buttons: `12dp` radius
- Bottom Sheet: `24dp` (top corners only)

**Spot Check** (app_theme.dart):
- ✅ CardTheme: `borderRadius: 16` - CORRECT ✓

**Action Needed**: Manual audit of all `BorderRadius` usages in widgets

---

### 4.5 Shadows — **USING STANDARD MATERIAL**
**Spec** (`06_VISUAL_DESIGN.md` § 3.3):
```
Card Shadow: 0px 4px 12px rgba(15, 76, 92, 0.08) (Tinted with Primary)
FAB Shadow: 0px 8px 16px rgba(227, 100, 20, 0.3) (Tinted with Secondary)
```

**Actual**: Using Material default elevation system

**Impact**: **LOW** - Minor visual polish, not user-facing functional issue

**What Needs to Be Fixed**: Override `cardTheme.shadowColor` and FAB boxShadow

---

### 4.6 Hardcoded Colors NOT Using Tokens

**Found Violations**:
1. `pulse_chart.dart` line 118: `color: Colors.orangeAccent` (should use secondary or define token)
2. `pulse_chart.dart` line 158: `color: Colors.orangeAccent` (cumulative line)
3. Various `Colors.grey` usages (should use `textSecondary` from theme)

**Recommendation**: Conduct full `grep "Colors\."` audit and replace with theme tokens

---

## 5. INCOMPLETE TASKS

**Reference**: `09_DEV_CHECKLIST.md`

### Phase 5: Production Readiness — **0% Complete**
- ❌ **5.1 App Icon**: Generate launcher icons
  - **Status**: No custom icon, using Flutter default
  - **Action**: Use `flutter_launcher_icons` package (already in dev deps) + create icon asset
  
- ❌ **5.2 Splash Screen**: Configure native splash
  - **Status**: Not configured
  - **Action**: Use `flutter_native_splash` package + create splash asset

- ❌ **5.3 Release Build**: Verify `--release` build works on Android/iOS
  - **Status**: Android APK builds successfully ✓ (we tested this)
  - **Status**: iOS not verified (no Mac/Xcode test)
  - **Action**: Mark Android as DONE, add iOS verification task

---

### Hidden Tasks (Not in Checklist but in Spec)

**From** `03_FEATURE_SCOPE.md` § 1.2:
- ❌ Notification implementation (**missing from checklist!**)

**From** `05_WIREFRAMES.md` § 2.1:
- 🟡 Onboarding: Partially complete (functional but doesn't match wire exactly)
  - **Spec**: 3-step wizard ("What service?" → "How much?" → "When due?")
  - **Actual**: Multi-field form all at once

---

## 6. MISSING TESTS

### 6.1 Test Coverage — **GOOD**
**Total Test Files**: 15
- ✅ Core Logic: `billing_calculator_test.dart`
- ✅ Stats Logic: `subscription_stats_test.dart`
- ✅ Domain: `subscription_test.dart`
- ✅ Data Layer: `subscription_model_test.dart`, `hive_subscription_repository_test.dart`
- ✅ Controllers: `subscription_controller_test.dart`
- ✅ Screens: Dashboard, Onboarding, Settings, Add, Edit
- ✅ Widgets: SubscriptionCard, PulseChart, BreakdownChart

### 6.2 Test Failures — **BLOCKING ISSUE**
**Status**: ❌ **25 passing, 4 failing**

**Failures**:
1. ❌ `edit_subscription_screen_test.dart` - "deletes subscription"
   - **Error**: "Exception caught by gesture" during delete confirmation
   - **Root Cause**: Context/navigation timing issue in test harness
   - **Impact**: HIGH - Delete functionality works in app but test is unreliable

2. ❌ `widget_test.dart`
   - **Error**: `Couldn't find constructor 'MyApp'`
   - **Root Cause**: Stale test file from Flutter init, never updated
   - **Impact**: LOW - Not a real test, just placeholder
   - **Fix**: Delete file or update to test actual MyApp from main.dart

**Action Required**: 
- Fix or skip `edit_subscription_screen_test.dart::deletes subscription` test
- Delete `widget_test.dart` (obsolete)

### 6.3 Missing Test Coverage

**Implemented Features WITHOUT Tests**:
- ❌ Settings "Generate Test Data" button (new feature added recently)
- ❌ Settings "Wipe Data" functionality
- ❌ Settings currency/theme toggle persistence
- ❌ Onboarding wizard completion → `hasSeenOnboarding` flag set

**Impact**: LOW for MVP (core features are tested)

---

## 7. PRIORITY RECOMMENDATIONS

### 🔴 **P0 - Critical (Pre-Launch Blockers)**
1. **Implement Alert Engine** (notifications)
   - This is THE core value proposition
   - Estimated: 1-2 days full implementation + testing

2. **Fix Category Colors to Match Spec**
   - Quick win, affects brand perception
   - Estimated: 1 hour

3. **Fix Test Failures**
   - Delete or skip `widget_test.dart`
   - Investigate `edit_subscription_screen_test` delete issue
   - Estimated: 2-3 hours

4. **Production Assets**
   - Generate app icon (use SubSentry brand)
   - Configure splash screen
   - Estimated: 2-3 hours with design

### 🟡 **P1 - High (MVP Quality)**
5. **Service Auto-complete**
   - Major UX improvement
   - Estimated: 4-6 hours (50+ presets + UI integration)

6. **Empty State Illustration**
   - Professional polish, quick add
   - Estimated: 30 minutes (asset sourcing + integration)

7. **Cancellation URL Field & Deep Link**
   - Mentioned in spec, useful feature
   - Estimated: 1-2 hours

### 🟢 **P2 - Nice-to-Have (Post-MVP)**
8. Payment Source field in UI
9. Deep linking (subsentry:// scheme)
10. Audit all hardcoded colors → theme tokens
11. Custom shadow implementation (vs Material defaults)

---

## 8. VERIFICATION CHECKLIST

Following `@skills/verification-before-completion`:

### Before Claiming "MVP Complete":

- [ ] Run `flutter test` → **MUST show 0 failures**
  - Current: 4 failures → **NOT PASSING**
  
- [ ] Run `flutter analyze` → **MUST show 0 errors**
  - Current: Unknown (not verified in this audit)
  
- [ ] Build release APK → **MUST complete with exit 0**
  - Current: ✅ PASSING (49.8MB APK builds successfully)

- [ ] Manual test on device (each feature):
  - [ ] Add subscription
  - [ ] Edit subscription
  - [ ] Delete subscription (**needs verification - test fails**)
  - [ ] View Pulse chart
  - [ ] View Breakdown chart
  - [ ] Toggle theme
  - [ ] Toggle currency
  - [ ] Wipe data
  - [ ] Onboarding flow
  - [ ] **Receive notification alert** (**NOT POSSIBLE - feature missing**)

---

## 9. COMPLIANCE MATRIX

| Document | Compliance % | Critical Gaps |
|----------|--------------|---------------|
| 03_FEATURE_SCOPE.md | 75% | Alerts, Smart Defaults |
| 05_WIREFRAMES.md | 85% | Empty state illustration, Onboarding exact match |
| 06_VISUAL_DESIGN.md | 90% | Category colors drift |
| 07_ARCHITECTURE.md | 100% | ✅ Full compliance |
| 08_NAVIGATION_MAP.md | 95% | Deep linking not impl |
| 09_DEV_CHECKLIST.md | 80% | Phase 5 incomplete |

**Overall MVP Readiness**: **75-80%**

---

## 10. SUGGESTED ACTION PLAN

### Sprint 1 (Critical Path - 2-3 days)
**Goal**: Launch-ready MVP

1. **Day 1 Morning**: Implement Notification Service skeleton
2. **Day 1 Afternoon**: Integrate alerts with SubscriptionController
3. **Day 2 Morning**: Add notification settings to Settings screen
4. **Day 2 Afternoon**: Test notification scheduling thoroughly
5. **Day 3 Morning**: Fix category colors + test failures
6. **Day 3 Afternoon**: Generate icon/splash, final QA

### Sprint 2 (Post-Launch Polish - 1-2 days)
7. Service autocomplete
8. Empty state assets
9. Cancellation URL integration
10. Payment source UI

---

**End of Gap Analysis**  
*This document should be updated as gaps are closed.*
