//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public protocol HTTPClientTask {
	func cancel()
}

public protocol HTTPClient {
	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
	
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	@discardableResult
	@available(*, deprecated, message: "Use async alternative")
	func get(from url: URL, completion: @Sendable @escaping (Result) -> Void) -> HTTPClientTask
	
	func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}

public extension HTTPClient {
	func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
		nonisolated(unsafe) var task: HTTPClientTask?
		return try await withTaskCancellationHandler {
			return try await withCheckedThrowingContinuation { continuation in
				task = get(from: url) { result in
					continuation.resume(with: result)
				}
			}
		} onCancel: {
			task?.cancel()
		}
	}
}
