//	
// Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct Paginated<Item> {
	public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void
	
	public let items: [Item]
	public let loadMore: ((@escaping LoadMoreCompletion) -> Void)?
	
	public init(items: [Item], loadMore: ((@escaping LoadMoreCompletion) -> Void)? = nil) {
		self.items = items
		self.loadMore = loadMore
	}
}
