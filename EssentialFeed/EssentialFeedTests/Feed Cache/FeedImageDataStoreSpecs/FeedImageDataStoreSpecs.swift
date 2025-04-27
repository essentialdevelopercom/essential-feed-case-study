//
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

protocol FeedImageDataStoreSpecs {
	func test_retrieveImageData_deliversNotFoundWhenEmpty() throws
	func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() throws
	func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() throws
	func test_retrieveImageData_deliversLastInsertedValue() throws
}
