# Design System Strategy: The Kinetic Warehouse

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Digital Curator."** 

Inventory management is traditionally cluttered, rigid, and exhausting. This system rejects the "spreadsheet-on-a-phone" aesthetic in favor of a high-end editorial experience. We treat stock items not as mere data points, but as curated objects. By utilizing intentional asymmetry, expansive breathing room, and a sophisticated layering of surfaces, we transform a utility tool into a premium workspace. The goal is to provide shopkeepers and managers with a sense of "calm control"—where the most critical data is surfaced through high-contrast typography and secondary information recedes into the background.

## 2. Colors & Surface Philosophy
We move beyond flat UI by utilizing a tonal system that mimics physical depth and light.

### The Color Palette (Material Logic)
*   **Primary (`#006c49` / `#10b981`):** Represents "Action" and "Success." Use this for growth indicators, completed stock counts, and primary navigation.
*   **Secondary (`#0058be` / `#3B82F6`):** The "Trust" Blue. Reserved for systemic information, blue-collar logistics, and technical data points.
*   **Tertiary (`#a43a3a`):** Used sparingly for critical alerts or stock-outs.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section off content. Boundaries must be defined solely through background color shifts.
*   **Surface Hierarchy:** A card (`surface_container_lowest`) sitting on a section (`surface_container_low`) creates a natural boundary.
*   **The Glass & Gradient Rule:** For floating Action Buttons (FABs) or high-level summaries, use a subtle linear gradient transitioning from `primary` to `primary_container`. This adds a "soul" to the UI that flat hex codes cannot achieve.

## 3. Typography: The Editorial Edge
We utilize **Inter** not as a standard sans-serif, but as a Swiss-style architectural element.

*   **Display & Headlines:** Use `display-sm` (2.25rem) for warehouse totals or high-level inventory value. The tight letter-spacing and high contrast against `surface` backgrounds create an authoritative, "magazine-style" feel.
*   **The Data Narrative:** Use `title-md` (1.125rem) for product names and `label-md` (0.75rem) for SKUs. 
*   **Hierarchy through Weight:** Always pair a heavy weight (Bold) for data values with a lighter weight (Regular/Medium) for labels to ensure shopkeepers can scan a shelf while looking at their screen.

## 4. Elevation & Depth: Tonal Layering
Traditional shadows are often "dirty." This system uses light and transparency to signify importance.

*   **The Layering Principle:** 
    1.  **Base:** `surface` (#f8f9ff)
    2.  **Sectioning:** `surface_container_low` (#eff4ff)
    3.  **Active Cards:** `surface_container_lowest` (#ffffff)
*   **Ambient Shadows:** If a card must "float" (e.g., a critical low-stock alert), use an extra-diffused shadow: `Y: 8px, Blur: 24px, Color: #0b1c30 (Opacity: 4%)`.
*   **The "Ghost Border" Fallback:** If accessibility requires a container edge, use `outline_variant` at **15% opacity**. Never use 100% opaque lines.
*   **Glassmorphism:** Use `surface_bright` with a 70% opacity and a `20px backdrop-blur` for sticky headers. This allows the colors of inventory images to bleed through subtly as the user scrolls.

## 5. Components & Primitive Styling

### Buttons (The Kinetic Triggers)
*   **Primary:** Solid `primary` background. 12px (`md`) rounded corners. No border. Use `on_primary` for text.
*   **Secondary:** `secondary_container` background with `on_secondary_container` text. These should feel "recessed" compared to the Primary.
*   **Sizing:** 56px height for mobile touch targets to accommodate warehouse environments.

### Input Fields & Search
*   **Styling:** Use `surface_container_high` for the input track. Remove the bottom line. 
*   **Focus State:** Shift background to `surface_container_lowest` and apply a 2px "Ghost Border" of the `primary` color.

### Cards & Lists (The Inventory Unit)
*   **The "No-Divider" Rule:** Forbid the use of horizontal lines between list items. Instead, use a `12px` vertical gap between cards or a subtle background toggle between `surface_container_lowest` and `surface_container_low`.
*   **Inventory Cards:** High-contrast data (Stock Count) should be placed in the top-right using `headline-sm` in `primary` color.

### Chips (Status Micro-Data)
*   **Selection:** Use `primary_fixed` with `on_primary_fixed_variant` text.
*   **Logic:** Chips must use `full` roundness (9999px) to contrast against the `12px` card corners.

## 6. Do’s and Don’ts

### Do:
*   **Do** use asymmetrical padding (e.g., 24px left, 16px right) on certain dashboard headers to create an "Editorial" flow.
*   **Do** use `primary` gradients on progress bars to show stock replenishment.
*   **Do** prioritize "Glanceable" data—bold numbers, soft labels.

### Don’t:
*   **Don't** use pure black (#000000) for text. Use `on_surface` (#0b1c30) to maintain a premium, ink-like softness.
*   **Don't** use standard "Drop Shadows." If it looks like a 2010 app, it’s too heavy. Use Tonal Layering.
*   **Don't** cram items. If a warehouse manager can't tap it with a thumb while walking, the spacing is too tight. Use the `lg` (1rem) spacing scale as your minimum margin.