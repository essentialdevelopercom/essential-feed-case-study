//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class HTTPClientStub: HTTPClient {
	private let stub: (URL) -> Result<(Data, HTTPURLResponse), Error>
	
	init(stub: @escaping (URL) -> Result<(Data, HTTPURLResponse), Error>) {
		self.stub = stub
	}
	
	func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
		try stub(url).get()
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
