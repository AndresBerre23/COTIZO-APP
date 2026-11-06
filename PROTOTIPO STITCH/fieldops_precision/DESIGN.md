---
name: FieldOps Precision
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#444651'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#757682'
  outline-variant: '#c5c5d3'
  surface-tint: '#4059aa'
  primary: '#00236f'
  on-primary: '#ffffff'
  primary-container: '#1e3a8a'
  on-primary-container: '#90a8ff'
  inverse-primary: '#b6c4ff'
  secondary: '#0051d5'
  on-secondary: '#ffffff'
  secondary-container: '#316bf3'
  on-secondary-container: '#fefcff'
  tertiary: '#00311f'
  on-tertiary: '#ffffff'
  tertiary-container: '#004a31'
  on-tertiary-container: '#27c38a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b6c4ff'
  on-primary-fixed: '#00164e'
  on-primary-fixed-variant: '#264191'
  secondary-fixed: '#dbe1ff'
  secondary-fixed-dim: '#b4c5ff'
  on-secondary-fixed: '#00174b'
  on-secondary-fixed-variant: '#003ea8'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-lg:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '600'
    lineHeight: 38px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  currency-display:
    fontFamily: JetBrains Mono
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 38px
  currency-md:
    fontFamily: JetBrains Mono
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 24px
  currency-sm:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is engineered for field contractors, site supervisors, and independent tradespeople operating in high-demand, variable physical environments. The aesthetic pairs industrial utility with fintech rigor: clean, resilient, and unapologetically functional.

The emotional core is operational confidence. Visual noise is aggressively eliminated so users can log micro-expenses, verify invoice disbursements, and inspect job cash flows in direct sunlight, often using one hand while wearing protective gear. 

The aesthetic leverages **High-Contrast Modernism with Industrial Tactility**:
- **Clarity under extreme lighting**: High luminance contrast across all actionable states to prevent washed-out interfaces under direct sunlight.
- **Instrument-grade hierarchy**: Large tabular monetary values that read like precision gauges rather than marketing displays.
- **Physical ergonomics**: Touch targets calibrated strictly to 48px+ touch envelopes, thumb-zone anchored primary inputs, and explicit card boundaries that divide dense project financial data into glanceable blocks.

## Colors

The palette is tuned specifically for outdoors readability, instant status recognition, and precise financial categorization.

- **Primary (`#1E3A8A`) & Interactive Blue (`#2563EB`)**: Anchor color for administrative hierarchy, active navigational states, primary CTA buttons, and verified invoice states.
- **Success / Revenue (`#10B981`)**: Signals collected payments, positive margins, signed work-orders, and balance inflows. Always paired with dark tabular text or high-contrast backgrounds to prevent green-washout in direct sunlight.
- **Destructive / Expenses / Alert (`#EF4444`)**: Applied to outgoing job costs, safety issues, overdue accounts receivable, and irreversible deletions.
- **Neutral Primary (`#1E293B`) & Neutral Muted (`#64748B`)**: Delivers deep, anti-glare legibility for transactional copy and structural clarity for labels without resorting to eye-straining pure `#000000`.
- **Canvas (`#F8F9FA`) & Surface (`#FFFFFF`) with Border (`#E2E8F0`)**: Forms an explicit multi-tiered surface system that remains visually separated even if device screen brightness auto-dims.

## Typography

The typographical foundation relies on **Inter** for all UI communication and narrative content, complemented by **JetBrains Mono** for monetary metrics, ledger balance amounts, purchase order codes, and units of measurement.

### Numerical Data & Tabular Rules
- All currency readouts, quantity balances, and timestamps must leverage tabular numerals (`font-feature-settings: "tnum"` in Inter, or native fixed-width spacing via JetBrains Mono). This ensures columns in budget tables and expense manifests remain strictly aligned across dynamically changing values.
- Positive financial indicators prepend an explicit `+` symbol; negative cash flows utilize a distinct minus `−` accompanied by semantic color.

### Mobile Legibility Safeguards
- Text sizes under 12px are prohibited for interactive items or primary financial data.
- Headers scale down conservatively on mobile devices to prevent wrapping critical currency totals into multiple lines.

## Layout & Spacing

The layout model is driven by a mobile-first, strict fluid grid optimized for rapid handheld interaction.

- **Mobile Viewport (360px - 599px)**: 4-column fluid grid, `16px` outer margins (`margin`), and `12px` column gutters (`gutter-mobile`). Visual containers stack vertically with fixed horizontal padding to maximize screen width for multi-entry receipt logs.
- **Tablet / In-Vehicle Mount (600px - 1023px)**: 8-column layout with `24px` outer margins (`margin-tablet`) and `16px` gutters. Enables side-by-side inspection of blueprints/invoices alongside the expense entry stream.
- **Ergonomic Safe Zones**: Critical actions (such as logging an expense or scanning a delivery ticket) must stay anchored within the bottom 40% of the viewport (the thumb comfort zone). Modals, numeric input pads, and quick-filter chips pin to the bottom edge with minimum 16px bottom padding above the OS home indicator.

## Elevation & Depth

Visual depth is achieved through **low-contrast borders combined with crisp, directional ambient shadows**. This prevents muddy blur gradients when screens are set to peak outdoor brightness.

- **Level 0 (Canvas Base)**: `#F8F9FA`. Non-elevated, clean, glare-reducing plane.
- **Level 1 (Card & Section Containers)**: `#FFFFFF` fill with a `1px solid #E2E8F0` border and subtle elevation: `0px 1px 3px rgba(30, 41, 59, 0.06), 0px 1px 2px rgba(30, 41, 59, 0.04)`.
- **Level 2 (Active Sheets, Popovers & Floating Keypads)**: `#FFFFFF` fill with `1px solid #CBD5E1` border and elevation: `0px 6px 16px -2px rgba(30, 41, 59, 0.10), 0px 3px 6px -1px rgba(30, 41, 59, 0.05)`.
- **Level 3 (Modal Alerts & Heavy Drawers)**: `#FFFFFF` with `0px 20px 25px -5px rgba(30, 41, 59, 0.15), 0px 8px 10px -6px rgba(30, 41, 59, 0.08)`.
- **High-Sun Border Rule**: Elevation shadows are never used alone to delineate containers; a defining border (`#E2E8F0` or `#CBD5E1`) is strictly required on every surface element.

## Shapes

The design system enforces a **Level 2 (Rounded)** shape rhythm (`0.5rem` / `8px` default radius). 

- Base UI components (inputs, card tiles, buttons, keypad cells) use `8px` (`0.5rem`) corner rounding. This delivers a modern, approachable feel while retaining an industrial, structural edge.
- Interactive modular chips and quick-status tags use a pill format (`9999px`) to create clear differentiation between actionable category tags and dense tabular cards.
- Bottom sheet drawer tops employ `16px` (`rounded-xl` / `1rem`) corner rounding on their top-left and top-right edges.

## Components

### Buttons
- **Touch Targets**: All buttons require a minimum visual height of 48px (52px preferred for primary actions) and a 48px minimum touch envelope.
- **Primary Button**: Solid `#1E3A8A` fill, `#FFFFFF` text (Inter, Semi-bold 16px). Active/Pressed state darkens to `#172554`. Focus ring: 3px `#2563EB` offset by 2px white.
- **Secondary / Action Button**: Solid `#2563EB` fill with white text for secondary task completion.
- **Outline / Utility Button**: `#FFFFFF` background, `1.5px solid #CBD5E1`, text `#1E293B`. Provides clear physical boundary on canvas.
- **Destructive Button**: Coral Red `#EF4444` background with pure `#FFFFFF` label.

### Form Inputs & Custom Numeric Keypad
- **Inputs**: 52px height, `#FFFFFF` background, `1px solid #CBD5E1` default border, `8px` border-radius. Active focus transitions to `2px solid #2563EB`. Label floats or sits above input at `12px` font size in `#64748B`.
- **Field Keypad for Micro-Expenses**: On-screen native keypad designed for swift one-hand expense logging. Key cells are organized in a 3x4 grid with a minimum key size of 64px x 56px, filled with `#FFFFFF`, separated by `8px` gaps on a `#F1F5F9` tray. Number labels render in `JetBrains Mono` 24px Semi-bold for instant recognition. Includes dedicated decimal (`.`) and backspace confirmation buttons.

### Cards
- **Finance Snapshot Cards**: Surface `#FFFFFF`, border `1px solid #E2E8F0`, corner radius `8px`, padded at `16px`. Header area cleanly divides the vendor/project name from the mono-spaced cash amount. 
- **Receipt & Invoice Cards**: Feature a left-hand 4px status bar (Emerald Green `#10B981` for paid/inflow, Coral Red `#EF4444` for outgoing expense, Slate Gray `#94A3B8` for draft/unapproved).

### Chips & Filter Tags
- **Selection Chips**: 36px height with 48px touch padding. Inactive state: `#F1F5F9` background, `#1E293B` text, `1px solid transparent`. Active state: `#1E3A8A` background, `#FFFFFF` text. Pill-shaped (`9999px`).

### Lists & Activity Feeds
- **Feed Rows**: Strict 60px minimum row height. Contains clear horizontal border separators (`1px solid #F1F5F9`). Left side contains category icon tile (36x36px with `6px` radius); right side contains JetBrains Mono aligned currency text and timestamp.

### Checkboxes & Radios
- Minimum dimension `22x22px` within an interactive area of `48x48px`. Checkbox stroke is 2px solid `#2563EB` when checked, filled with `#2563EB` and white tick icon. Unchecked: `2px solid #94A3B8`.