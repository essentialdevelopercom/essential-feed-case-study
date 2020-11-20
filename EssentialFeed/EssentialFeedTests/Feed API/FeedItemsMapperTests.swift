//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {
	
	func test_map_throwsErrorOnNon200HTTPResponse() throws {
		let json = makeItemsJSON([])
		let samples = [199, 201, 300, 400, 500]
		
		try samples.forEach { code in
			XCTAssertThrowsError(
				try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
			)
		}
	}
	
	func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
		let invalidJSON = Data("invalid json".utf8)
		
		XCTAssertThrowsError(
			try FeedItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
		)
	}
	
	func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
		let emptyListJSON = makeItemsJSON([])
		
		let result = try FeedItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))
		
		XCTAssertEqual(result, [])
	}
	
	func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
		let item1 = makeItem(
			id: UUID(),
			imageURL: URL(string: "http://a-url.com")!)
		
		let item2 = makeItem(
			id: UUID(),
			description: "a description",
			location: "a location",
			imageURL: URL(string: "http://another-url.com")!)
		
		let json = makeItemsJSON([item1.json, item2.json])
		
		let result = try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))
		
		XCTAssertEqual(result, [item1.model, item2.model])
	}
	
	// MARK: - Helpers
	
	private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
		let item = FeedImage(id: id, description: description, location: location, url: imageURL)
		
		let json = [
			"id": id.uuidString,
			"description": description,
			"location": location,
			"image": imageURL.absoluteString
		].compactMapValues { $0 }
		
		return (item, json)
	}
	
}
