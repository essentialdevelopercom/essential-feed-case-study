
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
        let deadline = Date().addingTimeInterval(timeout)
        var lastValue: T?
        var retryCount = 0
        repeat {
            lastValue = expression1()
            if lastValue == expression2() { return }
            RunLoop.current.run(until: Date().addingTimeInterval(interval))
            retryCount += 1
        } while Date() < deadline
        
        XCTFail("Expected \(String(describing: expression2())) but got \(String(describing: lastValue))", file: file, line: line)
    }
}

