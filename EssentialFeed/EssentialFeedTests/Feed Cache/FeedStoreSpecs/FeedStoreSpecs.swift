//
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

protocol FeedStoreSpecs {
	func test_retrieve_deliversEmptyOnEmptyCache() async throws
	func test_retrieve_hasNoSideEffectsOnEmptyCache() async throws
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() async throws
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() async throws
	
	func test_insert_deliversNoErrorOnEmptyCache() async throws
	func test_insert_deliversNoErrorOnNonEmptyCache() async throws
	func test_insert_overridesPreviouslyInsertedCacheValues() async throws
	
	func test_delete_deliversNoErrorOnEmptyCache() async throws
	func test_delete_hasNoSideEffectsOnEmptyCache() async throws
	func test_delete_deliversNoErrorOnNonEmptyCache() async throws
	func test_delete_emptiesPreviouslyInsertedCache() async throws
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
	func test_retrieve_deliversFailureOnRetrievalError() async throws
	func test_retrieve_hasNoSideEffectsOnFailure() async throws
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
	func test_insert_deliversErrorOnInsertionError() async throws
	func test_insert_hasNoSideEffectsOnInsertionError() async throws
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
	func test_delete_deliversErrorOnDeletionError() async throws
	func test_delete_hasNoSideEffectsOnDeletionError() async throws
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
