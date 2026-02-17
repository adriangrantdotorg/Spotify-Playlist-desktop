---
name: futuristic-dark-ui
description: Create stunning futuristic, dark-themed interfaces for mobile, web, and Mac desktop apps. Combines the Anti-AI-Slop philosophy, structured UX/accessibility rigor, and design intelligence tooling with a specialized sci-fi/cyberpunk/neo-noir aesthetic. Produces production-grade React, HTML/CSS, or SwiftUI-style code with bold dark palettes, sophisticated animations, and cross-platform design consistency.
license: MIT
---

# Futuristic Dark UI Skill

Create breathtaking, futuristic dark-themed interfaces across **mobile**, **web**, and **Mac desktop** platforms. Every output should feel like it belongs in a premium sci-fi cockpit, a cyberpunk dashboard, or a next-gen operating system — never generic, never flat, never boring.

---

## Core Philosophy: Anti-AI Slop

Claude (and all AI agents) are capable of extraordinary creative work, yet often default to safe, generic patterns. This skill **MANDATES** breaking those patterns.

- **AVOID**: Inter, Roboto, Arial, system fonts, purple-on-white gradients, cookie-cutter SaaS layouts, emojis as icons.
- **MANDATE**: Unique typography, context-specific dark color schemes, intentional motion, unexpected spatial composition, and production-grade functional code.

Every output must pass the "screenshot test" — if someone saw a screenshot, they should immediately know this was **designed**, not generated.

---

## Design Thinking Process

Before coding, understand the context and commit to a BOLD aesthetic direction:

1. **Purpose**: What problem does this interface solve? Who uses it?
2. **Tone**: Pick a sub-genre from the table below and commit fully — no half measures.
3. **Intelligence**: Use the Design Intelligence Tool (below) to gather palettes, fonts, and UX data. **CRITICAL: Filter all results through the Anti-AI Slop lens.** If a tool suggests "Inter" or "Roboto", IGNORE it and pick a distinctive alternative.
4. **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?
5. **Platform**: Which target(s) — mobile, web, desktop — and adapt density, interaction, and layout accordingly.

---

## Design Intelligence Tool

Use the internal search tool to gather palettes, font pairings, and UX guidelines before building.

```bash
# Generate a complete design system
python scripts/search.py "<product_type> <industry> <keywords>" --design-system

# Search specific domains (style, typography, color, ux, chart, landing)
python scripts/search.py "<keyword>" --domain <domain>

# Get stack-specific guidelines (html-tailwind, react, nextjs, shadcn, etc.)
python scripts/search.py "<keyword>" --stack <stack_name>
```

**CRITICAL**: You MUST filter all results through the Anti-AI Slop lens. If the tool suggests generic fonts or common palettes, override with distinctive alternatives from this skill's typography and color sections.

---

## Aesthetic Sub-Genres (Choose per project)

| Style                      | Vibe                                  | Key Elements                                                       |
| -------------------------- | ------------------------------------- | ------------------------------------------------------------------ |
| **Cyberpunk Neon**         | Electric, gritty, Blade Runner        | Neon cyan/magenta/hot pink glows, scanlines, distortion effects    |
| **Neo-Noir Tech**          | Sophisticated, moody, Minority Report | Subtle blue/violet accents, frosted glass, precision typography    |
| **Void Minimal**           | Ultra-clean, Apple-meets-void         | Near-black monotone, single accent color, extreme whitespace       |
| **HUD/Tactical**           | Military/aerospace, data-dense        | Grid overlays, mono fonts, status indicators, radar-style elements |
| **Cosmic Luxe**            | Premium, deep space, luxury           | Gradient nebulas, gold/platinum accents, organic curves            |
| **Synthwave Retro-Future** | 80s retro meets modern UI             | Chrome gradients, sunset palettes, grid floors, retro fonts        |

_Commit to ONE direction and execute it fully._

---

## Color System

### Base Palette (Always start here)

```css
:root {
  /* Depths */
  --void: #000000;
  --abyss: #050508;
  --deep: #0a0a0f;
  --surface: #111118;
  --elevated: #1a1a24;
  --raised: #222230;
  --subtle: #2a2a3a;

  /* Text Hierarchy */
  --text-primary: #e8e8f0;
  --text-secondary: #8888a0;
  --text-tertiary: #555570;
  --text-ghost: #333348;

  /* Borders & Dividers */
  --border-subtle: rgba(255, 255, 255, 0.04);
  --border-light: rgba(255, 255, 255, 0.08);
  --border-medium: rgba(255, 255, 255, 0.12);

  /* Semantic Status */
  --status-success: #00ff88;
  --status-warning: #f5a623;
  --status-error: #ff3366;
  --status-info: #3b82f6;
}
```

### Accent Palettes (Pick one primary, one secondary)

**Cyan Circuit** (Default futuristic)

```css
--accent-primary: #00f0ff;
--accent-glow: rgba(0, 240, 255, 0.15);
--accent-dim: #00899a;
```

**Neon Magenta**

```css
--accent-primary: #ff00aa;
--accent-glow: rgba(255, 0, 170, 0.15);
--accent-dim: #8a005c;
```

**Electric Violet**

```css
--accent-primary: #7c3aed;
--accent-glow: rgba(124, 58, 237, 0.15);
--accent-dim: #4c1d95;
```

**Solar Gold**

```css
--accent-primary: #f5a623;
--accent-glow: rgba(245, 166, 35, 0.12);
--accent-dim: #8a5a00;
```

**Matrix Green**

```css
--accent-primary: #00ff88;
--accent-glow: rgba(0, 255, 136, 0.12);
--accent-dim: #008844;
```

**Arctic Blue**

```css
--accent-primary: #3b82f6;
--accent-glow: rgba(59, 130, 246, 0.12);
--accent-dim: #1e40af;
```

---

## Typography

### Font Stacks (import from Google Fonts or CDN)

**Primary Choices** — Use ONE display + ONE body:

| Role            | Font Options                                                        | Vibe                  |
| --------------- | ------------------------------------------------------------------- | --------------------- |
| Display/Headers | `Orbitron`, `Exo 2`, `Rajdhani`, `Michroma`, `Audiowide`, `Oxanium` | Geometric, tech       |
| Display/Headers | `Syne`, `Unbounded`, `Chakra Petch`, `Bruno Ace`                    | Bold, futuristic      |
| Body            | `JetBrains Mono`, `IBM Plex Mono`, `Fira Code`                      | Mono/technical        |
| Body            | `DM Sans`, `Outfit`, `Manrope`, `Plus Jakarta Sans`                 | Clean, modern         |
| Body            | `Geist`, `Satoshi` (via CDN)                                        | Ultra-modern, premium |

### Typography Rules

- **NEVER** use: Inter, Roboto, Arial, Helvetica, system-ui as primary fonts
- Headers: ALL-CAPS or mixed with generous `letter-spacing: 0.05em–0.15em`
- Body: `font-size: 14px–16px`, `line-height: 1.5–1.7`
- Use `font-feature-settings: 'ss01', 'cv01'` for stylistic alternates when available
- Number displays: Use tabular figures (`font-variant-numeric: tabular-nums`)

---

## Professional UI Rules

| Rule                    | Do                                                                        | Don't                                               |
| ----------------------- | ------------------------------------------------------------------------- | --------------------------------------------------- |
| **Icons**               | Use SVG icon libraries (Lucide, Heroicons, Simple Icons, Phosphor)        | Use emojis (🎨 🚀 ⚙️) as UI icons — ever            |
| **Typography**          | Import beautiful, distinctive Google/Custom fonts                         | Use Inter, Roboto, Arial, system fonts              |
| **Hover States**        | Stable transitions: color, opacity, shadow, border-color, glow            | Scale transforms that shift layout or push siblings |
| **Cursor**              | Add `cursor: pointer` to ALL clickable/interactive elements               | Leave default cursor on buttons, links, or cards    |
| **Contrast**            | Minimum 4.5:1 ratio for body text; 3:1 for large text/UI elements         | Low-contrast "aesthetic" text that's unreadable     |
| **Focus States**        | Visible `:focus-visible` rings on all interactive elements (keyboard nav) | Removing `:focus` outlines without a replacement    |
| **Loading States**      | Skeleton screens, shimmer, or subtle pulse animations                     | Empty space or spinners with no context             |
| **Spatial Composition** | Asymmetry, overlap, diagonal flow, grid-breaking elements                 | Cookie-cutter centered layouts with uniform padding |

---

## Visual Effects Toolkit

### Glassmorphism (Primary surface treatment)

```css
.glass-panel {
  background: rgba(255, 255, 255, 0.03);
  backdrop-filter: blur(20px) saturate(150%);
  -webkit-backdrop-filter: blur(20px) saturate(150%);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 16px;
}

.glass-panel-elevated {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(40px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.08);
  box-shadow:
    0 8px 32px rgba(0, 0, 0, 0.4),
    inset 0 1px 0 rgba(255, 255, 255, 0.05);
}
```

### Neon Glow Effects

```css
.neon-text {
  color: var(--accent-primary);
  text-shadow:
    0 0 7px var(--accent-glow),
    0 0 20px var(--accent-glow),
    0 0 42px var(--accent-glow);
}

.neon-border {
  border: 1px solid var(--accent-primary);
  box-shadow:
    0 0 5px var(--accent-glow),
    inset 0 0 5px var(--accent-glow);
}

.neon-button {
  background: transparent;
  border: 1px solid var(--accent-primary);
  color: var(--accent-primary);
  cursor: pointer;
  box-shadow: 0 0 15px var(--accent-glow);
  transition: all 0.25s ease;
}
.neon-button:hover {
  background: var(--accent-glow);
  box-shadow:
    0 0 25px var(--accent-glow),
    0 0 50px rgba(0, 240, 255, 0.1);
  transform: translateY(-1px);
}
.neon-button:focus-visible {
  outline: 2px solid var(--accent-primary);
  outline-offset: 2px;
}
```

### Gradient Mesh Backgrounds

```css
.cosmic-bg {
  background:
    radial-gradient(
      ellipse at 20% 50%,
      rgba(124, 58, 237, 0.08) 0%,
      transparent 50%
    ),
    radial-gradient(
      ellipse at 80% 20%,
      rgba(0, 240, 255, 0.06) 0%,
      transparent 50%
    ),
    radial-gradient(
      ellipse at 50% 80%,
      rgba(255, 0, 170, 0.04) 0%,
      transparent 50%
    ),
    var(--abyss);
}

.grid-floor {
  background-image:
    linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
  background-size: 40px 40px;
}
```

### Scanline / Noise Overlays

```css
.scanlines::after {
  content: "";
  position: absolute;
  inset: 0;
  background: repeating-linear-gradient(
    0deg,
    transparent,
    transparent 2px,
    rgba(0, 0, 0, 0.1) 2px,
    rgba(0, 0, 0, 0.1) 4px
  );
  pointer-events: none;
  z-index: 100;
}

/* CSS noise texture via SVG filter */
.noise-overlay::before {
  content: "";
  position: absolute;
  inset: 0;
  opacity: 0.03;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
  pointer-events: none;
}
```

---

## Animation Patterns

### Motion Principles

- **Micro-interactions**: `150ms–300ms` duration, `ease` or `ease-out` timing
- **Page transitions / reveals**: `400ms–700ms`, `ease-out` timing
- **Looping ambient effects** (glow pulse, border trace): `2s–5s`, `linear` or `ease-in-out`
- **Always** respect `prefers-reduced-motion` — provide a `@media (prefers-reduced-motion: reduce)` fallback
- **Prioritize CSS-only** solutions; use Motion (framer-motion) for React only when CSS can't achieve the effect

### Page Load Orchestration

```css
@keyframes fadeSlideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes glowPulse {
  0%,
  100% {
    opacity: 0.5;
  }
  50% {
    opacity: 1;
  }
}

@keyframes scanReveal {
  from {
    clip-path: inset(0 0 100% 0);
  }
  to {
    clip-path: inset(0 0 0% 0);
  }
}

/* Staggered entry — apply to children */
.stagger-entry > * {
  animation: fadeSlideUp 0.6s ease-out both;
}
.stagger-entry > *:nth-child(1) {
  animation-delay: 0s;
}
.stagger-entry > *:nth-child(2) {
  animation-delay: 0.1s;
}
.stagger-entry > *:nth-child(3) {
  animation-delay: 0.15s;
}
.stagger-entry > *:nth-child(4) {
  animation-delay: 0.2s;
}
.stagger-entry > *:nth-child(5) {
  animation-delay: 0.25s;
}

/* Reduced motion fallback */
@media (prefers-reduced-motion: reduce) {
  .stagger-entry > * {
    animation: none;
    opacity: 1;
  }
}
```

### Micro-Interactions

```css
/* Hover lift with glow — stable, no layout shift */
.card-hover {
  transition:
    transform 0.25s ease,
    box-shadow 0.25s ease;
  cursor: pointer;
}
.card-hover:hover {
  transform: translateY(-4px);
  box-shadow:
    0 12px 40px rgba(0, 0, 0, 0.5),
    0 0 20px var(--accent-glow);
}

/* Border trace animation */
@keyframes borderTrace {
  0% {
    background-position: 0% 0%;
  }
  100% {
    background-position: 200% 0%;
  }
}
.animated-border {
  border: 1px solid transparent;
  background:
    linear-gradient(var(--surface), var(--surface)) padding-box,
    linear-gradient(
        90deg,
        var(--accent-primary),
        transparent,
        var(--accent-primary)
      )
      border-box;
  background-size: 200% 100%;
  animation: borderTrace 3s linear infinite;
}
```

---

## Platform-Specific Guidelines

### Web (React / HTML)

- Use CSS `backdrop-filter` for glassmorphism (check browser support)
- Build with CSS Grid + Flexbox for responsive layouts
- Use `prefers-color-scheme: dark` as base, but ALWAYS default to dark
- Import fonts via `<link>` from Google Fonts
- Use CSS custom properties for theming
- For React: use Tailwind utilities where possible, custom CSS for complex effects
- Responsive breakpoints: `375px` (mobile), `768px` (tablet), `1024px` (desktop), `1440px` (wide)
- **No horizontal scroll on any breakpoint**

### Mobile (React-style / responsive web)

- **Touch targets**: Minimum `44×44px` tap areas
- **Bottom navigation**: Primary actions within thumb reach
- **Safe areas**: Account for notch/dynamic island with `env(safe-area-inset-*)`
- **Reduced motion**: Respect `prefers-reduced-motion` — simplify or remove animations
- **Haptic hints**: Design interactions that suggest haptic feedback (quick transitions, snappy buttons)
- **Cards over tables**: Use stacked cards instead of data tables on mobile
- **Dark OLED optimization**: Use true black (`#000`) backgrounds for AMOLED power savings
- **Font sizes**: Minimum `14px` body, `12px` captions
- **Scrolling**: Vertical only, no horizontal overflow

### Mac Desktop (Electron / web-based desktop)

- **macOS-native feel**: Rounded corners (`12–16px`), window chrome-aware layouts
- **Sidebar + content**: Classic macOS layout pattern — fixed sidebar, scrollable main content
- **Vibrancy**: Use `backdrop-filter` to simulate macOS vibrancy/materials
- **Traffic lights zone**: Leave ~`80px` top-left clear for window controls
- **Hover states**: Rich hover interactions (desktops have cursors!)
- **Keyboard shortcuts**: Design for power users — show shortcut hints in UI (`⌘K`, `⌘/`, etc.)
- **Window size awareness**: Design for `1200px` minimum, scale gracefully to `2560px+`
- **Density**: Desktop users expect higher information density than mobile
- **Custom scrollbars**: Style to match dark theme:

```css
::-webkit-scrollbar {
  width: 6px;
}
::-webkit-scrollbar-track {
  background: transparent;
}
::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
}
::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.2);
}
```

---

## Component Patterns

### Cards

- Background: `rgba(255, 255, 255, 0.02–0.05)` with `backdrop-filter: blur()`
- Border: `1px solid rgba(255, 255, 255, 0.06)`
- Border-radius: `12–20px`
- Hover: Subtle glow + lift (stable — no layout shift)
- Inner content padding: `20–28px`
- `cursor: pointer` if clickable

### Buttons

- **Primary**: Accent color background with subtle glow, text in dark
- **Secondary**: Transparent with accent border and glow
- **Ghost**: Transparent, accent text, hover reveals background
- All buttons: `border-radius: 8–12px`, `padding: 10px 24px`, `font-weight: 600`, `letter-spacing: 0.02em`
- All buttons: `cursor: pointer`, visible `:focus-visible` ring
- Transitions: `all 0.2s ease`

### Inputs

- Background: `rgba(255, 255, 255, 0.03)`
- Border: `1px solid rgba(255, 255, 255, 0.08)`
- Focus: Border transitions to accent color + subtle glow
- Placeholder: `var(--text-tertiary)`
- Border-radius: `8–12px`
- **Always** include a visible `<label>` or `aria-label`

### Navigation

- Sidebar: Frosted glass panel, icon + label items, accent highlight on active
- Top bar: Blur background, minimal, centered or left-aligned title
- Mobile bottom bar: 4–5 items max, icon-first, accent color on active, `44px` min touch targets

### Data Displays

- Use accent colors for charts/graphs
- Monospace fonts for numbers and data
- Subtle grid lines in `rgba(255, 255, 255, 0.04)`
- Animated count-up for key metrics
- Status indicators: Colored dots with subtle pulse animation

---

## Anti-Patterns (NEVER do these)

1. **White or light backgrounds** — This is a DARK skill. No light modes unless explicitly asked.
2. **Flat, lifeless surfaces** — Every surface should have depth (glass, gradients, borders, shadows).
3. **Generic fonts** — No Inter, Roboto, Arial, system-ui.
4. **Purple gradient on white** — The classic AI slop aesthetic. Absolutely not.
5. **Emojis as icons** — Use SVG icon libraries only.
6. **Uniform spacing** — Vary rhythm. Dense clusters + breathing room.
7. **Tiny, low-contrast text** — Dark themes need WCAG AA contrast minimum on important text.
8. **Overused blue** — If using blue accents, make them electric and distinct, not default browser blue.
9. **Ignoring platform conventions** — Mac apps should feel like Mac apps. Mobile should feel mobile-native.
10. **All glow, no substance** — Effects serve the content. Don't glow everything.
11. **Inconsistent radius** — Pick a border-radius scale (`4, 8, 12, 16, 20`) and stick to it.
12. **Missing cursors** — Every interactive element needs `cursor: pointer`.
13. **Scale transforms on hover** that shift surrounding layout — use `translateY` or `box-shadow` instead.

---

## Pre-Delivery Checklist

Before delivering any output, verify EVERY item:

### Visual Quality

- [ ] Background is truly dark (not gray, not dark-blue-pretending-to-be-dark)
- [ ] At least one memorable visual signature (glow, animation, unusual layout)
- [ ] Typography is distinctive (imported custom fonts, proper hierarchy)
- [ ] Color accents are intentional and consistent
- [ ] Glass/blur effects on at least one surface element
- [ ] Smooth animations on load and interaction
- [ ] No emojis used as icons — SVG only
- [ ] NO generic AI aesthetics (no Inter, no purple-on-white, no cookie-cutter cards)

### UX & Accessibility

- [ ] All interactive elements have `cursor: pointer`
- [ ] All form inputs have visible labels or `aria-label`
- [ ] All images have `alt` text
- [ ] Text contrast meets 4.5:1 minimum (body text on dark backgrounds)
- [ ] Visible `:focus-visible` styles on all interactive elements
- [ ] Responsive at all breakpoints: `375px`, `768px`, `1024px`, `1440px`
- [ ] No horizontal scroll on mobile
- [ ] `prefers-reduced-motion` fallback is present

### Platform Fit

- [ ] Mobile: Touch targets ≥ `44×44px`, safe area padding, bottom nav in thumb reach
- [ ] Desktop: Custom scrollbars, keyboard shortcut hints, higher info density
- [ ] Mac: Traffic light zone clearance, sidebar layout pattern, vibrancy effects

---

## Quick Start Template (React/JSX)

When starting a new component, begin with this structure:

```jsx
import { useState } from "react";

// Font import (add to HTML head or use @import)
// <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=DM+Sans:wght@400;500;700&display=swap" rel="stylesheet">

export default function FuturisticApp() {
  return (
    <div
      style={{
        minHeight: "100vh",
        background: "#050508",
        fontFamily: "'DM Sans', sans-serif",
        color: "#e8e8f0",
        position: "relative",
        overflow: "hidden",
      }}
    >
      {/* Ambient background gradient */}
      <div
        style={{
          position: "fixed",
          inset: 0,
          zIndex: 0,
          background: `
          radial-gradient(ellipse at 20% 50%, rgba(0,240,255,0.06) 0%, transparent 50%),
          radial-gradient(ellipse at 80% 20%, rgba(124,58,237,0.04) 0%, transparent 50%)
        `,
        }}
      />

      {/* Content */}
      <div style={{ position: "relative", zIndex: 1 }}>
        {/* Your futuristic UI here */}
      </div>
    </div>
  );
}
```

---

Remember: Every interface should make the user feel like they're interacting with technology from the future. Dark, cool, and unforgettable.
