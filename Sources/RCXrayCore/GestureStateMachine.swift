import Foundation

/// The interaction phases described by the product contract.
public enum GesturePhase: Equatable, Sendable {
    case idle
    case pending(startedAt: TimeInterval)
    case brushing
    case gracePeriod(expiresAt: TimeInterval)
}

public enum GestureEvent: Equatable, Sendable {
    case rightButtonDown
    case rightButtonUp
    case cursorMoved
    case thresholdElapsed
    case gracePeriodElapsed
    case cancelled
}

public enum GestureEffect: Equatable, Sendable {
    case armPendingClick
    case replayShortClick
    case activateBrush
    case paint
    case suppressRightButtonUp
    case enterGracePeriod(expiresAt: TimeInterval)
    case reset
}

/// Pure state machine for right-button gestures. Timing is supplied by the caller,
/// so tests do not need sleeps and the event tap can use its own clock.
public struct GestureStateMachine: Sendable {
    public private(set) var phase: GesturePhase = .idle
    public let activationThreshold: TimeInterval
    public let gracePeriod: TimeInterval

    public init(activationThreshold: TimeInterval = 0.2, gracePeriod: TimeInterval = 1.0) {
        precondition(activationThreshold >= 0)
        precondition(gracePeriod > 0)
        self.activationThreshold = activationThreshold
        self.gracePeriod = gracePeriod
    }

    @discardableResult
    public mutating func handle(_ event: GestureEvent, at time: TimeInterval) -> [GestureEffect] {
        switch (phase, event) {
        case (.idle, .rightButtonDown):
            phase = .pending(startedAt: time)
            return [.armPendingClick]

        case let (.pending(startedAt), .thresholdElapsed) where time - startedAt >= activationThreshold:
            phase = .brushing
            return [.activateBrush, .paint]

        case let (.pending(startedAt), .rightButtonUp):
            guard time - startedAt < activationThreshold else {
                phase = .brushing
                return [.activateBrush, .paint, .suppressRightButtonUp]
            }
            phase = .idle
            return [.replayShortClick]

        case (.pending, .cancelled):
            phase = .idle
            return [.reset]

        case (.brushing, .cursorMoved):
            return [.paint]

        case (.brushing, .rightButtonUp):
            let expiry = time + gracePeriod
            phase = .gracePeriod(expiresAt: expiry)
            return [.suppressRightButtonUp, .enterGracePeriod(expiresAt: expiry)]

        case (.brushing, .cancelled):
            phase = .idle
            return [.reset]

        case (.gracePeriod, .cursorMoved):
            return [.paint]

        case (.gracePeriod, .rightButtonDown):
            phase = .brushing
            return [.activateBrush, .paint]

        case let (.gracePeriod(expiresAt), .gracePeriodElapsed) where time >= expiresAt:
            phase = .idle
            return [.reset]

        case (.gracePeriod, .cancelled):
            phase = .idle
            return [.reset]

        default:
            return []
        }
    }
}
