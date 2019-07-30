//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
	private init() {}
	
	public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
		let feedViewModel = FeedViewModel(feedLoader: feedLoader)
		let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
		let feedController = FeedViewController(refreshController: refreshController)
		feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
		return feedController
	}
	
	private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
		return { [weak controller] feed in
			controller?.tableModel = feed.map { model in
				FeedImageCellController(viewModel:
					FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
			}
		}
	}
}
