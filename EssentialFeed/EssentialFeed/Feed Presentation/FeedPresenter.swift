//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public final class FeedPresenter {
	public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
			tableName: "Feed",
			bundle: Bundle(for: FeedPresenter.self),
			comment: "Title for the feed view")
	}
}
