//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedCache {
	func save(_ feed: [FeedImage]) throws
}
