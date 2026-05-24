---
name: Kinetic Dark
colors:
  surface: '#121415'
  surface-dim: '#121415'
  surface-bright: '#38393a'
  surface-container-lowest: '#0c0e0f'
  surface-container-low: '#1a1c1d'
  surface-container: '#1e2021'
  surface-container-high: '#282a2b'
  surface-container-highest: '#333536'
  on-surface: '#e2e2e3'
  on-surface-variant: '#c4c9ac'
  inverse-surface: '#e2e2e3'
  inverse-on-surface: '#2f3132'
  outline: '#8e9379'
  outline-variant: '#444933'
  surface-tint: '#abd600'
  primary: '#ffffff'
  on-primary: '#283500'
  primary-container: '#c3f400'
  on-primary-container: '#556d00'
  inverse-primary: '#506600'
  secondary: '#c6c6c9'
  on-secondary: '#2f3133'
  secondary-container: '#454749'
  on-secondary-container: '#b4b5b7'
  tertiary: '#ffffff'
  on-tertiary: '#2f3133'
  tertiary-container: '#e2e2e5'
  on-tertiary-container: '#636467'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#c3f400'
  primary-fixed-dim: '#abd600'
  on-primary-fixed: '#161e00'
  on-primary-fixed-variant: '#3c4d00'
  secondary-fixed: '#e2e2e5'
  secondary-fixed-dim: '#c6c6c9'
  on-secondary-fixed: '#1a1c1e'
  on-secondary-fixed-variant: '#454749'
  tertiary-fixed: '#e2e2e5'
  tertiary-fixed-dim: '#c6c6c9'
  on-tertiary-fixed: '#1a1c1e'
  on-tertiary-fixed-variant: '#454749'
  background: '#121415'
  on-background: '#e2e2e3'
  surface-variant: '#333536'
typography:
  display-lg:
    fontFamily: Montserrat
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Montserrat
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Montserrat
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 40px
---

## Brand & Style

The design system is engineered for high-performance fitness environments, targeting athletes and enthusiasts who value precision and momentum. The brand personality is energetic, disciplined, and forward-moving. By utilizing a high-contrast dark aesthetic, the UI minimizes distractions and focuses the user’s attention on their data and progress.

The design style is a hybrid of **Modern Corporate** and **High-Contrast Bold**. It leverages the depth of a dark charcoal canvas to make functional elements "pop" with neon accents. The emotional response should be one of immediate readiness—evoking the feeling of a premium, dimly lit gym where the only thing that matters is the workout at hand.

- **Minimalism:** Lean interfaces that prioritize telemetry and action over decorative elements.
- **Modernity:** Clean lines and purposeful use of whitespace (or "darkspace") to ensure the UI feels expansive rather than cramped.
- **Energy:** Strategic use of "Electric Lime" to guide the eye toward primary actions and success states.

## Colors

The palette is rooted in a "Deep Charcoal" base to provide a sophisticated, low-strain background for late-night or early-morning training sessions.

- **Primary (Electric Lime):** Used exclusively for high-priority interactions, progress bars, and active states. It represents energy and completion.
- **Secondary (Deep Charcoal):** The foundation of the UI. Used for the main background to create a sense of focus.
- **Tertiary (Graphite):** Used for card surfaces and elevated containers to create subtle depth without breaking the dark-mode immersion.
- **Neutral:** A range of cool grays used for secondary text and icons, ensuring a clear hierarchy against the vibrant primary color.

## Typography

The typography strategy uses **Montserrat** for all headlines to project a bold, athletic, and authoritative voice. Its geometric construction mirrors the precision of fitness tracking. For body copy and data-heavy displays, **Inter** is utilized for its exceptional legibility and systematic feel.

- **Headlines:** Use heavy weights (700+) and tighter letter spacing for a compact, powerful look.
- **Labels:** Small caps or wide letter spacing are used for "Label LG" to denote categories and metadata without competing with primary data points.
- **Data Visualization:** Numbers should prioritize weight and clarity, often using Montserrat to match the impact of headlines.

## Layout & Spacing

This design system employs a **fluid grid** model based on an 8px square rhythm to ensure mathematical harmony across all components.

- **Mobile:** A 4-column grid with 20px side margins. Content cards usually span the full width to maximize readability of performance charts.
- **Desktop/Tablet:** A 12-column grid with a max-width of 1280px. Data dashboards use a "Bento Box" layout, grouping related metrics into distinct cards.
- **Spacing Philosophy:** Use generous "xl" spacing between major sections to prevent the dark UI from feeling claustrophobic. Use "xs" and "sm" for internal card padding to keep data-dense information tightly grouped.

## Elevation & Depth

In this dark-mode centric system, depth is achieved through **Tonal Layering** rather than traditional shadows. 

- **Level 0 (Base):** Deep Charcoal (#1A1C1E). Used for the global background.
- **Level 1 (Cards/Surfaces):** Graphite (#2F3133). Used for content containers. This slight lift is enough to define edges in a dark environment.
- **Level 2 (Modals/Popovers):** Lightened Graphite with a very subtle 1px border (#FFFFFF with 10% opacity) to define boundaries against Level 1.
- **Active State:** A subtle "Electric Lime" outer glow (5-10% opacity) can be used for the current active workout card or selected navigation item to simulate a "neon pulse" effect.

## Shapes

The shape language is **Rounded (Level 2)**. This softens the aggressive nature of the high-contrast color palette, making the app feel user-friendly and approachable despite its professional-grade performance focus.

- **Standard Elements:** Buttons and input fields use a 0.5rem (8px) radius.
- **Containers:** Large dashboard cards use `rounded-lg` (1rem) to create a distinct, modular look.
- **Interactive Indicators:** Progress rings and toggle switches should remain fully circular (pill-shaped) to represent the continuity of a fitness journey.

## Components

### Buttons
- **Primary:** Electric Lime background with Deep Charcoal text. High-impact, used for "Start Workout" or "Save."
- **Secondary:** Transparent with a 2px Electric Lime border. Used for "Add Exercise" or "View History."
- **Tertiary:** Ghost style, white text with no background.

### Cards
- Dashboard cards should have a subtle 1px border in a slightly lighter shade of gray to ensure separation on low-quality screens. 
- Headers within cards should use the `label-lg` typography style.

### Input Fields
- Dark backgrounds (Level 2 depth) with a bottom-only border that turns Electric Lime on focus. 
- Error states should use a vibrant Coral instead of the Primary color to ensure immediate recognition.

### Data Visualization
- **Progress Rings:** Use a thick stroke for the Primary color and a low-opacity version of the same color for the "track."
- **Line Charts:** Use Electric Lime for the trend line with a subtle gradient fill underneath to provide a sense of volume and "growth."

### Chips/Tags
- Used for workout categories (e.g., "Strength," "Cardio"). These should be small, high-radius (pill) shapes with low-opacity fills of the primary color.