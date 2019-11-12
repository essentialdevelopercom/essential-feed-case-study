//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest

class EssentialAppUIAcceptanceTests: XCTestCase {
	
	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let app = XCUIApplication()
		
		app.launch()
		
		let feedCells = app.cells.matching(identifier: "feed-image-cell")
		XCTAssertEqual(feedCells.count, 22)
		
		let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
		XCTAssertTrue(firstImage.exists)
	}
	
	func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
		let onlineApp = XCUIApplication()
		onlineApp.launch()

		let offlineApp = XCUIApplication()
		offlineApp.launchArguments = ["-connectivity", "offline"]
		offlineApp.launch()

		let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
		XCTAssertEqual(cachedFeedCells.count, 22)
		
		let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
		XCTAssertTrue(firstCachedImage.exists)
	}
	
}
