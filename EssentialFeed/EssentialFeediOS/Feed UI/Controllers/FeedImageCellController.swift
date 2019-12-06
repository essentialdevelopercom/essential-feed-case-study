//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
	func didRequestImage()
	func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView {
	private let delegate: FeedImageCellControllerDelegate
	private var cell: FeedImageCell?
	
	public init(delegate: FeedImageCellControllerDelegate) {
		self.delegate = delegate
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		delegate.didRequestImage()
		return cell!
	}
	
	func preload() {
		delegate.didRequestImage()
	}
	
	func cancelLoad() {
		releaseCellForReuse()
		delegate.didCancelImageRequest()
	}
	
	public func display(_ viewModel: FeedImageViewModel<UIImage>) {
		cell?.locationContainer.isHidden = !viewModel.hasLocation
		cell?.locationLabel.text = viewModel.location
		cell?.descriptionLabel.text = viewModel.description
		cell?.feedImageView.setImageAnimated(viewModel.image)
		cell?.feedImageContainer.isShimmering = viewModel.isLoading
		cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
		cell?.onRetry = delegate.didRequestImage
	}
	
	private func releaseCellForReuse() {
		cell = nil
	}
}
