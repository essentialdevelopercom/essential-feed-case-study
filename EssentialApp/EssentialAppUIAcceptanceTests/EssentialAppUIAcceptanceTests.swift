//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest

class EssentialAppUIAcceptanceTests: XCTestCase {
	
	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let app = XCUIApplication()
		
		app.launch()
		
		XCTAssertEqual(app.cells.count, 22)
		XCTAssertEqual(app.cells.firstMatch.images.count, 1)
	}
	
}
