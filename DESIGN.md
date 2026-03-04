# Design System: Neara — Hyperlocal Worker Discovery & Emergency Assistance

> **Stitch Prompting Source of Truth** — Use this file when generating new screens with Stitch to ensure visual consistency.

---

## 1. Visual Theme & Atmosphere

**Mood:** Confident, grounded, and human-first. Neara exists where emergencies happen — in kitchens with leaks, on roadsides at night, in apartments without power. The visual language must simultaneously feel **calm under pressure** and **alive with urgency** when needed.

**Aesthetic:** Dark-anchored midnight surfaces with vivid saffron-amber accents. Think the warmth of a streetlamp cutting through a dark lane — industrious, reliable, South-Asian in soul. The UI is **dense but breathable**: cards are compact, yet well-aerated with deliberate whitespace. This is not a minimal SaaS product — it is a utility app that must project *trust* at 2am.

**Design Character:**
- Primary mode: **Dark theme** with deep navy-charcoal surfaces
- Accent system: **Saffron-amber primary** + electric teal for live/emergency states
- Tone: Warm dark, not cold dark — no pure blacks, all surfaces have warmth
- Overall density: Medium-high (information-rich cards, action-oriented layouts)

---

## 2. Color Palette & Roles

### Core Surfaces
| Name | Hex | Role |
|------|-----|------|
| Deep Midnight Navy | `#0D1117` | App background — deepest layer |
| Warm Charcoal | `#161B22` | Card backgrounds, bottom sheets |
| Elevated Graphite | `#21262D` | Secondary cards, input fields |
| Muted Steel | `#30363D` | Dividers, stroke borders |

### Brand Accents
| Name | Hex | Role |
|------|-----|------|
| Saffron Amber | `#F6A623` | Primary CTA buttons, active states, icons |
| Pale Saffron | `#FBC95A` | Hover/pressed state of saffron, highlights |
| Burnt Umber | `#C47D10` | Darker saffron for badge outlines |

### Semantic / Status Colors
| Name | Hex | Role |
|------|-----|------|
| Emergency Crimson | `#FF3B30` | SOS button, critical alerts, error states |
| Pulse Red Glow | `#FF3B3040` | SOS pulsing halo / ambient glow |
| Live Teal | `#00D4AA` | Online/available indicator, real-time events |
| Safe Green | `#34C759` | Payment success, completed status |
| Warning Amber | `#FF9F0A` | Pending/negotiation states |

### Text
| Name | Hex | Role |
|------|-----|------|
| Bright Ivory | `#F0F6FC` | Primary headings and key data |
| Soft Moonlight | `#B0BEC5` | Body text, secondary labels |
| Muted Fog | `#6E7681` | Hints, placeholders, metadata |

---

## 3. Typography Rules

**Primary Font Family:** `Sora` (Google Fonts) — geometric, friendly, slightly technical. Chosen for its Indian context readability at small sizes and its warmth over clinical sans-serifs like Inter or Roboto.

**Secondary / Accent Font:** `JetBrains Mono` — used **only** for numeric data (prices ₹400, distances 1.3 km, ratings 4.7★) to give figures a precise, trusted dashboard feel.

**Weight Usage:**
- `700 Bold` — Screen titles, worker names, CTAs
- `600 SemiBold` — Card section headers, tab labels
- `400 Regular` — Body text, descriptions, form labels
- `300 Light` — Metadata, timestamps, subtitles

**Letter Spacing:**
- Headings: Slightly tight (`-0.3px`) for impact
- Body: Normal (0)
- ALL CAPS labels (e.g., status chips like "ARRIVED", "IN PROGRESS"): Wide tracking (`+1.5px`)

**Sizing Scale (Mobile):**
- Display: 28sp
- Title: 22sp
- Subtitle: 16sp
- Body: 14sp
- Caption: 12sp
- Micro: 10sp (badges, status)

---

## 4. Component Stylings

### Buttons
- **Primary CTA:** Full-width pill-shaped (`border-radius: 28px`), Saffron Amber (`#F6A623`) fill, Deep Midnight Navy text. Uses `BoxShadow` with `#F6A62340` glow at 12px blur.
- **Secondary:** Outlined pill, `#F6A623` stroke (1.5px), transparent fill, Saffron Amber text.
- **Destructive/SOS:** Full-width rounded rectangle (`border-radius: 16px`), Emergency Crimson fill (`#FF3B30`), with pulsing outer ring animation.
- **Ghost:** No border, no fill — saffron amber text only, used in negotiation flows.
- **Icon Buttons:** Circular `48×48dp`, Elevated Graphite fill (`#21262D`), icon in Saffron Amber.

### Cards & Containers
- **Worker Cards:** Warm Charcoal background (`#161B22`), `border-radius: 16px`, Muted Steel stroke (`#30363D`, 1px), `BoxShadow: 0 4px 20px rgba(0,0,0,0.4)`. Contains avatar (circular, 48px), name in Bright Ivory Bold, rating pill in Pale Saffron, distance in Muted Fog.
- **Service Status Card:** Full-width, `border-radius: 20px`, gradient top-border accent line (Saffron to Teal) as a 3px top decoration.
- **Proposal/Payment Cards:** Elevated Graphite (`#21262D`) surface, with a subtle left-border stripe in Saffron Amber (4px wide).
- **Emergency/SOS Card:** Crimson-tinted Warm Charcoal (`#1E0A0A`), Emergency Crimson accent.

### Inputs & Forms
- **Text Fields:** Elevated Graphite fill (`#21262D`), rounded rectangle (`border-radius: 12px`), Muted Steel border (1px). On focus: Saffron Amber border (1.5px) + subtle outer glow.
- **Voice Record Button:** Large circular (72×72dp), Saffron Amber fill, microphone icon in Midnight Navy, pulsing ring animation when recording.
- **OTP Fields:** Individual square cells (`48×48dp`), Elevated Graphite fill, Saffron Amber filled when active.

### Status Chips & Badges
- **Pill-shaped chips** (`border-radius: 999px`), 8px horizontal padding, 4px vertical padding.
- Colors map to semantic palette: Teal for Available, Warning Amber for Pending, Safe Green for Completed, Crimson for SOS.
- ALL CAPS text, `JetBrains Mono`, 10sp, wide letter spacing.

### Navigation
- **Bottom Navigation Bar:** Warm Charcoal (`#161B22`) background, Muted Steel top border (1px). Active icon in Saffron Amber with soft amber dot indicator below. Inactive icons in Muted Fog.
- **App Bar:** Deep Midnight Navy background, transparent, no elevation. Back icon as circular icon button. Title centered in Bright Ivory SemiBold.

### Rating Stars
- Filled: `#F6A623` (Saffron Amber)
- Empty: `#30363D` (Muted Steel)
- Size: 16sp inline, 24sp on review screens

---

## 5. Layout Principles

**Spatial System:** 4dp base unit. Content margins: 20dp horizontal. Card internal padding: 16dp. Gap between list items: 12dp. Section gaps: 24dp.

**Whitespace Philosophy:** Cards breathe — never stack elements without at least 8dp vertical gap inside a card. Screen content areas always have 20dp left/right margin. Bottom navigation has 16dp top padding.

**Grid Strategy:** Single-column list layout for worker cards. 2-column grid for service category chips on Home screen. Full-bleed hero sections for SOS and voice input.

**Visual Hierarchy Rules:**
1. The most important action is always the largest element with the brightest color (Saffron Amber CTA)
2. Status information is always communicated via colored chips — never only text
3. Critical alerts (SOS, payment) always have a glow/shadow to signal gravity
4. Worker distance and rating are always displayed together in a compact pill

**Elevation Layers:**
- Layer 0 (Background): `#0D1117`
- Layer 1 (Base Cards): `#161B22`
- Layer 2 (Elevated Cards, Modals): `#21262D`
- Layer 3 (Tooltips, Dropdowns): `#2D333B`
- Floating (SOS Overlay, Sheets): `#161B22` + backdrop blur

**Safe Areas:** Respect device safe areas. Bottom navigation sits above device home indicator. Top content starts below status bar with 8dp extra breathing room.

---

## 6. Motion & Animation Guidelines

**Philosophy:** Motion should feel purposeful, not decorative. On a utility app, every animation should communicate meaning — loading, success, urgency.

**Key Animations:**
- **SOS Button:** Continuous pulsing ring (scale 1.0→1.4, opacity 1→0, 1.2s loop, red glow)
- **Voice Recording:** Breathing circle animation (scale oscillates with audio amplitude)
- **Screen Transitions:** Slide-up from bottom (300ms, ease-out curve) for sheets; Slide-right for flows
- **Status Updates:** Subtle slide-in from right + fade (200ms) for new status chips
- **Worker Cards:** Staggered fade-up on list load (delay: index × 60ms)
- **Payment Success:** Scale bounce + safe green flash overlay (400ms)
- **Micro-interactions:** Button press: scale to 0.96 (100ms spring), release back

---

## 7. Stitch Prompt Prefix

When using Stitch to generate new screens for Neara, always begin prompts with:

```
A dark-themed mobile app screen for Neara, a hyperlocal service & emergency platform. 
Deep Midnight Navy background (#0D1117), Warm Charcoal cards (#161B22), 
Saffron Amber primary accent (#F6A623), Bright Ivory text (#F0F6FC), 
Sora font family. Rounded corners (16px cards, 28px buttons). 
Platform: Mobile, Android/iOS-first.
```
