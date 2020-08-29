//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol HTTPClientTask {
	func cancel()
}

public protocol HTTPClient {
	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
	
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	@discardableResult
	func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
