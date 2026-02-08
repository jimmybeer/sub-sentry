# Debug Steps for £43.33 Issue

## Expected Behavior
- **Input**: £5 weekly subscription starting 01/01/26
- **Formula**: £5 × 4.333333 = £21.67/month (normalized)
- **Expected in Breakdown**: £21.67

## Actual Behavior  
- **Showing**: £43.33
- **Analysis**: £43.33 = 2 × £21.67 (exactly double)

## Diagnostic Steps

### Step 1: Check for Duplicate Subscriptions
1. Open the app
2. Look at the Dashboard list
3. **Question**: Do you see ONE subscription card or TWO?
   - If TWO cards: The subscription was saved twice (likely cause)
   - If ONE card: There's a calculation bug

### Step 2: Check Subscription ID
1. Tap the subscription to edit it
2. Note the subscription details
3. Close and re-open edit - does it show the same data?

### Step 3: Check Database Directly
Run this query to see how many subscriptions exist:

```dart
// In the app code, we can add debug logging to SubscriptionStatsLogic.calculate()
print('DEBUG: Processing ${subs.length} subscriptions');
for (final sub in subs) {
  print('  - ${sub.name}: £${sub.cost} ${sub.cycle.name}');
}
```

## Most Likely Causes (in order)

### 1. Duplicate Entry in Database (90% probability)
**Symptoms**: Two identical subscriptions saved
**Cause**: 
- Save button tapped twice quickly
- Race condition in form submission
- Test data generator created duplicate

**Fix**: Delete one of the duplicates

### 2. Calculation Running Twice (8% probability)  
**Symptoms**: Stats calculation executes twice on same data
**Cause**: 
- Provider rebuild issue
- Stats calculation called multiple times

**Fix**: Need to add debug logging to trace

### 3. Incorrect Multiplier (2% probability)
**Symptoms**: Using 8.67 instead of 4.33
**Cause**: Bug in weekly calculation

**Fix**: Check subscription_stats_logic.dart line 47

## Quick Test
1. Wipe all data
2. Add exactly ONE subscription: £5/week starting 01/01/26
3. Check breakdown - should show £21.67
4. If it shows £43.33, we have a calculation bug
5. If it shows £21.67, the original data had duplicates

## Current Code Reference
File: `lib/features/analysis/logic/subscription_stats_logic.dart`
Line 47: `monthlyCost = sub.cost * 4.333333;`

This is mathematically correct:
- 52 weeks per year ÷ 12 months = 4.333333 weeks per month
- £5 × 4.333333 = £21.6666... ≈ £21.67
