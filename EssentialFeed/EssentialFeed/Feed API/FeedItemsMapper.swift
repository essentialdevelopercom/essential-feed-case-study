//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

final class FeedItemsMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedItem]
	}
	
	private static var OK_200: Int { return 200 }
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
		guard response.statusCode == OK_200,
			let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}

		return root.items
	}
}
