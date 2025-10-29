//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public protocol HTTPClient {
	func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
