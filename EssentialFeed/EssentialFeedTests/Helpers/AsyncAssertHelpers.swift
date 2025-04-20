
import XCTest

public extension XCTestCase {
    /// Helper para reintentar comparaciones con espera (asincronía Keychain, operaciones async, etc)
	func assertEventuallyEqual<T: Equatable>(
        _ expression1: @autoclosure @escaping () -> T?,
        _ expression2: @autoclosure @escaping () -> T?,
        timeout: TimeInterval = 0.5,
        interval: TimeInterval = 0.05,
        file: StaticString = #file, line: UInt = #line
    ) {
        print("[assertEventuallyEqual] ENTER (timeout: \(timeout), interval: \(interval))")
        let deadline = Date().addingTimeInterval(timeout)
        var lastValue: T?
        var retryCount = 0
        repeat {
            lastValue = expression1()
            print("[assertEventuallyEqual] Retry #\(retryCount) - got value: \(String(describing: lastValue)), expected: \(String(describing: expression2()))")
            if lastValue == expression2() { print("[assertEventuallyEqual] SUCCESS after \(retryCount) retries"); return }
            RunLoop.current.run(until: Date().addingTimeInterval(interval))
            retryCount += 1
        } while Date() < deadline
        print("[assertEventuallyEqual] FAIL after \(retryCount) retries. Last value: \(String(describing: lastValue)), expected: \(String(describing: expression2()))")
        XCTFail("Expected \(String(describing: expression2())) but got \(String(describing: lastValue))", file: file, line: line)
    }
}

