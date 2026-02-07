# 08. Navigation Map (GoRouter)

> **Philosophy**: "Flat & Fast". Avoid deep nesting. Use Modals for tasks, Pushes for details.

## 1. Visual Navigation Diagram
```mermaid
graph TD
    Splash[Splash Screen] --> Check{First Run?}
    Check -->|Yes| Onboarding[Onboarding Wizard]
    Check -->|No| Dashboard[Dashboard (Home)]
    
    Onboarding -->|Complete| Dashboard
    
    Dashboard -->|Tap FAB| AddSub[Add Subscription (Modal)]
    Dashboard -->|Tap List Item| EditSub[Edit Subscription (Modal)]
    Dashboard -->|Tap Settings Icon| Settings[Settings Screen]
    
    AddSub -->|Save| Dashboard
    EditSub -->|Save/Delete| Dashboard
```

## 2. Route Definitions

| Route Name | Path | Type | Params | Transition | Parent |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `splash` | `/` | Screen | - | Fade | Root |
| `onboarding` | `/onboarding` | Screen | - | Slide Right | Root |
| `dashboard` | `/home` | Screen | - | Fade | Root |
| `settings` | `/settings` | Screen | - | Slide Left | Dashboard |
| `add_subscription` | `/add` | Modal | `categoryId` (opt) | BottomSheet | Dashboard |
| `edit_subscription` | `/edit/:id` | Modal | `id` (required) | BottomSheet | Dashboard |

## 3. Deep Linking Schema
*   `subsentry://home` -> Dashboard
*   `subsentry://add?cat=netflix` -> Add Screen pre-filled
*   `subsentry://sub/:id` -> Edit Screen for specific sub

## 4. App Shell Logic
*   **Scaffold**: The `Dashboard` wraps the main content.
*   **Global Elements**:
    *   `FloatingActionButton`: Persistent on Dashboard.
    *   `SnackBar`: Global overlay for "Saved!" messages.
