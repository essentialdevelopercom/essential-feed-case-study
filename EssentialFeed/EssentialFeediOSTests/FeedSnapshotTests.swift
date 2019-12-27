//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedSnapshotTests: XCTestCase {
	
	func test_emptyFeed() {
		let sut = makeSUT()
		
		sut.display(emptyFeed())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_dark")
	}
	
	func test_feedWithContent() {
		let sut = makeSUT()
		
		sut.display(feedWithContent())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
	}
	
	func test_feedWithErrorMessage() {
		let sut = makeSUT()

		sut.display(.error(message: "This is a\nmulti-line\nerror message"))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_dark")
	}
	
	func test_feedWithFailedImageLoading() {
		let sut = makeSUT()

		sut.display(feedWithFailedImageLoading())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
	}
	
	// MARK: - Helpers

	private func makeSUT() -> FeedViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyFeed() -> [FeedImageCellController] {
		return []
	}
	
	private func feedWithContent() -> [ImageStub] {
		return [
			ImageStub(
				description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
				location: "East Side Gallery\nMemorial in Berlin, Germany",
				image: UIImage.make(withColor: .red)
			),
			ImageStub(
				description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
				location: "Garth Pier",
				image: UIImage.make(withColor: .green)
			)
		]
	}
	
	private func feedWithFailedImageLoading() -> [ImageStub] {
		return [
			ImageStub(
				description: nil,
				location: "Cannon Street, London",
				image: nil
			),
			ImageStub(
				description: nil,
				location: "Brighton Seafront",
				image: nil
			)
		]
	}
	
}

private extension FeedViewController {
	func display(_ stubs: [ImageStub]) {
		let cells: [FeedImageCellController] = stubs.map { stub in
			let cellController = FeedImageCellController(delegate: stub)
			stub.controller = cellController
			return cellController
		}
		
		display(cells)
	}
}

private class ImageStub: FeedImageCellControllerDelegate {
	let viewModel: FeedImageViewModel<UIImage>
	weak var controller: FeedImageCellController?

	init(description: String?, location: String?, image: UIImage?) {
		viewModel = FeedImageViewModel(
			description: description,
			location: location,
			image: image,
			isLoading: false,
			shouldRetry: image == nil)
	}
	
	func didRequestImage() {
		controller?.display(viewModel)
	}
	
	func didCancelImageRequest() {}
}
