# 06. Visual Design System ("Financial Zen")

> **Design Anchor**: "The clarity of a Swiss train timetable meets the warmth of a premium notebook."

## 1. Color Palette
*A focused, matte palette designed for high data legibility and calm confidence.*

### 1.1 Primary Brand Colors
| Token | Hex | Role |
| :--- | :--- | :--- |
| `primary` | `#0F4C5C` | **Midnight Teal**. The "Trust" color. Used for active states, branding, and high-level charts. |
| `primaryContainer` | `#D8E9EC` | Very pale teal background for active branding elements. |
| `secondary` | `#E36414` | **Burnt Coral**. The "Action/Alert" color. Used for FAB, trial warnings, and negative cashflow. |
| `secondaryContainer` | `#FADECD` | Pale coral for alerts backgrounds. |

### 1.2 Category Colors (Functional)
*Used for the Donut Chart and Icon Backgrounds.*
| Category | Hex | Meaning |
| :--- | :--- | :--- |
| `cat_entertainment` | `#9A031E` | Ruby Red (Netflix, Disney) |
| `cat_utilities` | `#FB8B24` | Safety Orange (Energy, Broadband) |
| `cat_software` | `#00A896` | Persian Green (Spotify, Adobe) |
| `cat_finance` | `#5F0F40` | Tyrian Purple (Banking, Interest) |
| `cat_gym` | `#02C39A` | Mint (Health, Fitness) |
| `cat_other` | `#8D99AE` | Cool Grey |

### 1.3 Neutrals (The Canvas)
| Token | Hex (Light) | Hex (Dark) | Usage |
| :--- | :--- | :--- | :--- |
| `background` | `#FAFAFA` | `#121212` | Main app background (Off-white / Deep Black). |
| `surface` | `#FFFFFF` | `#1E1E1E` | Card backgrounds. |
| `outline` | `#E0E0E0` | `#404040` | Dividers and borders. |
| `textPrimary` | `#1A1A1A` | `#ECECEC` | Headings, Amounts. |
| `textSecondary`| `#757575` | `#A0A0A0` | Dates, Subtitles. |

---

## 2. Typography
*Pairing: Geometric Header + Humanist Body.*

### 2.1 Font Families
*   **Headings**: `Outfit` (Google Font).
    *   Why: Geometric, modern, high x-height. Feels like a fintech product.
*   **Body**: `Inter` (Google Font).
    *   Why: Unbeatable number legibility. Crucial for prices/dates.

### 2.2 Type Scale
| Style | Size | Weight | Letter Spacing | Usage |
| :--- | :--- | :--- | :--- | :--- |
| `Display Large` | 32sp | Bold (700) | -1.0 | "Total: £145" |
| `Headline Medium`| 24sp | SemiBold (600)| -0.5 | Page Titles |
| `Title Medium` | 18sp | Medium (500) | 0 | Card Titles (Netflix) |
| `Body Large` | 16sp | Regular (400) | 0.5 | Form Inputs |
| `Body Medium` | 14sp | Regular (400) | 0.25 | Dates, List details |
| `Label Small` | 11sp | Bold (700) | 0.5 | Caps Labels (UPCOMING) |

---

## 3. Shape & Spacing (The "Rhythm")

### 3.1 Spacing Scale (8pt Grid)
*   `xs`: 4dp (Tight grouping)
*   **`s`: 8dp** (Standard icon gap)
*   `m`: 16dp (Standard padding)
*   `l`: 24dp (Section spacing)
*   `xl`: 32dp (Fab spacing)
*   `xxl`: 48dp (Bottom sheet top pad)

### 3.2 Border Radius
*   **Buttons**: `12dp` (Modern, accessible).
*   **Cards**: `16dp` (Friendly).
*   **Bottom Sheet**: `24dp` (Top corners only).

### 3.3 Elevation (Shadows)
*Avoid standard material hard shadows. Use diffuse colored shadows.*
*   **Card Shadow**: `0px 4px 12px rgba(15, 76, 92, 0.08)` (Tinted with Primary).
*   **Floating Action Button**: `0px 8px 16px rgba(227, 100, 20, 0.3)` (Tinted with Secondary).

---

## 4. Components

### 4.1 Buttons
*   **Primary (FAB/Save)**:
    *   Bg: `primary` (Teal). Text: `white`.
    *   Height: 56dp.
    *   Haptic: Medium Impact on Tap.
*   **Secondary (Cancel)**:
    *   Bg: Transparent. Text: `textSecondary`.

### 4.2 Subscription Card
*   **Container**: `surface` color, `16dp` radius.
*   **Layout**:
    *   Left: 40dp Circle (`category color` @ 15% opacity) with Icon (`category color`).
    *   Center: Title (`Title Medium`), Date (`Body Medium` + `textSecondary`).
    *   Right: Price (`Title Medium` + `Monospace` numerals).

### 4.3 Input Fields
*   **Style**: "Outlined" but with very subtle border.
*   **Normal**: Border `outline` (1dp). Bg `surface`.
*   **Focused**: Border `primary` (2dp). Bg `primaryContainer` @ 10%.
*   **Validation**: "Smart Check" icon appears on right when valid.
