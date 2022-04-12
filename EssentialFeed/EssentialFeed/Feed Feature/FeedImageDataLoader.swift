//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageDataLoader {
	func loadImageData(from url: URL) throws -> Data
}
