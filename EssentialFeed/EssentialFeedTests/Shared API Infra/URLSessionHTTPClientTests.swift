//
// Copyright © Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

@MainActor
class URLSessionHTTPClientTests: XCTestCase {
	
	override func tearDown() {
		super.tearDown()
		
		URLProtocolStub.removeStub()
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
	
	func test_cancelGetFromURLTask_cancelsURLRequest() async {
		var task: HTTPClientTask?
		URLProtocolStub.onStartLoading { task?.cancel() }
		
		let receivedError = await resultErrorFor(taskHandler: { task = $0 }) as NSError?
		
		XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
	}
	
	func test_getFromURL_failsOnRequestError() async {
		let requestError = anyNSError()
		
		let receivedError = await resultErrorFor((data: nil, response: nil, error: requestError))
		
		XCTAssertNotNil(receivedError)
	}
	
	func test_getFromURL_failsOnAllInvalidRepresentationCases() async {
		assertNotNil(await resultErrorFor((data: nil, response: nil, error: nil)))
		assertNotNil(await resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
		assertNotNil(await resultErrorFor((data: anyData(), response: nil, error: nil)))
		assertNotNil(await resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
		assertNotNil(await resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
		assertNotNil(await resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
		assertNotNil(await resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
		assertNotNil(await resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
		assertNotNil(await resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
	}
	
	func test_getFromURL_succeedsOnHTTPURLResponseWithData() async {
		let data = anyData()
		let response = anyHTTPURLResponse()
		
		let receivedValues = await resultValuesFor((data: data, response: response, error: nil))
		
		XCTAssertEqual(receivedValues?.data, data)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}
	
	func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() async {
		let response = anyHTTPURLResponse()
		
		let receivedValues = await resultValuesFor((data: nil, response: response, error: nil))
		
		let emptyData = Data()
		XCTAssertEqual(receivedValues?.data, emptyData)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [URLProtocolStub.self]
		let session = URLSession(configuration: configuration)
		
		let sut = URLSessionHTTPClient(session: session)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath, line: UInt = #line) async -> (data: Data, response: HTTPURLResponse)? {
		let result = await resultFor(values, file: file, line: line)
		
		switch result {
		case let .success(values):
			return values
		default:
			XCTFail("Expected success, got \(result) instead", file: file, line: line)
			return nil
		}
	}
	
	private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) async -> Error? {
		let result = await resultFor(values, taskHandler: taskHandler, file: file, line: line)
		
		switch result {
		case let .failure(error):
			return error
		default:
			XCTFail("Expected failure, got \(result) instead", file: file, line: line)
			return nil
		}
	}
	
	private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },  file: StaticString = #filePath, line: UInt = #line) async -> HTTPClient.Result {
		values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
		
		let sut = makeSUT(file: file, line: line)
		
		return await withCheckedContinuation { continuation in
			taskHandler(sut.get(from: anyURL()) { result in
				continuation.resume(returning: result)
			})
		}
	}
	
	private func anyHTTPURLResponse() -> HTTPURLResponse {
		return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
	}
	
	private func nonHTTPURLResponse() -> URLResponse {
		return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
	}
	
}

private func assertNotNil(_ value: Any?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
	XCTAssertNotNil(value, message(), file: file, line: line)
}
