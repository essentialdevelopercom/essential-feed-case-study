//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
	private let session: URLSession
	
	public init(session: URLSession) {
		self.session = session
	}
	
	private struct UnexpectedValuesRepresentation: Error {}
		
	public func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
		let (data, response) = try await session.data(from: url)
		guard let response = response as? HTTPURLResponse else {
			throw UnexpectedValuesRepresentation()
		}
		return (data, response)
	}	
}
