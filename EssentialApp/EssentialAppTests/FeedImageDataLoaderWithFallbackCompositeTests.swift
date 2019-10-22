//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
	
	func test_init_doesNotLoadImageData() {
		let (_, primaryLoader, fallbackLoader) = makeSUT()

		XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}
	
	func test_loadImageData_loadsFromPrimaryLoaderFirst() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()

		_ = sut.loadImageData(from: url) { _ in }
		
		XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}
	
	func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()

		_ = sut.loadImageData(from: url) { _ in }
		
		primaryLoader.complete(with: anyNSError())
		
		XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
		XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
	}
	
	func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()

		let task = sut.loadImageData(from: url) { _ in }
		task.cancel()
		
		XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
		XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the fallback loader")
	}
	
	func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()

		let task = sut.loadImageData(from: url) { _ in }
		primaryLoader.complete(with: anyNSError())
		task.cancel()
		
		XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the primary loader")
		XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancel URL loading from fallback loader")
	}
		
	func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
		let primaryData = anyData()
		let (sut, primaryLoader, _) = makeSUT()
		
		expect(sut, toCompleteWith: .success(primaryData), when: {
			primaryLoader.complete(with: primaryData)
		})
	}
	
	func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
		let fallbackData = anyData()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		expect(sut, toCompleteWith: .success(fallbackData), when: {
			primaryLoader.complete(with: anyNSError())
			fallbackLoader.complete(with: fallbackData)
		})
	}
	
	func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(anyNSError()), when: {
			primaryLoader.complete(with: anyNSError())
			fallbackLoader.complete(with: anyNSError())
		})
	}

	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy) {
		let primaryLoader = LoaderSpy()
		let fallbackLoader = LoaderSpy()
		let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
		trackForMemoryLeaks(primaryLoader, file: file, line: line)
		trackForMemoryLeaks(fallbackLoader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, primaryLoader, fallbackLoader)
	}
	
	private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		_ = sut.loadImageData(from: anyURL()) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedFeed), .success(expectedFeed)):
				XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
				
			case (.failure, .failure):
				break
				
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private class LoaderSpy: FeedImageDataLoader {
		private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

		private(set) var cancelledURLs = [URL]()

		var loadedURLs: [URL] {
			return messages.map { $0.url }
		}

		private struct Task: FeedImageDataLoaderTask {
			let callback: () -> Void
			func cancel() { callback() }
		}

		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			messages.append((url, completion))
			return Task { [weak self] in
				self?.cancelledURLs.append(url)
			}
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func complete(with data: Data, at index: Int = 0) {
			messages[index].completion(.success(data))
		}
	}
	
}
