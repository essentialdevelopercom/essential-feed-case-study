//
//  Copyright © Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

class SceneDelegateTests: XCTestCase {
	
	func test_configureWindow_setsWindowAsKeyAndVisible() throws {
		let sut = SceneDelegate()

		let window = try UIWindowSpy.make()
		sut.window = window
		
		sut.configureWindow()
		
		XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
	}
	
	func test_configureWindow_configuresRootViewController() throws {
		let sut = SceneDelegate()
		sut.window = try UIWindowSpy.make()

		sut.configureWindow()
		
		let root = sut.window?.rootViewController
		let rootNavigation = root as? UINavigationController
		let topController = rootNavigation?.topViewController
		
		XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
		XCTAssertTrue(topController is ListViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
	}
	
	private class UIWindowSpy: UIWindow {
		var makeKeyAndVisibleCallCount = 0
		
		static func make() throws -> UIWindowSpy {
			let dummyScene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
			return UIWindowSpy(windowScene: dummyScene)
		}
				
		override func makeKeyAndVisible() {
			makeKeyAndVisibleCallCount += 1
		}
	}
	
}
