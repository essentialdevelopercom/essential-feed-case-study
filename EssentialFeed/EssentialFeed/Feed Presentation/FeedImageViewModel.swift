//
//  Copyright © Essential Developer. All rights reserved.
//

public struct FeedImageViewModel {
	public let description: String?
	public let location: String?
	
	public var hasLocation: Bool {
		return location != nil
	}
}
