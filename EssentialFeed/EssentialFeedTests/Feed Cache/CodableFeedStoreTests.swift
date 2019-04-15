//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		completion(.empty)
	}
}

class CodableFeedStoreTests: XCTestCase {
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = CodableFeedStore()
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { result in
			switch result {
			case .empty:
				break
				
			default:
				XCTFail("Expected empty result, got \(result) instead")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = CodableFeedStore()
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { firstResult in
			sut.retrieve { secondResult in
				switch (firstResult, secondResult) {
				case (.empty, .empty):
					break
					
				default:
					XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
				}
				
				exp.fulfill()
			}
		}
		
		wait(for: [exp], timeout: 1.0)
	}
}
