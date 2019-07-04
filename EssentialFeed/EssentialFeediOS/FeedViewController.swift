//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask {
	func cancel()
}

public protocol FeedImageDataLoader {
	typealias Result = Swift.Result<Data, Error>

	func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
	private var feedLoader: FeedLoader?
	private var imageLoader: FeedImageDataLoader?
	private var tableModel = [FeedImage]()
	private var tasks = [IndexPath: FeedImageDataLoaderTask]()

	public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
		self.init()
		self.feedLoader = feedLoader
		self.imageLoader = imageLoader
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		tableView.prefetchDataSource = self
		load()
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		feedLoader?.load { [weak self] result in
			if let feed = try? result.get() {
				self?.tableModel = feed
				self?.tableView.reloadData()
			}
			self?.refreshControl?.endRefreshing()
		}
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellModel = tableModel[indexPath.row]
		let cell = FeedImageCell()
		cell.locationContainer.isHidden = (cellModel.location == nil)
		cell.locationLabel.text = cellModel.location
		cell.descriptionLabel.text = cellModel.description
		cell.feedImageView.image = nil
		cell.feedImageRetryButton.isHidden = true
		cell.feedImageContainer.startShimmering()
		
		let loadImage = { [weak self, weak cell] in
			guard let self = self else { return }

			self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
				let data = try? result.get()
				let image = data.map(UIImage.init) ?? nil
				cell?.feedImageView.image = image
				cell?.feedImageRetryButton.isHidden = (image != nil)
				cell?.feedImageContainer.stopShimmering()
			}
		}
		
		cell.onRetry = loadImage
		loadImage()
		
		return cell
	}
	
	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		tasks[indexPath]?.cancel()
		tasks[indexPath] = nil
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let cellModel = tableModel[indexPath.row]
			_ = imageLoader?.loadImageData(from: cellModel.url) { _ in }
		}
	}
}
