# 06b. App Icon Design ("The Cycle Sentry")

> **Design Anchor**: "A high-precision watch dial meets a financial safety shield."

## 1. Design Direction Summary
*   **Aesthetic Name**: Industrial Utilitarian Minimal
*   **DFII Score**: 13 (Impact: 4, Fit: 5, Feasibility: 5, Performance: 4 - Risk: 1)
*   **Inspiration**: Precision instrument dials (Swiss watches, cockpit gauges, modern radar interfaces).

## 2. Icon Concept
The icon represents **SubSentry** through three geometric elements:
1.  **The Cycle**: An interrupted circular ring (75% circumference) representing the recurring nature of subscriptions.
2.  **The Sentry**: A vertical, high-contrast needle or "hand" that marks the current moment or a bill coming due.
3.  **The Void**: The break in the circle represents the ability to "cut" unwanted costs.

## 3. Color Palette
Used from `docs/06_VISUAL_DESIGN.md`:
1.  **Background**: `#0F4C5C` (Midnight Teal) — Conveys trust, security, and financial depth.
2.  **Primary Foreground**: `#FFFFFF` (White) — Used for the main cycle loop for maximum contrast.
3.  **Accent**: `#E36414` (Burnt Coral) — Used for the "Sentry Needle" to draw immediate attention.

## 4. Technical Specifications

### 4.1 Master Asset
*   **Size**: 1024 x 1024 px.
*   **Format**: SVG (for design), PNG (for submission).
*   **Grid**: 8pt geometric grid alignment.

### 4.2 Android Adaptive Icon
*   **Background Layer**: Solid fill of `#0F4C5C`.
*   **Foreground Layer**:
    *   White cycle loop (thickness: 80px).
    *   Burnt Coral needle (centered horizontally, pointing to top-right gap).
    *   **Safe Zone**: All foreground elements kept within the central 66% (676px) circle to prevent clipping during system animations (squircle, circle, teardrop transforms).

### 4.3 iOS Icon
*   **Format**: Flat PNG.
*   **Background**: Solid `#0F4C5C`.
*   **Corners**: Sharp in source (iOS system applies the 160px radius mask).
*   **Transparency**: No alpha channel permitted.

### 4.4 Legibility & Scaling
*   **29x29pt (iOS Settings)**: The simple contrast between the thick loop and the sharp coral needle ensures the "hand on a dial" metaphor remains readable.
*   **48dp (Android Launcher)**: High-contrast palette ensures visibility against varied wallpapers.

## 5. Differentiation
| Feature | SubSentry Icon | Competitor Icons (Typical) |
| :--- | :--- | :--- |
| **Metaphor** | Monitoring Tool (Watch/Radar) | Storage (Wallet/Safe) or Symbol ($/£) |
| **Geometry** | Precise, Interrupted Asymmetry | Symmetrical or Skeuomorphic |
| **Palette** | Matte Midnight Teal & Burnt Coral | "Bank Blue" or Green/Gold |

## 6. Implementation Plan (Phase 5)
1.  Generate SVG paths for the interrupted ring and needle.
2.  Export 1024px PNG for iOS.
3.  Export separate `foreground.png` and `background.png` (or XML vectors) for Android.
4.  Finalize with `flutter_launcher_icons` configuration in `pubspec.yaml`.
