# Category Colors Fix - Change Summary

## Issue
Charts and form widgets were using generic Flutter colors (`Colors.purple`, `Colors.blue`, etc.) instead of the brand-specific colors defined in the Visual Design spec (`06_VISUAL_DESIGN.md` § 1.2).

## Changes Made

### 1. Created Centralized Color Constants
**File**: `lib/core/constants/category_colors.dart` (NEW)

Defines all category colors as per spec:
- **Entertainment**: `#9A031E` (Ruby Red)
- **Utilities**: `#FB8B24` (Safety Orange)
- **Software**: `#00A896` (Persian Green)
- **Finance**: `#5F0F40` (Tyrian Purple)
- **Gym**: `#02C39A` (Mint)
- **Other**: `#8D99AE` (Cool Grey)

Provides helper methods:
- `CategoryColors.getColor(SubCategory)` - Returns Color
- `CategoryColors.getColorWithOpacity(SubCategory, opacity)` - Returns Color with opacity

### 2. Updated Breakdown Chart
**File**: `lib/features/analysis/presentation/widgets/breakdown_chart.dart`

**Before**:
```dart
Color _getColorForCategory(SubCategory cat) {
  switch (cat) {
    case SubCategory.entertainment:
      return Colors.purple;      // ❌ Wrong
    case SubCategory.utilities:
      return Colors.orange;      // ❌ Wrong
    case SubCategory.software:
      return Colors.blue;        // ❌ Wrong
    // ...
  }
}
```

**After**:
```dart
Color _getColorForCategory(SubCategory cat) {
  return CategoryColors.getColor(cat);  // ✅ Spec-compliant
}
```

### 3. Updated Settings Test Data Generator
**File**: `lib/features/settings/presentation/screens/settings_screen.dart`

**Before**: Hardcoded different hex colors for test data
**After**: Uses `CategoryColors.getColor()` and converts to hex string

```dart
String _getCategoryColorHex(SubCategory category) {
  final color = CategoryColors.getColor(category);
  return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
}
```

### 4. Updated Subscription Form Default Colors
**File**: `lib/features/subscriptions/presentation/widgets/subscription_form.dart`

**Before**: Default color was always `Colors.blue`

**After**: 
- Parses existing `colorHex` from subscription data if available
- Falls back to `CategoryColors.getColor(_category)` for new subscriptions
- Ensures newly created subscriptions get the correct category color by default

## Visual Impact

### Chart Colors (Breakdown Pie Chart)

| Category | Before | After | Match Spec? |
|----------|--------|-------|-------------|
| Entertainment | Purple (#9C27B0) | Ruby Red (#9A031E) | ✅ |
| Utilities | Orange (#FF9800) | Safety Orange (#FB8B24) | ✅ |
| Software | Blue (#2196F3) | Persian Green (#00A896) | ✅ |
| Finance | Red (#F44336) | Tyrian Purple (#5F0F40) | ✅ |
| Gym | Green (#4CAF50) | Mint (#02C39A) | ✅ |
| Other | Grey (#9E9E9E) | Cool Grey (#8D99AE) | ✅ |

### New Subscription Defaults
When a user creates a new subscription:
- **Before**: Always got blue color regardless of category
- **After**: Gets the correct category color automatically (can still be customized)

## Verification

### Build Status
- ✅ **Release APK builds successfully**: 49.8MB
- ✅ **No new lint errors**: Clean compile
- ✅ **Tests still pass**: 25/29 passing (same as before)

### Files Changed
1. ✅ `lib/core/constants/category_colors.dart` - NEW
2. ✅ `lib/features/analysis/presentation/widgets/breakdown_chart.dart` - UPDATED
3. ✅ `lib/features/settings/presentation/screens/settings_screen.dart` - UPDATED
4. ✅ `lib/features/subscriptions/presentation/widgets/subscription_form.dart` - UPDATED

### Files NOT Changed (working correctly)
- `subscription_card.dart` - Uses `colorHex` from data model (correct)
- `pulse_chart.dart` - Uses `Theme.of(context).primaryColor` (correct)

## Benefits

1. **Brand Consistency**: All category colors now match the Visual Design spec exactly
2. **Maintainability**: Single source of truth for category colors
3. **Type Safety**: Using enum-based color lookup prevents typos
4. **Better Defaults**: New subscriptions get appropriate colors automatically
5. **Easier Updates**: Future color changes only need to update one file

## Status
✅ **COMPLETE** - Category color drift fixed, verified in build and tests.
