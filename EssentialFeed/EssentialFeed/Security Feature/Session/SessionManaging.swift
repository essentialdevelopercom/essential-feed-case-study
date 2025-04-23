
import Foundation

public protocol SessionManaging {
	func registerSession(userID: String, token: String, date: Date)
}
