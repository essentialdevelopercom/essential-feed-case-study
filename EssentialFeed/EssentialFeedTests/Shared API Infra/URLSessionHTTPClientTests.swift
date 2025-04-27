//
// Copyright © Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class URLSessionHTTPClientTests: XCTestCase {
  // Dummy para cumplir el protocolo HTTPClient en tests
  private class HTTPClientDummy: HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
      fatalError("Not implemented")
    }
    func post(
      to url: URL, body: [String: String], completion: @escaping (HTTPClient.Result) -> Void
    ) -> HTTPClientTask {
      fatalError("Not implemented for tests")
    }
  }

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

  func test_cancelGetFromURLTask_cancelsURLRequest() {
    let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?

    XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
  }

  func test_getFromURL_failsOnRequestError() {
    let requestError = anyNSError()

    let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))

    XCTAssertNotNil(receivedError)
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

  private func makeSUT(
    session: URLSession? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> HTTPClient {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [URLProtocolStub.self]
    let session = session ?? URLSession(configuration: configuration)
    let sut = URLSessionHTTPClient(session: session)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut as HTTPClient
}

  private func result(_ values: (Data, HTTPURLResponse)? = nil, error: Error? = nil)
    -> HTTPClient.Result
  {
    switch (values, error) {
    case let (.some((data, response)), _):
      return .success((data, response))
    case let (_, .some(error)):
      return .failure(error)
    default:
      return .failure(anyNSError())
    }
  }

  private func resultValuesFor(
    _ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath,
    line: UInt = #line
  ) -> (data: Data, response: HTTPURLResponse)? {
    let result = resultFor(values, file: file, line: line)
    switch result {
    case let .success((data, response)):
      return (data, response)
    default:
      XCTFail("Expected success, got \(result) instead", file: file, line: line)
      return nil
    }
  }

  private func resultErrorFor(
    _ values: (data: Data?, response: URLResponse?, error: Error?)? = nil,
    taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath,
    line: UInt = #line
  ) -> Error? {
    let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)

    switch result {
    case let .failure(error):
      return error
    default:
      XCTFail("Expected failure, got \(result) instead", file: file, line: line)
      return nil
    }
  }

  private func resultFor(
    _ values: (data: Data?, response: URLResponse?, error: Error?)?,
    taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath,
    line: UInt = #line
  ) -> HTTPClient.Result {
    values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }

    let sut = makeSUT(file: file, line: line)
    let exp = expectation(description: "Wait for completion")

    var receivedResult: HTTPClient.Result!
    taskHandler(
      sut.get(from: anyURL()) { result in
        receivedResult = result
        exp.fulfill()
      })

    wait(for: [exp], timeout: 1.0)
    return receivedResult
  }

  private func anyHTTPURLResponse() -> HTTPURLResponse {
    return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
  }

  private func nonHTTPURLResponse() -> URLResponse {
    return URLResponse(
      url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
  }
}
