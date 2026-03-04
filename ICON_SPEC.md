# Breviary iOS — App Icon Specification

**Art Director:** Giotto (Ecclesia Dev)
**Style:** Byzantine/Romanesque sacred art tradition
**Date:** 2026-03-03

---

## Concept

The Divine Office — an open illuminated breviary manuscript glowing under candlelight against the darkness of night. The composition evokes the Church praying through the hours, from Matins in the deep night to Compline at day's end.

## Composition

- **Background:** Deep blackish-purple (#1A0A2E) gradient, darkest at corners, suggesting the night hours
- **Central Element:** An open illuminated manuscript/breviary, viewed slightly from above at a ~15° angle. The pages are cream/vellum (#F5E6C8) with visible red and blue text lines suggesting rubrics and psalms
- **Left Page:** A large illuminated capital letter "D" (for "Deus in adiutorium meum intende") in gold (#D4A017) with red (#8B1A1A) vine tendrils
- **Right Page:** Smaller text lines in dark red and deep blue, with a small gold cross at the top margin
- **Light Source:** A single golden oil lamp or beeswax candle at the upper-left, casting warm amber light (#FFD700 to #CC8400) across the open pages. Light radiates outward in a soft Byzantine-style halo
- **Decorative Border:** Thin gold filigree border around the icon perimeter (inset ~3%), using interlocking crosses and vine patterns in the Romanesque tradition
- **Base:** The book rests on a dark wooden lectern or choir stall, barely visible in the darkness

## Color Palette

| Role | Hex | Description |
|------|-----|-------------|
| Background | #1A0A2E | Deep purple-black (night sky) |
| Background gradient | #0D0518 | Near-black for corners |
| Vellum/Pages | #F5E6C8 | Warm cream parchment |
| Gold leaf | #D4A017 | Rich manuscript gold |
| Gold highlight | #FFD700 | Bright gold for lamp light |
| Candlelight glow | #CC8400 | Warm amber radiance |
| Rubric red | #8B1A1A | Deep liturgical red for text |
| Text blue | #1B3A5C | Deep blue for psalm text |
| Border gold | #B8860B | Dark gold for filigree |

## Symbolism

- **Open breviary:** The prayer of the Church, the Opus Dei
- **Night background:** The hours of prayer sanctifying darkness — "In the night I will bless the Lord"
- **Oil lamp:** "Thy word is a lamp unto my feet" (Ps 118:105); also the wise virgins' lamps
- **Illuminated capital:** The medieval monastic tradition of hand-copied sacred texts
- **Gold leaf:** The glory of God shining through sacred words

## Style Notes

- **NO flat design.** The icon should have depth, texture, and warmth
- Parchment should show subtle texture/grain
- Gold areas should suggest metallic leaf, not flat yellow
- Light should feel warm and alive, not digitally perfect
- The overall impression should be: "I am looking into a scriptorium at night"
- Corner radius: standard iOS rounded-rect mask applied by the OS — design to full square
- Ensure the manuscript is legible at 60px (simplify detail at small sizes; the golden glow and open-book silhouette should remain recognizable)

## Required Sizes (pixels, square PNG)

| Size | Usage |
|------|-------|
| 1024x1024 | App Store |
| 180x180 | iPhone @3x |
| 167x167 | iPad Pro @2x |
| 152x152 | iPad @2x |
| 120x120 | iPhone @2x |
| 76x76 | iPad @1x |
| 60x60 | Spotlight/Settings |
| 58x58 | Settings @2x |
| 40x40 | Spotlight @2x |
| 29x29 | Settings @1x |
| 20x20 | Notification @1x |

## Production Notes

- Render from the SVG concept (`icon-concept.svg`) at highest resolution first (1024x1024)
- Add texture overlays (parchment grain, gold leaf speckle) in final production
- Test at all sizes — the silhouette of lamp + open book must read clearly at 29px
- The SVG is a simplified guide; the final icon should be richly detailed at 1024px
