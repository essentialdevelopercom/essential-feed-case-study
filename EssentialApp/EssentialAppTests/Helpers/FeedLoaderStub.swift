//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import EssentialFeed

class FeedLoaderStub: FeedLoader {
	private let result: FeedLoader.Result
	
	init(result: FeedLoader.Result) {
		self.result = result
	}

	func load(completion: @escaping (FeedLoader.Result) -> Void) {
		completion(result)
	}
}
