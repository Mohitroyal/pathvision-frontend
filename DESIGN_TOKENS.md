# JARVIS OS - Design Token Reference

## 🎨 Complete Design System Reference

### Color Hierarchy

#### Backgrounds (Neutral Dark)
```
bgPrimary       #030303   - Main app background
bgSecondary     #0A0A0A   - Alternative background
bgTertiary      #111111   - Card/surface background
bgQuaternary    #181818   - Input/hover state
bgQuint         #1F1F1F   - Deep layer
```

#### Gold Accent System
```
gold            #C9A84C   - Primary accent (100%)
goldLight       #E8C96D   - Secondary accent (80%)
goldLighter     #F5DFA0   - Tertiary accent (60%)
goldDim         rgba(201,168,76,0.12)  - Subtle background
goldGlow        rgba(201,168,76,0.3)   - Shadow/glow
goldLine        rgba(201,168,76,0.22)  - Border color
```

#### Text Colors
```
textPrimary     #E8E0D0   - Main text (100% opacity)
textMid         #A09888   - Secondary text (80%)
textDim         #6A6058   - Tertiary/subtitle (60%)
```

#### Status Colors
```
okColor         #1E8A4A   - Success/positive
incomeLight     #27AE60   - Income (green tone)
warnColor       #D4830A   - Warning/attention
expenseLight    #E74C3C   - Expense/negative (red tone)
dangerColor     #C0392B   - Critical/error (dark red)
blueColor       #2471A3   - Secondary action
debtOwe         #8E44AD   - Owe debt (purple)
debtOwed        #2471A3   - Owed to us (blue)
purpleColor     #9B59B6   - Priority/highlight
```

#### Income/Expense Variants (with transparency)
```
incomeDim       rgba(39,174,96,0.12)    - Income background
incomeLine      rgba(39,174,96,0.25)    - Income border
expenseDim      rgba(231,76,60,0.1)     - Expense background
expenseLine     rgba(231,76,60,0.25)    - Expense border
```

---

## 📝 Typography System

### Font Families
```
Orbitron        - Headings & titles (geometric, futuristic)
Rajdhani        - Body text & labels (clean, readable)
JetBrainsMono   - Data & code (monospace, technical)
```

### Type Scales

#### Headings (Orbitron)
```
headlineLarge       48px, weight 900, spacing 2px
headlineMedium      32px, weight 900, spacing 1.5px
headlineSmall       20px, weight 700, spacing 1px
```

#### Titles (Mixed)
```
titleLarge          16px, Orbitron, weight 700, spacing 1.5px, gold
titleMedium         14px, Rajdhani, weight 600, primary
titleSmall          11px, JetBrainsMono, weight 600, gold
```

#### Body (Rajdhani)
```
bodyLarge           14px, weight 500, primary
bodyMedium          12px, weight 500, textMid
bodySmall           11px, weight 400, textDim
```

#### Labels (JetBrainsMono)
```
labelLarge          11px, weight 600, gold, spacing 1.2px
labelMedium         9px, weight 500, textDim, spacing 0.5px
labelSmall          8px, weight 400, textDim, spacing 0.3px
```

---

## 📏 Spacing System (8px Grid)

### Increments
```
xs      4px     - Micro gaps, icon padding
sm      8px     - Small margins, tight spacing
md      12px    - Medium (default), padding
lg      16px    - Large, section spacing
xl      20px    - Extra large, major spacing
xxl     24px    - 2x large, hero spacing
xxxl    32px    - 3x large, page padding
```

### Common Patterns
```
Card padding        16px (lg)
List item gap       12px (md)
Section margin      24px (xxl)
Component gap       8-12px (sm-md)
Page padding        32px (xxxl) desktop, 16px (lg) mobile
Input height        40-48px with 12px padding
Button height       44px (touch target)
```

---

## 🎯 Border & Radius

### Border Radius
```
xs      2px     - Subtle rounding (minimal)
sm      4px     - Small buttons, 
md      6px     - Default (cards, inputs)
lg      12px    - Large elements, bottom sheets
xl      24px    - Extra large (avatars, orbs)
```

### Border Widths
```
Hair    0.8px   - Default borders
Thin    1px     - Focus states
Medium  1.5px   - Device frames
Thick   2px     - Accent lines
```

### Border Styles
```
goldLine        gradient left → transparent
accentLine      3px left bar with gradient
shadow          blur 12px, spread 2px, goldGlow
```

---

## 🌈 Shadow System

### Shadow Definitions
```
goldGlowShadow    blur: 12px, spread: 2px, color: goldGlow
mediumShadow      blur: 8px, spread: 0, shadow: 4px down
smallShadow       blur: 4px, spread: 0, shadow: 2px down
```

### Application
- **Orbs**: goldGlowShadow
- **Cards**: No shadow (border only)
- **Buttons**: mediumShadow on hover
- **Dropdowns**: mediumShadow

---

## 🎨 Component Theming

### Card Variants
```
JarvisCard          white border, bgTertiary
JarvisCardAccent    3px gold left bar
IncomeCard          green border, dark green bg gradient
ExpenseCard         red border, dark red bg gradient
```

### Chip Types
```
ChipType.ok         green bg/text
ChipType.warn       yellow bg/text
ChipType.danger     red bg/text
ChipType.blue       blue bg/text
ChipType.gold       gold bg/text
ChipType.income     green bg/text
ChipType.expense    red bg/text
ChipType.purple     purple bg/text
```

### Button Styles
```
Primary         gold gradient, black text
Secondary       transparent, gold border
Danger          red background
Success         green background
```

---

## 📱 Responsive Breakpoints

### Mobile First
```
sm: 0px         - Base mobile
md: 600px       - Tablet portrait
lg: 900px       - Tablet landscape / desktop
xl: 1200px      - Large desktop
2xl: 1536px     - Extra large desktop
```

### Layout Changes at 900px
```
< 900px:
- Single column
- Bottom navigation
- Full-width cards
- Sidebar hidden

≥ 900px:
- 2-3 column layout
- Left sidebar (200px)
- Multi-column grid
- Expanded content
```

---

## 🎬 Animation Tokens

### Durations
```
fast        200ms
normal      300ms
slow        500ms
verySlow    1000ms
```

### Curves
```
easeIn      accelerating from zero velocity
easeOut     decelerating to zero velocity
easeInOut   acceleration then deceleration
linear      constant velocity
```

### AI Orb
```
duration    3000ms
curve       easeInOut
scale       1.0 → 1.05 → 1.0
```

---

## 📊 KPI Styling

### KPI Card Structure
```
┌─────────────────────────┐
│ [icon]            Value │  (24px, gold)
│                         │
│ 4px gap                 │
│                         │
│ LABEL (8px, dim)        │
└─────────────────────────┘
  ▔ gold gradient line
```

### KPI Row
```
[KPI 1] --- gap --- [KPI 2] --- gap --- [KPI 3]
Width: 140px each
Gap: 16px (lg)
Horizontal scroll on mobile
```

---

## 🎯 Spacing Grid Visualization

```
Micro spacing (4px)
├─ Icon padding inner
├─ Tight component gaps
└─ Minimal visual separation

Small spacing (8px)
├─ Navigation item padding
├─ Button-to-button gaps
└─ Compact list items

Medium spacing (12px)
├─ Card padding default
├─ List item separation
└─ Input field padding

Large spacing (16px)
├─ Section margins
├─ Major component gaps
└─ Sidebar width units

Extra large (20px)
├─ Header margins
└─ Section breaks

2x large (24px)
├─ Hero spacing
├─ Major page sections
└─ Mobile section padding

3x large (32px)
├─ Page padding (desktop)
├─ Maximum horizontal margins
└─ Full-page gutters
```

---

## 🔤 Font Weight Mapping

```
Orbitron:
  regular    = 400
  medium     = 500
  semibold   = 600
  bold       = 700
  900        = 900 (ultra black)

Rajdhani:
  light      = 300
  regular    = 400
  medium     = 500
  semibold   = 600
  bold       = 700

JetBrainsMono:
  light      = 300
  regular    = 400
  medium     = 500
  semibold   = 600
```

---

## 🎨 Color Application Examples

### Finance Screen
```
Income Card     green (incomeLight) for values, borders
Expense Card    red (expenseLight) for values, borders
Progress bar    gold gradient
```

### Task Screen
```
Completed       gold checkmark + strikethrough
Pending         gold border + icon
High Priority   gold/red indicator
```

### AI Screen
```
Orb glow        goldGlow shadow
Message box     bgQuaternary (input), bgTertiary (ai)
Button          gold gradient
```

---

## ✨ Visual Hierarchy

### Primary Elements
- Headings: Orbitron 48px gold gradient
- Major CTAs: Gold background
- Key metrics: Gold text, large font

### Secondary Elements
- Subtitles: Rajdhani 12px textMid
- Secondary CTAs: Gold border
- Section headers: Orbitron 14px gold

### Tertiary Elements
- Captions: JetBrainsMono 8px textDim
- Hints: Rajdhani 11px textDim
- Meta data: JetBrainsMono 9px textDim

---

## 🎯 Interactive States

### Hover
- Cards: 1px gold border (from 0.8px)
- Buttons: Brightness +10%
- Links: Underline appears

### Focus
- Inputs: 1px gold border
- Buttons: 2px gold border
- Keyboard nav: Gold outline

### Active
- Selected: Gold background
- Pressed: Brightness -10%
- Toggle: Gold accent

### Disabled
- Opacity: 50%
- Color: textDim
- Cursor: not-allowed

---

## 📐 Composition Rules

### Cards
```
Min padding     12px
Max width       none (responsive)
Border          0.8px goldLine
Radius          6px
Shadow          none
Content gap     12px minimum
```

### Forms
```
Label size      9px, spacing 1.5px
Input height    40px minimum
Input padding   12px horizontal, 8px vertical
Gap between     12px
Select same as  input
```

### Lists
```
Item padding    12px
Item margin     0
Gap between     8px
Divider         0.8px golden gradient
```

---

## 🎨 Theme Extension Points

To customize, modify:

```dart
// Change primary accent
lib/theme/jarvis_colors.dart
const Color gold = Color(0xFFYOUR_COLOR);

// Change typography
lib/theme/jarvis_theme.dart
headlineSmall: GoogleFonts.orbitron(
  fontSize: YOUR_SIZE,
)

// Change spacing
lib/theme/jarvis_theme.dart
class Spacing {
  static const double md = 16; // was 12
}

// Change shadows
lib/theme/jarvis_theme.dart
class JarvisShadows {
  static List<BoxShadow> customShadow = [...]
}
```

---

This design system ensures:
- ✅ Visual consistency across all screens
- ✅ Accessibility (color contrast, touch targets)
- ✅ Performance (minimal rendering, reusable tokens)
- ✅ Maintainability (centralized definitions)
- ✅ Scalability (easy to extend and customize)
