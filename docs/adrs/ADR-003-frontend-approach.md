# ADR-003: Frontend Approach
**Status**: Accepted
**Date**: 2026-03-10

## Context

Frontend requirements:
- Keyboard-native interaction: j/k navigation, Enter to submit, Esc to skip, g+d sequence, h/e marks (FR-6.1, FR-6.2)
- Input-focus guard: navigation shortcuts disabled when typing in exercise input (FR-6.6, AC-014-02)
- 30-second countdown timer with auto-advance at 0 (FR-5.4, FR-5.5)
- Exercise feedback appears within 500ms of Enter press (NFR-1.3)
- Session duration tracking (mirrors server start time; display only)
- Visible focus rings on all interactive elements (FR-6.3)
- No modal dialogs or complex stateful UI

The platform is single-user with no real-time collaboration, no complex client-side state management, no offline mode. The primary interaction model is: load page → answer question → see feedback → advance.

Team size: 1 developer. Operational simplicity is a priority.

## Decision

**Hotwire (Turbo Frames + Turbo Streams) + Stimulus JS.**

Turbo handles answer submission → feedback panel swap without full page reload (achieving 500ms response requirement with server-rendered feedback). Stimulus provides lightweight JavaScript controllers for:
- `timer_controller`: countdown from 30s, auto-advance trigger
- `keyboard_controller`: shortcut binding, input-focus guard, g+d sequence state
- `session_controller`: mirror session elapsed time from server-provided `started_at`

Propshaft + Import Maps: no build step required. Stimulus loaded as ESM via import map.

## Consequences

**Positive**:
- No JavaScript build pipeline (webpack, esbuild, vite). Zero build tooling maintenance.
- Server renders all feedback content — SM-2 result, next review date, explanation — without a separate API layer.
- Turbo Frames scope DOM updates to the feedback region only — snappy UX without a SPA.
- Stimulus controllers are small (~30-50 lines each) and testable with simple DOM fixtures.
- Full Rails compatibility: CSRF tokens, flash messages, and redirects work conventionally.
- Keyboard navigation is a Stimulus concern — well-isolated, doesn't pollute application logic.

**Negative**:
- Timer accuracy: Stimulus timer relies on `setInterval` (browser-side). Subject to tab throttling if tab is backgrounded. Acceptable: exercises are interactive; user is looking at the screen. Server authoritatively records `reviewed_at`, not the client timer value.
- g+d key sequence requires state in the keyboard controller (awaiting second key after g). Simple to implement; no framework needed.

## Alternatives Considered

**React (with Rails API backend)**: Provides rich client-side state management. Would require: separate React app or Rails + Vite integration, API endpoints for all data access, client-side routing, and significantly more JavaScript. Keyboard shortcut handling in React is equivalent work to Stimulus. The 500ms feedback requirement is achievable with Turbo. Rejected: complexity cost far exceeds benefit for single-user tool with 3 Stimulus controllers.

**Plain ERB without JavaScript**: Would require full page reloads for every exercise submission. Timer auto-advance at 30s would be impossible without JavaScript. Focus management (auto-focus input on exercise load) requires JavaScript. Keyboard shortcut sequences require JavaScript. Rejected: core requirements cannot be met.

**Vue.js / Alpine.js**: Alpine.js is closer to Stimulus in weight. However, Hotwire (Turbo + Stimulus) is Rails-native, co-authored by the Rails core team, and fully integrated with Rails' asset pipeline and form helpers. Alpine would require additional setup and lacks the Turbo Streams integration for server-sent DOM updates. Rejected: Hotwire is the better-integrated Rails choice.
