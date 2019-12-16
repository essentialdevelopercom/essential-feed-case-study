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
	
	private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
		let snapshotURL = makeSnapshotURL(named: name, file: file)
		let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

		guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
			XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
			return
		}
		
		if snapshotData != storedSnapshotData {
			let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
				.appendingPathComponent(snapshotURL.lastPathComponent)
			
			try? snapshotData?.write(to: temporarySnapshotURL)
			
			XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
		}
	}
	
	private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
		let snapshotURL = makeSnapshotURL(named: name, file: file)
		let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

		do {
			try FileManager.default.createDirectory(
				at: snapshotURL.deletingLastPathComponent(),
				withIntermediateDirectories: true
			)
			
			try snapshotData?.write(to: snapshotURL)
		} catch {
			XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
		}
	}
	
	private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
		return URL(fileURLWithPath: String(describing: file))
			.deletingLastPathComponent()
			.appendingPathComponent("snapshots")
			.appendingPathComponent("\(name).png")
	}
	
	private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
		guard let data = snapshot.pngData() else {
			XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
			return nil
		}
		
		return data
	}
	
}

extension UIViewController {
	func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
		return SnapshotWindow(configuration: configuration, root: self).snapshot()
	}
}

struct SnapshotConfiguration {
	let size: CGSize
	let safeAreaInsets: UIEdgeInsets
	let layoutMargins: UIEdgeInsets
	let traitCollection: UITraitCollection
	
	static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
		return SnapshotConfiguration(
			size: CGSize(width: 375, height: 667),
			safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
			layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
			traitCollection: UITraitCollection(traitsFrom: [
				.init(forceTouchCapability: .available),
				.init(layoutDirection: .leftToRight),
				.init(preferredContentSizeCategory: .medium),
				.init(userInterfaceIdiom: .phone),
				.init(horizontalSizeClass: .compact),
				.init(verticalSizeClass: .regular),
				.init(displayScale: 2),
				.init(displayGamut: .P3),
				.init(userInterfaceStyle: style)
			]))
	}
}

private final class SnapshotWindow: UIWindow {
	private var configuration: SnapshotConfiguration = .iPhone8(style: .light)
	
	convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
		self.init(frame: CGRect(origin: .zero, size: configuration.size))
		self.configuration = configuration
		self.layoutMargins = configuration.layoutMargins
		self.rootViewController = root
		self.isHidden = false
		root.view.layoutMargins = configuration.layoutMargins
	}
	
	override var safeAreaInsets: UIEdgeInsets {
		return configuration.safeAreaInsets
	}
	
	override var traitCollection: UITraitCollection {
		return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
	}

	func snapshot() -> UIImage {
		let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
		return renderer.image { action in
			layer.render(in: action.cgContext)
		}
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
