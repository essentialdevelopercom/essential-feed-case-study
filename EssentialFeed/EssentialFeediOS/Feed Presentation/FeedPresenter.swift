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
	var feedView: FeedView?
	var loadingView: FeedLoadingView?
	
	func didStartLoadingFeed() {
		loadingView?.display(FeedLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView?.display(FeedViewModel(feed: feed))
		loadingView?.display(FeedLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingFeed(with error: Error) {
		loadingView?.display(FeedLoadingViewModel(isLoading: false))
	}
}
