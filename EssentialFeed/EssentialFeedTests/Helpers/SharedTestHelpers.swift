//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

func anyNSError() -> NSError {
	return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
	return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
	return Data("any data".utf8)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
	let json = ["items": items]
	return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
	convenience init(statusCode: Int) {
		self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
	}
}

extension Date {
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
	
	func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
		return calendar.date(byAdding: .minute, value: minutes, to: self)!
	}
	
	func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
		return calendar.date(byAdding: .day, value: days, to: self)!
	}
}
