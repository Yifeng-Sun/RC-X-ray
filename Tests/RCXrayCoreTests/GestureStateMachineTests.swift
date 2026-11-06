import XCTest
@testable import RCXrayCore

final class GestureStateMachineTests: XCTestCase {
    func testShortClickIsReplayedAndNeverActivatesBrush() {
        var machine = GestureStateMachine(activationThreshold: 0.2)

        XCTAssertEqual(machine.handle(.rightButtonDown, at: 10), [.armPendingClick])
        XCTAssertEqual(machine.handle(.rightButtonUp, at: 10.1), [.replayShortClick])
        XCTAssertEqual(machine.phase, .idle)
    }

    func testThresholdActivatesAndSuppressesReleaseIntoGracePeriod() {
        var machine = GestureStateMachine(activationThreshold: 0.2, gracePeriod: 1)

        _ = machine.handle(.rightButtonDown, at: 10)
        XCTAssertEqual(machine.handle(.thresholdElapsed, at: 10.2), [.activateBrush, .paint])
        XCTAssertEqual(machine.handle(.cursorMoved, at: 10.3), [.paint])
        XCTAssertEqual(machine.handle(.rightButtonUp, at: 10.4), [
            .suppressRightButtonUp,
            .enterGracePeriod(expiresAt: 11.4)
        ])
    }

    func testGracePeriodPaintsAndCanResumeBrushing() {
        var machine = GestureStateMachine(gracePeriod: 1)

        _ = machine.handle(.rightButtonDown, at: 0)
        _ = machine.handle(.thresholdElapsed, at: 0.2)
        _ = machine.handle(.rightButtonUp, at: 0.3)
        XCTAssertEqual(machine.handle(.cursorMoved, at: 0.8), [.paint])
        XCTAssertEqual(machine.handle(.rightButtonDown, at: 0.9), [.activateBrush, .paint])
        XCTAssertEqual(machine.phase, .brushing)
    }

    func testGracePeriodExpiresAtOneSecond() {
        var machine = GestureStateMachine(gracePeriod: 1)

        _ = machine.handle(.rightButtonDown, at: 0)
        _ = machine.handle(.thresholdElapsed, at: 0.2)
        _ = machine.handle(.rightButtonUp, at: 0.5)
        XCTAssertEqual(machine.handle(.gracePeriodElapsed, at: 1.49), [])
        XCTAssertEqual(machine.handle(.gracePeriodElapsed, at: 1.5), [.reset])
        XCTAssertEqual(machine.phase, .idle)
    }
}
