//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		
		setupEmptyStoreState()
	}
	
	override func tearDown() {
		super.tearDown()
		
		undoStoreSideEffects()
	}
	
	// MARK: - LocalFeedLoader Tests
	
	func test_loadFeed_deliversNoItemsOnEmptyCache() {
		let feedLoader = makeFeedLoader()
		
		expect(feedLoader, toLoad: [])
	}
	
	func test_loadFeed_deliversItemsSavedOnASeparateInstance() {
		let feedLoaderToPerformSave = makeFeedLoader()
		let feedLoaderToPerformLoad = makeFeedLoader()
		let feed = uniqueImageFeed().models
		
		save(feed, with: feedLoaderToPerformSave)
		
		expect(feedLoaderToPerformLoad, toLoad: feed)
	}
	
	func test_saveFeed_overridesItemsSavedOnASeparateInstance() {
		let feedLoaderToPerformFirstSave = makeFeedLoader()
		let feedLoaderToPerformLastSave = makeFeedLoader()
		let feedLoaderToPerformLoad = makeFeedLoader()
		let firstFeed = uniqueImageFeed().models
		let latestFeed = uniqueImageFeed().models
		
		save(firstFeed, with: feedLoaderToPerformFirstSave)
		save(latestFeed, with: feedLoaderToPerformLastSave)
		
		expect(feedLoaderToPerformLoad, toLoad: latestFeed)
	}
	
	func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
		let feedLoaderToPerformSave = makeFeedLoader()
		let feedLoaderToPerformValidation = makeFeedLoader()
		let feed = uniqueImageFeed().models
		
		save(feed, with: feedLoaderToPerformSave)
		validateCache(with: feedLoaderToPerformValidation)
		
		expect(feedLoaderToPerformSave, toLoad: feed)
	}
	
	func test_validateFeedCache_deletesFeedSavedInADistantPast() {
		let feedLoaderToPerformSave = makeFeedLoader(currentDate: .distantPast)
		let feedLoaderToPerformValidation = makeFeedLoader(currentDate: Date())
		let feed = uniqueImageFeed().models
		
		save(feed, with: feedLoaderToPerformSave)
		validateCache(with: feedLoaderToPerformValidation)
		
		expect(feedLoaderToPerformSave, toLoad: [])
	}
	
	// MARK: - LocalFeedImageDataLoader Tests
	
	func test_loadImageData_deliversSavedDataOnASeparateInstance() {
		let imageLoaderToPerformSave = makeImageLoader()
		let imageLoaderToPerformLoad = makeImageLoader()
		let feedLoader = makeFeedLoader()
		let image = uniqueImage()
		let dataToSave = anyData()
		
		save([image], with: feedLoader)
		save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
		
		expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
	}
	
	func test_saveImageData_overridesSavedImageDataOnASeparateInstance() {
		let imageLoaderToPerformFirstSave = makeImageLoader()
		let imageLoaderToPerformLastSave = makeImageLoader()
		let imageLoaderToPerformLoad = makeImageLoader()
		let feedLoader = makeFeedLoader()
		let image = uniqueImage()
		let firstImageData = Data("first".utf8)
		let lastImageData = Data("last".utf8)
		
		save([image], with: feedLoader)
		save(firstImageData, for: image.url, with: imageLoaderToPerformFirstSave)
		save(lastImageData, for: image.url, with: imageLoaderToPerformLastSave)
		
		expect(imageLoaderToPerformLoad, toLoad: lastImageData, for: image.url)
	}
	
	// MARK: - Helpers
	
	private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
		let storeURL = testSpecificStoreURL()
		let store = try! CoreDataFeedStore(storeURL: storeURL)
		let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func makeImageLoader(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedImageDataLoader {
		let storeURL = testSpecificStoreURL()
		let store = try! CoreDataFeedStore(storeURL: storeURL)
		let sut = LocalFeedImageDataLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
		let saveExp = expectation(description: "Wait for save completion")
		loader.save(feed) { result in
			if case let Result.failure(error) = result {
				XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
			}
			saveExp.fulfill()
		}
		wait(for: [saveExp], timeout: 1.0)
	}
	
	private func validateCache(with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
		let saveExp = expectation(description: "Wait for save completion")
		loader.validateCache() { result in
			if case let Result.failure(error) = result {
				XCTFail("Expected to validate feed successfully, got error: \(error)", file: file, line: line)
			}
			saveExp.fulfill()
		}
		wait(for: [saveExp], timeout: 1.0)
	}
	
	private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		sut.load { result in
			switch result {
			case let .success(loadedFeed):
				XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
				
			case let .failure(error):
				XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #filePath, line: UInt = #line) {
		do {
			try loader.save(data, for: url)
		} catch {
			XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
		}
	}
	
	private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #filePath, line: UInt = #line) {
		do {
			let loadedData = try sut.loadImageData(from: url)
			XCTAssertEqual(loadedData, expectedData, file: file, line: line)
		} catch {
			XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
		}
	}
	
	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}
	
	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
	
}
