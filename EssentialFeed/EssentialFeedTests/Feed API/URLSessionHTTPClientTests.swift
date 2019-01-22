//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
	private let session: URLSession
	
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { _, _, error in
			if let error = error {
				completion(.failure(error))
			}
		}.resume()
	}
}

class URLSessionHTTPClientTests: XCTestCase {
	
	func test_getFromURL_failsOnRequestError() {
		URLProtocolStub.startInterceptingRequests()
		let url = URL(string: "http://any-url.com")!
		let error = NSError(domain: "any error", code: 1)
		URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
		
		let sut = URLSessionHTTPClient()
		
		let exp = expectation(description: "Wait for completion")
		
		sut.get(from: url) { result in
			switch result {
			case let .failure(receivedError as NSError):
				XCTAssertEqual(receivedError, error)
			default:
				XCTFail("Expected failure with error \(error), got \(result) instead")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		URLProtocolStub.stopInterceptingRequests()
	}

	// MARK: - Helpers
	
	private class URLProtocolStub: URLProtocol {
		private static var stubs = [URL: Stub]()
		
		private struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		}
		
		static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
			stubs[url] = Stub(data: data, response: response, error: error)
		}
		
		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stubs = [:]
		}
		
		override class func canInit(with request: URLRequest) -> Bool {
			guard let url = request.url else { return false }
			
			return URLProtocolStub.stubs[url] != nil
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		override func startLoading() {
			guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
			
			if let data = stub.data {
				client?.urlProtocol(self, didLoad: data)
			}
			
			if let response = stub.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			
			if let error = stub.error {
				client?.urlProtocol(self, didFailWithError: error)
			}
			
			client?.urlProtocolDidFinishLoading(self)
		}
		
		override func stopLoading() {}
	}
	
}
