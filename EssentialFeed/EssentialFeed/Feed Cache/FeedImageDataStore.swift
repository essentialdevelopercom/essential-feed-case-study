//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageDataStore {
	typealias Result = Swift.Result<Data?, Error>
	
	func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
