import XCTest
import EssentialFeed

// Checklist: Validar integración de registro de sesión con almacenamiento seguro
final class SystemSessionManagerTests: XCTestCase {
  
  // Checklist: Validar integración de registro de sesión con almacenamiento seguro
  // CU:  
  func test_registerSession_delegatesToStore() {
    let (sut, store) = makeSUT()
    let userID = "user123"
    let token = "token_abc"
    let date = Date()
    
    sut.registerSession(userID: userID, token: token, date: date)
    
    // Assert: store received correct session
    XCTAssertEqual(store.receivedSessions.count, 1, "store should receive exactly one session")
    let received = store.receivedSessions.first
    XCTAssertEqual(received?.userID, userID, "userID should match")
    XCTAssertEqual(received?.token, token, "token should match")
    XCTAssertEqual(received?.date, date, "date should match")
  }
  
  // MARK: - Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: SystemSessionManager, store: SessionStoreSpy) {
    let store = SessionStoreSpy()
    let sut = SystemSessionManager(store: store)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
}

// MARK: - Test Double
private class SessionStoreSpy: SessionStore {
  private(set) var receivedSessions: [(userID: String, token: String, date: Date)] = []
  func saveSession(userID: String, token: String, date: Date) {
    receivedSessions.append((userID, token, date))
  }
}
