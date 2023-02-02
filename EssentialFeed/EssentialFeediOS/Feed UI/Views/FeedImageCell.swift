//
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
	@IBOutlet private(set) public var locationContainer: UIView!
	@IBOutlet private(set) public var locationLabel: UILabel!
	@IBOutlet private(set) public var feedImageContainer: UIView!
	@IBOutlet private(set) public var feedImageView: UIImageView!
	@IBOutlet private(set) public var feedImageRetryButton: UIButton!
	@IBOutlet private(set) public var descriptionLabel: UILabel!
	
	var onRetry: (() -> Void)?
	var onReuse: (() -> Void)?
	
	@IBAction private func retryButtonTapped() {
		onRetry?()
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		
		onReuse?()
	}
}
