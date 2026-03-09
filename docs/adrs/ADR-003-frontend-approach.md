# ADR-003: Frontend Approach — Hotwire (Turbo + Stimulus)

**Status**: Accepted
**Date**: 2026-03-09
**Deciders**: Solo developer (user)

---

## Context

The Ruby Learning Platform requires a browser UI with these characteristics:
- **Keyboard-native**: all interactions via keyboard; vim-style shortcuts (j/k, Enter, Esc, /, ?)
- **Fast feedback**: exercise submission feedback within 100ms; no full-page reload acceptable
- **Overlay management**: progress dashboard (p), keyboard shortcut help (?), topic selection (t) — all open as overlays without losing page state
- **Timer**: 30-second countdown visible on every exercise; auto-reveals answer on expiry
- **Tree navigation**: curriculum tree with j/k movement, inline search filter
- **No multi-user state**: no client-side auth, no complex client state management

Quality attributes driving this decision:
- **Time-to-market** (rank 3): no separate frontend build pipeline desired
- **Simplicity** (rank 4): personal tool; minimal JS complexity
- **Keyboard usability** (rank 5): must work; but implementation is server-side rendering + Stimulus

---

## Decision

**Hotwire: Turbo Drive + Turbo Frames + Stimulus.**

No separate JavaScript SPA framework. Rails renders HTML. Turbo handles page transitions and partial updates. Stimulus provides targeted JavaScript for keyboard shortcuts, timer, focus management.

---

## Rationale

Hotwire is bundled with Rails 8. It enables:
- **Turbo Drive**: intercepts links/forms; replaces `<body>` without full page reload. Page transitions feel instant.
- **Turbo Frames**: partial page updates; exercise submission renders new frame without page reload. Achieves 100ms feedback target.
- **Turbo Streams**: server-push updates over WebSocket/SSE (not needed for MVP; available for future enhancement)
- **Stimulus**: minimal JavaScript framework for DOM-attached controllers. Each keyboard feature is a targeted controller (KeyboardController, TimerController, FocusController, SearchController).

This approach:
- Eliminates separate frontend build (no webpack, no npm pipeline)
- All keyboard shortcuts implemented in Stimulus; centralized keymap config
- Overlays implemented with Turbo Frames + CSS; no separate modal framework needed
- Server renders curriculum tree as HTML; client-side search filters DOM nodes directly (25 lessons fits in memory)

---

## Alternatives Considered

### Alternative 1: React (or Vue / Svelte) SPA
- **What**: JavaScript SPA communicating with Rails JSON API. React handles all UI state, keyboard navigation, overlays.
- **Evaluation**: Mature keyboard libraries exist (hotkeys.js, react-hotkeys-hook). Richer client state management. Decoupled from Rails server-side rendering.
- **Rejection reason**: Adds significant complexity for a 1-user personal tool:
  - Separate frontend build pipeline (Node.js, bundler, npm)
  - Rails API layer required in addition to existing Rails app
  - JavaScript state management (Redux/Zustand) for 25 lessons is overkill
  - Solo developer must context-switch between Ruby and JavaScript ecosystems
  - Time-to-market impact; Hotwire achieves all UI requirements without the overhead

### Alternative 2: Vanilla JavaScript (no framework)
- **What**: Write keyboard shortcut handling, timer, DOM manipulation in plain JS files
- **Evaluation**: Zero dependencies; maximum control
- **Rejection reason**: Stimulus provides just enough structure (controller lifecycle, targets, values) to keep keyboard shortcut code maintainable over months/years. Vanilla JS keyboard handlers grow unwieldy without lifecycle management. Stimulus is 2.9kB; negligible overhead.

### Alternative 3: ViewComponent (Rails) + Alpine.js
- **What**: Rails ViewComponent for component encapsulation; Alpine.js for lightweight interactivity (declarative x-data attributes in HTML)
- **Evaluation**: Alpine.js simpler than Stimulus for some use cases. ViewComponent improves template reuse.
- **Rejection reason**: Alpine.js is an additional dependency with smaller community than Stimulus. Stimulus is Rails-native (Rails 8 includes it). ViewComponent is a valid addition but not required in MVP; templates can be extracted later if needed.

---

## Consequences

**Positive**:
- No separate frontend build; `rails server` is the only process for development
- Turbo Frames satisfy 100ms exercise feedback requirement without custom XHR
- Stimulus KeyboardController provides centralized, testable keyboard shortcut registration
- Rails server renders HTML; search engines can index content (irrelevant for personal tool, but zero-cost benefit)
- Aligns with Rails 8 defaults; no divergence from framework conventions

**Negative**:
- Complex client-side state (e.g., in-flight timer state on navigation) requires careful Stimulus lifecycle management. Mitigation: timer state stored in Stimulus controller values; Turbo `beforeRender` event handles cleanup.
- Turbo caching can interfere with timer (timer may continue on cached page). Mitigation: `data-turbo-cache="false"` on exercise frames; or timer restarts on Stimulus `connect()`.
- Offline use not possible (no service worker). Acceptable: personal tool on personal server; 1 user.

**License**: Turbo — MIT; Stimulus — MIT
**GitHub**: https://github.com/hotwired/turbo (4.5k+ stars, active); https://github.com/hotwired/stimulus (12k+ stars, active)
