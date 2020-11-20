//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class HTTPClientStub: HTTPClient {
	private class Task: HTTPClientTask {
		func cancel() {}
	}
	
	private let stub: (URL) -> HTTPClient.Result
	
	init(stub: @escaping (URL) -> HTTPClient.Result) {
		self.stub = stub
	}
	
	func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
		completion(stub(url))
		return Task()
	}
}

extension HTTPClientStub {
	static var offline: HTTPClientStub {
		HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
	}
	
	static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
		HTTPClientStub { url in .success(stub(url)) }
	}
}
