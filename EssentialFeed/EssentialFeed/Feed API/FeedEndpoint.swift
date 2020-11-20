//	
// Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public enum FeedEndpoint {
	case get(after: FeedImage? = nil)
	
	public func url(baseURL: URL) -> URL {
		switch self {
		case let .get(image):
			var components = URLComponents()
			components.scheme = baseURL.scheme
			components.host = baseURL.host
			components.path = baseURL.path + "/v1/feed"
			components.queryItems = [
				URLQueryItem(name: "limit", value: "10"),
				image.map { URLQueryItem(name: "after_id", value: $0.id.uuidString) },
			].compactMap { $0 }
			return components.url!
		}
	}
}
