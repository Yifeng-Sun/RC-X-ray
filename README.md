# RC-X-ray

RC-X-ray is a macOS menu-bar utility for revealing live screen content with a feathered right-button brush while preserving ordinary short right-clicks.

## Current vertical slice

- A native AppKit menu-bar executable launches as an accessory/background app.
- The core right-button gesture state machine is implemented as a Foundation-only library.
- Short clicks replay as normal clicks; activated gestures transition to brushing and then a one-second grace period.
- Timing is injected into the state machine, making the behavior deterministic to test.
- The menu exposes live Screen Recording and Accessibility/Input Monitoring permission status with direct links to System Settings.

The event tap, screen capture, overlay, permissions UI, and compositor are intentionally not claimed yet; they are the next slices.

## Build and test

```sh
swift test
swift build
```

The executable requires macOS and can be launched from the built products directory when running under a full macOS development environment.
