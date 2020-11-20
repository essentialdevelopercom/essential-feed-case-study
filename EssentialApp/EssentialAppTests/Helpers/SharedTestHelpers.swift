//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
	return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
	return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
	return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
	return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}

private class DummyView: ResourceView {
	func display(_ viewModel: Any) {}
}

var loadError: String {
	LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
	FeedPresenter.title
}

var commentsTitle: String {
	ImageCommentsPresenter.title
}
