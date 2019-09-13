//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct FeedViewModel {
	let feed: [FeedImage]
}

protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

struct FeedLoadingViewModel {
	let isLoading: Bool
}

protocol FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedErrorViewModel {
	let message: String?
	
	static var noError: FeedErrorViewModel {
		return FeedErrorViewModel(message: nil)
	}
}

protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
	private let feedView: FeedView
	private let loadingView: FeedLoadingView
	private let errorView: FeedErrorView
	
	init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
		self.feedView = feedView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	func didStartLoadingFeed() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
}

class FeedPresenterTests: XCTestCase {

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
	
	// MARK: - Helpers

	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
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
