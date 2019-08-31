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
