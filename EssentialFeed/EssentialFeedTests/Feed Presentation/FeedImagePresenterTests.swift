//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel {
	let description: String?
	let location: String?
	let image: Any?
	let isLoading: Bool
	let shouldRetry: Bool
	
	var hasLocation: Bool {
		return location != nil
	}
}

protocol FeedImageView {
	func display(_ model: FeedImageViewModel)
}

class FeedImagePresenter {
	private let view: FeedImageView
	private let imageTransformer: (Data) -> Any?

	init(view: FeedImageView, imageTransformer: @escaping (Data) -> Any?) {
		self.view = view
		self.imageTransformer = imageTransformer
	}
	
	func didStartLoadingImageData(for model: FeedImage) {
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: nil,
			isLoading: true,
			shouldRetry: false))
	}
	
	func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: imageTransformer(data),
			isLoading: false,
			shouldRetry: true))
	}
}

class FeedImagePresenterTests: XCTestCase {
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingImageData_displaysLoadingImage() {
		let (sut, view) = makeSUT()
		let image = uniqueImage()
		
		sut.didStartLoadingImageData(for: image)
		
		let message = view.messages.first
		XCTAssertEqual(view.messages.count, 1)
		XCTAssertEqual(message?.description, image.description)
		XCTAssertEqual(message?.location, image.location)
		XCTAssertEqual(message?.isLoading, true)
		XCTAssertEqual(message?.shouldRetry, false)
		XCTAssertNil(message?.image)
	}
	
	func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
		let (sut, view) = makeSUT(imageTransformer: { _ in nil })
		let image = uniqueImage()
		let data = Data()
		
		sut.didFinishLoadingImageData(with: data, for: image)
		
		let message = view.messages.first
		XCTAssertEqual(view.messages.count, 1)
		XCTAssertEqual(message?.description, image.description)
		XCTAssertEqual(message?.location, image.location)
		XCTAssertEqual(message?.isLoading, false)
		XCTAssertEqual(message?.shouldRetry, true)
		XCTAssertNil(message?.image)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		imageTransformer: @escaping (Data) -> Any? = { _ in nil },
		file: StaticString = #file,
		line: UInt = #line
	) -> (sut: FeedImagePresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private class ViewSpy: FeedImageView {
		private(set) var messages = [FeedImageViewModel]()
		
		func display(_ model: FeedImageViewModel) {
			messages.append(model)
		}
	}

}
