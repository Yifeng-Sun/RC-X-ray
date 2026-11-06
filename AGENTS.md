# RC-X(ray) Agent Guide

## Mission

Build a stable macOS menu-bar utility named RC-X(ray) that lets a user reveal live screen content with a circular, heavily feathered brush while preserving normal right-click behavior for short clicks.

The app must support arbitrary frontmost applications, run continuously in the background, and remain usable and recoverable after every development cycle.

## Product contract

### Normal right-click

- A short right-button press must behave like an ordinary macOS right-click.
- The application must not show a reveal brush for a short click.
- The underlying application must receive the normal right-click/context-menu interaction.

### Reveal brush

- A right-button press held past a configurable activation threshold (initial target: 150–250 ms) activates the brush.
- Once activated, the right-click gesture is suppressed completely; no context menu is shown for that gesture.
- The brush is circular with strongly blurred/feathered edges.
- The brush follows cursor movement and reveals continuously updated screen content in real time.
- Revealed areas accumulate into a persistent mask, like painting with a brush.
- The initial target window/display is determined at right-button-down and remains the capture target for that brush session.

### Grace period

- Releasing the right button after brush activation enters a one-second grace period.
- Cursor movement during the grace period continues painting the reveal mask without requiring the button to be held.
- A new right-button press during the grace period resumes brushing and is also suppressed.
- After one second without a new brush gesture, the overlay and mask reset to the idle state.

### Overlay behavior

- The reveal overlay must not activate, focus, or steal input from the underlying application.
- The overlay must be mouse-transparent.
- It must work across Retina scaling, multiple displays, Spaces, and normal window movement.
- It must avoid capturing or displaying its own overlay as feedback.
- The app should provide a clear permission/setup state when required system permissions are missing.

## Technical direction

Use native Swift/AppKit foundations unless a later decision documents a reason to change:

- Menu-bar/background application lifecycle.
- Quartz/global event monitoring or event tap for right-button interception.
- A short pending-click buffer so the app can distinguish a normal click from a brush gesture.
- ScreenCaptureKit for live screen/window capture.
- A borderless, nonactivating, mouse-transparent overlay window.
- Core Image/Core Animation or equivalent GPU-backed compositing for the persistent feathered mask.
- Explicit Retina-aware conversion between global screen coordinates, capture coordinates, and overlay coordinates.

The implementation must treat permission handling as a first-class feature. Screen capture requires the appropriate macOS Screen Recording permission and usage description. Global input interception may require Accessibility/Input Monitoring authorization. Never hide these requirements from the user or silently fail.

## Event semantics

The intended state machine is:

```text
Idle
  └─ right-button-down → Pending

Pending
  ├─ release before threshold → replay/pass through normal right-click → Idle
  └─ threshold reached → Brushing

Brushing
  ├─ cursor movement → paint persistent reveal mask
  └─ right-button-up → GracePeriod

GracePeriod
  ├─ cursor movement → continue painting
  ├─ right-button-down → Brushing
  └─ timeout → Idle
```

The pending-click implementation must be tested against at least Finder, a text editor, a browser, and a standard AppKit context menu. Event replay/suppression must not leave the right button logically stuck.

## Cycle protocol

Work autonomously in small vertical slices. Every cycle must produce a stable deliverable, even if the full product is incomplete.

At the start of each cycle:

1. Inspect the current repository state and existing changes.
2. Select one narrowly scoped outcome that can be demonstrated or verified.
3. Write or update acceptance criteria for that outcome.
4. Avoid broad refactors and unrelated cleanup.

During the cycle:

1. Keep the app launchable and the project build configuration valid.
2. Prefer reversible, incremental changes.
3. Add focused tests or diagnostics with each nontrivial behavior change.
4. Make permission failures and unsupported situations explicit.
5. Do not claim functionality that has only been stubbed or visually approximated.

Before completing the cycle:

1. Build the app using the repository's configured build command.
2. Run all available automated tests, linting, and formatting checks.
3. Perform a smoke test of the changed behavior where possible.
4. Confirm there are no compile errors, unhandled fatal paths, or broken existing behaviors.
5. Update documentation for any changed behavior, permission, or limitation.
6. Leave the repository in a runnable state; if a check cannot run, record the exact blocker and provide the safest fallback verification.

The cycle is not complete if the project is left knowingly uncompilable. If a desired feature cannot be completed safely in the current cycle, deliver a smaller working slice instead.

## Suggested implementation order

1. Establish a minimal menu-bar app that launches and exits cleanly.
2. Add a testable event state machine with configurable threshold and grace-period timing.
3. Implement normal right-click pass-through for short clicks.
4. Implement suppression for activated brush gestures and verify no context menu appears.
5. Add a static overlay and cursor tracking.
6. Add live capture with permission handling.
7. Add the persistent feathered brush mask and GPU-backed compositing.
8. Handle multiple displays, Retina scaling, Spaces, overlay exclusion, and lifecycle edge cases.
9. Add settings, diagnostics, onboarding, and packaging/signing documentation.

## Verification checklist

At minimum, verify:

- Short right-click opens the context menu.
- Holding right-click past the threshold activates the brush and opens no menu.
- Releasing an activated brush does not emit a delayed context menu.
- Brushing paints multiple disconnected areas and preserves earlier areas.
- Grace-period movement continues painting for exactly one second, within timing tolerance.
- A new right-button press during grace resumes brushing.
- The overlay does not receive normal application input.
- The overlay is excluded from its own capture.
- Permission denial produces an actionable explanation.
- The app remains responsive while capture and compositing are active.
- The app resets cleanly after timeout, cancellation, display changes, and target-window closure.

## Engineering rules

- Preserve unrelated user changes in the worktree.
- Do not use destructive repository commands without explicit approval.
- Keep secrets, permission data, and captured screen content out of logs and source control.
- Avoid persistent screen recording; capture only what is required for the active reveal session.
- Prefer deterministic tests for timing and event transitions over sleep-based tests.
- Document assumptions when macOS behavior differs by OS version or permission state.
- Before delivery, summarize what works, what was verified, and any known limitations.
