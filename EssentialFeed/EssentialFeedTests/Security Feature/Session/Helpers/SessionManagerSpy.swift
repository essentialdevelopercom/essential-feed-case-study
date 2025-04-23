import Foundation

final class SessionManagerSpy: SessionManaging {
    private(set) var registeredSessions: [(userID: String, token: String, date: Date)] = []

    func registerSession(userID: String, token: String, date: Date) {
        registeredSessions.append((userID, token, date))
    }
}
