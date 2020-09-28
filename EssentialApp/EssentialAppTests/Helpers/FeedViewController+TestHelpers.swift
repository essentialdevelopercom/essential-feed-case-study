//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
	func simulateUserInitiatedFeedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	@discardableResult
	func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
		return feedImageView(at: index) as? FeedImageCell
	}
	
	@discardableResult
	func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
		let view = simulateFeedImageViewVisible(at: row)
		
		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedImagesSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
		
		return view
	}
	
	func simulateFeedImageViewNearVisible(at row: Int) {
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImagesSection)
		ds?.tableView(tableView, prefetchRowsAt: [index])
	}
	
	func simulateFeedImageViewNotNearVisible(at row: Int) {
		simulateFeedImageViewNearVisible(at: row)
		
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImagesSection)
		ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
	}
	
	func renderedFeedImageData(at index: Int) -> Data? {
		return simulateFeedImageViewVisible(at: index)?.renderedImage
	}

    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
	var errorMessage: String? {
		return errorView.message
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 :  tableView.numberOfRows(inSection: feedImagesSection)
	}
	
	func feedImageView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedFeedImageViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedImagesSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	private var feedImagesSection: Int {
		return 0
	}
}
