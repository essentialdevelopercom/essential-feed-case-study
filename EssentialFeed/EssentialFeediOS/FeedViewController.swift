//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageDataLoader {
	func loadImageData(from url: URL)
	func cancelImageDataLoad(from url: URL)
}

final public class FeedViewController: UITableViewController {
	private var feedLoader: FeedLoader?
	private var imageLoader: FeedImageDataLoader?
	private var tableModel = [FeedImage]()

	public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
		self.init()
		self.feedLoader = feedLoader
		self.imageLoader = imageLoader
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
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
		imageLoader?.loadImageData(from: cellModel.url)
		return cell
	}
	
	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cellModel = tableModel[indexPath.row]
		imageLoader?.cancelImageDataLoad(from: cellModel.url)
	}
}
