//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageDataCache {
	func save(_ data: Data, for url: URL) throws
}
