//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
	internal let id: UUID
	internal let description: String?
	internal let location: String?
	internal let image: URL
}
