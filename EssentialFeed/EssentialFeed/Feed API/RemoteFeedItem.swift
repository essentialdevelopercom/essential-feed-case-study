//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteFeedItem: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let image: URL
}
