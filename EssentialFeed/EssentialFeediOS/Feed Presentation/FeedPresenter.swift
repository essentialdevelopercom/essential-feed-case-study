//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import EssentialFeed

struct FeedLoadingViewModel {
	let isLoading: Bool
}

protocol FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
	let feed: [FeedImage]
}

protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
	typealias Observer<T> = (T) -> Void
	
	private let feedLoader: FeedLoader
	
	init(feedLoader: FeedLoader) {
		self.feedLoader = feedLoader
	}
	
	var feedView: FeedView?
	var loadingView: FeedLoadingView?
	
	func loadFeed() {
		loadingView?.display(FeedLoadingViewModel(isLoading: true))
		feedLoader.load { [weak self] result in
			if let feed = try? result.get() {
				self?.feedView?.display(FeedViewModel(feed: feed))
			}
			self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
		}
	}
}
