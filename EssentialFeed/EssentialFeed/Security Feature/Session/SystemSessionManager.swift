import Foundation

public protocol SessionStore {
  func saveSession(userID: String, token: String, date: Date)
}

public final class SystemSessionManager: SessionManaging {
  private let store: SessionStore
  
  public init(store: SessionStore) {
    self.store = store
  }
  
  public func registerSession(userID: String, token: String, date: Date) {
    store.saveSession(userID: userID, token: token, date: date)
  }
}
