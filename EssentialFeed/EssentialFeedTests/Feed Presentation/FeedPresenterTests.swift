//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
	}

	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()

		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()

		sut.didStartLoadingFeed()

		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
		let (sut, view) = makeSUT()
		let feed = uniqueImageFeed().models
		
		sut.didFinishLoadingFeed(with: feed)
		
		XCTAssertEqual(view.messages, [
			.display(feed: feed),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingFeed(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers

	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}

	private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
		let table = "Feed"
		let bundle = Bundle(for: FeedPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

	private class ViewSpy: FeedView, FeedLoadingView, FeedErrorView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(feed: [FeedImage])
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: FeedErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: FeedLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: FeedViewModel) {
			messages.insert(.display(feed: viewModel.feed))
		}
	}

}
