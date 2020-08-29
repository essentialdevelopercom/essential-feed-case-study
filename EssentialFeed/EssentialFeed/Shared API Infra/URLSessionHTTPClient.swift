//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
	private let session: URLSession
	
	public init(session: URLSession) {
		self.session = session
	}
	
	private struct UnexpectedValuesRepresentation: Error {}
	
	private struct URLSessionTaskWrapper: HTTPClientTask {
		let wrapped: URLSessionTask
		
		func cancel() {
			wrapped.cancel()
		}
	}
	
	public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
		let task = session.dataTask(with: url) { data, response, error in
			completion(Result {
				if let error = error {
					throw error
				} else if let data = data, let response = response as? HTTPURLResponse {
					return (data, response)
				} else {
					throw UnexpectedValuesRepresentation()
				}
			})
		}
		task.resume()
		return URLSessionTaskWrapper(wrapped: task)
	}
}
