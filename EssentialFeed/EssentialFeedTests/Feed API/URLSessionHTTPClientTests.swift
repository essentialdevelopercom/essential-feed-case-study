//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		
		URLProtocolStub.startInterceptingRequests()
	}
	
	override func tearDown() {
		super.tearDown()
		
		URLProtocolStub.stopInterceptingRequests()
	}
	
	func test_getFromURL_performsGETRequestWithURL() {
		let url = anyURL()
		let exp = expectation(description: "Wait for request")
		
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")
			exp.fulfill()
		}
		
		makeSUT().get(from: url) { _ in }
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_cancelGetFromURLTask_cancelsURLRequest() {
		let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?

		XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
	}
	
	func test_getFromURL_failsOnRequestError() {
		let requestError = anyNSError()
		
		let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
		
		XCTAssertEqual(receivedError as NSError?, requestError)
	}
	
	func test_getFromURL_failsOnAllInvalidRepresentationCases() {
		XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
		XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
	}
	
	func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
		let data = anyData()
		let response = anyHTTPURLResponse()
		
		let receivedValues = resultValuesFor((data: data, response: response, error: nil))
		
		XCTAssertEqual(receivedValues?.data, data)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}
	
	func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
		let response = anyHTTPURLResponse()
		
		let receivedValues = resultValuesFor((data: nil, response: response, error: nil))

		let emptyData = Data()
		XCTAssertEqual(receivedValues?.data, emptyData)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}

	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
		let sut = URLSessionHTTPClient()
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
		let result = resultFor(values, file: file, line: line)

		switch result {
		case let .success(data, response):
			return (data, response)
		default:
			XCTFail("Expected success, got \(result) instead", file: file, line: line)
			return nil
		}
	}

	private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> Error? {
		let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
		
		switch result {
		case let .failure(error):
			return error
		default:
			XCTFail("Expected failure, got \(result) instead", file: file, line: line)
			return nil
		}
	}
	
	private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },  file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {
		values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
		
		let sut = makeSUT(file: file, line: line)
		let exp = expectation(description: "Wait for completion")
		
		var receivedResult: HTTPClient.Result!
		taskHandler(sut.get(from: anyURL()) { result in
			receivedResult = result
			exp.fulfill()
		})
		
		wait(for: [exp], timeout: 1.0)
		return receivedResult
	}
		
	private func anyData() -> Data {
		return Data("any data".utf8)
	}
		
	private func anyHTTPURLResponse() -> HTTPURLResponse {
		return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
	}
	
	private func nonHTTPURLResponse() -> URLResponse {
		return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
	}
	
	private class URLProtocolStub: URLProtocol {
		private static var stub: Stub?
		private static var requestObserver: ((URLRequest) -> Void)?
		
		private struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		}
		
		static func stub(data: Data?, response: URLResponse?, error: Error?) {
			stub = Stub(data: data, response: response, error: error)
		}
		
		static func observeRequests(observer: @escaping (URLRequest) -> Void) {
			requestObserver = observer
		}
		
		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stub = nil
			requestObserver = nil
		}
		
		override class func canInit(with request: URLRequest) -> Bool {
			return true
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		override func startLoading() {
			if let requestObserver = URLProtocolStub.requestObserver {
				client?.urlProtocolDidFinishLoading(self)
				return requestObserver(request)
			}

			guard let stub = URLProtocolStub.stub else { return }
			
			if let data = stub.data {
				client?.urlProtocol(self, didLoad: data)
			}
			
			if let response = stub.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			
			if let error = stub.error {
				client?.urlProtocol(self, didFailWithError: error)
			} else {
				client?.urlProtocolDidFinishLoading(self)
			}
		}
		
		override func stopLoading() {}
	}
	
}
