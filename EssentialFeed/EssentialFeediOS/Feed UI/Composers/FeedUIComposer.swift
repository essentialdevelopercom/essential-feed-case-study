//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
	private init() {}
	
	public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
		let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader:
			MainQueueDispatchDecorator(decoratee: feedLoader))
		
		let feedController = FeedViewController.makeWith(
			delegate: presentationAdapter,
			title: FeedPresenter.title)

		presentationAdapter.presenter = FeedPresenter(
			feedView: FeedViewAdapter(
				controller: feedController,
				imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
			loadingView: WeakRefVirtualProxy(feedController))
		
		return feedController
	}
}

private extension FeedViewController {
	static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
		feedController.delegate = delegate
		feedController.title = title
		return feedController
	}
}

private final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: FeedImageDataLoader
	
	init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
		self.controller = controller
		self.imageLoader = imageLoader
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.tableModel = viewModel.feed.map { model in
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
			let view = FeedImageCellController(delegate: adapter)
			
			adapter.presenter = FeedImagePresenter(
				view: WeakRefVirtualProxy(view),
				imageTransformer: UIImage.init)
			
			return view
		}
	}
}
