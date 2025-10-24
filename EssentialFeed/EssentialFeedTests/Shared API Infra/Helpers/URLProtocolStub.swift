//
// Copyright © Essential Developer. All rights reserved.
//

import Foundation
import Synchronization

class URLProtocolStub: URLProtocol {
	private struct Stub {
		let data: Data?
		let response: URLResponse?
		let error: Error?
		let shouldComplete: Bool
		let onStartLoading: @MainActor (URLRequest) -> Void
	}
	
	private static let stub = Mutex<Stub?>(nil)
	
	static func stub(data: Data?, response: URLResponse?, error: Error?) {
		stub.withLock { stub in
			stub = Stub(data: data, response: response, error: error, shouldComplete: true, onStartLoading: { _ in })
		}
	}
	
	static func observeRequests(observer: @MainActor @escaping (URLRequest) -> Void) {
		stub.withLock { stub in
			stub = Stub(data: Data(), response: HTTPURLResponse(), error: nil, shouldComplete: true, onStartLoading: observer)
		}
	}
	
	static func onStartLoading(observer: @MainActor @escaping () -> Void) {
		stub.withLock { stub in
			stub = Stub(data: nil, response: nil, error: nil, shouldComplete: false, onStartLoading: { _ in observer() })
		}
	}
	
	static func removeStub() {
		stub.withLock { stub in
			stub = nil
		}
	}
	
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	override func startLoading() {
		guard let stub = URLProtocolStub.stub.withLock({ $0 }) else { return }

		Task { @MainActor [request] in
			stub.onStartLoading(request)
		}
		
		guard let client = self.client else { return }
		
		if let data = stub.data {
			client.urlProtocol(self, didLoad: data)
		}
		
		if let response = stub.response {
			client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		}
		
		if let error = stub.error {
			client.urlProtocol(self, didFailWithError: error)
		} else if stub.shouldComplete {
			client.urlProtocolDidFinishLoading(self)
		}
	}
	
	override func stopLoading() {}
}
