//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {

	func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
		switch getFeedResult() {
		case let .success(imageFeed)?:
			XCTAssertEqual(imageFeed.count, 8, "Expected 8 images in the test account image feed")
			XCTAssertEqual(imageFeed[0], expectedImage(at: 0))
			XCTAssertEqual(imageFeed[1], expectedImage(at: 1))
			XCTAssertEqual(imageFeed[2], expectedImage(at: 2))
			XCTAssertEqual(imageFeed[3], expectedImage(at: 3))
			XCTAssertEqual(imageFeed[4], expectedImage(at: 4))
			XCTAssertEqual(imageFeed[5], expectedImage(at: 5))
			XCTAssertEqual(imageFeed[6], expectedImage(at: 6))
			XCTAssertEqual(imageFeed[7], expectedImage(at: 7))
			
		case let .failure(error)?:
			XCTFail("Expected successful feed result, got \(error) instead")
			
		default:
			XCTFail("Expected successful feed result, got no result instead")
		}
	}
	
	// MARK: - Helpers
	
	private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> LoadFeedResult? {
		let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
		let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
		let loader = RemoteFeedLoader(url: testServerURL, client: client)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		let exp = expectation(description: "Wait for load completion")
		
		var receivedResult: LoadFeedResult?
		loader.load { result in
			receivedResult = result
			exp.fulfill()
		}
		wait(for: [exp], timeout: 5.0)
		
		return receivedResult
	}
	
	private func expectedImage(at index: Int) -> FeedImage {
		return FeedImage(
			id: id(at: index),
			description: description(at: index),
			location: location(at: index),
			url: imageURL(at: index))
	}
	
	private func id(at index: Int) -> UUID {
		return UUID(uuidString: [
			"73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
			"BA298A85-6275-48D3-8315-9C8F7C1CD109",
			"5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
			"FF0ECFE2-2879-403F-8DBE-A83B4010B340",
			"DC97EF5E-2CC9-4905-A8AD-3C351C311001",
			"557D87F1-25D3-4D77-82E9-364B2ED9CB30",
			"A83284EF-C2DF-415D-AB73-2A9B8B04950B",
			"F79BD7F8-063F-46E2-8147-A67635C3BB01"
		][index])!
	}
	
	private func description(at index: Int) -> String? {
		return [
			"Description 1",
			nil,
			"Description 3",
			nil,
			"Description 5",
			"Description 6",
			"Description 7",
			"Description 8"
		][index]
	}
	
	private func location(at index: Int) -> String? {
		return [
			"Location 1",
			"Location 2",
			nil,
			nil,
			"Location 5",
			"Location 6",
			"Location 7",
			"Location 8"
		][index]
	}
	
	private func imageURL(at index: Int) -> URL {
		return URL(string: "https://url-\(index+1).com")!
	}
}
