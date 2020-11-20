//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
	private weak var controller: ListViewController?
	private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
	private let selection: (FeedImage) -> Void
	private let currentFeed: [FeedImage: CellController]
	
	private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
	private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
	
	init(currentFeed: [FeedImage: CellController] = [:], controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
		self.currentFeed = currentFeed
		self.controller = controller
		self.imageLoader = imageLoader
		self.selection = selection
	}
	
	func display(_ viewModel: Paginated<FeedImage>) {
		guard let controller = controller else { return }
		
		var currentFeed = self.currentFeed
		let feed: [CellController] = viewModel.items.map { model in
			if let controller = currentFeed[model] {
				return controller
			}
			
			let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
				imageLoader(model.url)
			})
			
			let view = FeedImageCellController(
				viewModel: FeedImagePresenter.map(model),
				delegate: adapter,
				selection: { [selection] in
					selection(model)
				})
			
			adapter.presenter = LoadResourcePresenter(
				resourceView: WeakRefVirtualProxy(view),
				loadingView: WeakRefVirtualProxy(view),
				errorView: WeakRefVirtualProxy(view),
				mapper: UIImage.tryMake)
			
			let controller = CellController(id: model, view)
			currentFeed[model] = controller
			return controller
		}
		
		guard let loadMorePublisher = viewModel.loadMorePublisher else {
			controller.display(feed)
			return
		}
		
		let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
		let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
		
		loadMoreAdapter.presenter = LoadResourcePresenter(
			resourceView: FeedViewAdapter(
				currentFeed: currentFeed,
				controller: controller,
				imageLoader: imageLoader,
				selection: selection
			),
			loadingView: WeakRefVirtualProxy(loadMore),
			errorView: WeakRefVirtualProxy(loadMore))
		
		let loadMoreSection = [CellController(id: UUID(), loadMore)]
		
		controller.display(feed, loadMoreSection)
	}
}

extension UIImage {
	struct InvalidImageData: Error {}
	
	static func tryMake(data: Data) throws -> UIImage {
		guard let image = UIImage(data: data) else {
			throw InvalidImageData()
		}
		return image
	}
}
