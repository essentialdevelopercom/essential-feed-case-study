//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
	}
	
	// MARK: - Helpers
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Feed"
		let bundle = Bundle(for: FeedPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
}
