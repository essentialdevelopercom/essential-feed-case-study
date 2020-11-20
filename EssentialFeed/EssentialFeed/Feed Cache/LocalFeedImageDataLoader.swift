//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public final class LocalFeedImageDataLoader {
	private let store: FeedImageDataStore
	
	public init(store: FeedImageDataStore) {
		self.store = store
	}
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
	public enum SaveError: Error {
		case failed
	}
	
	public func save(_ data: Data, for url: URL) throws {
		do {
			try store.insert(data, for: url)
		} catch {
			throw SaveError.failed
		}
	}
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
	public enum LoadError: Error {
		case failed
		case notFound
	}
		
	public func loadImageData(from url: URL) throws -> Data {
		do {
			if let imageData = try store.retrieve(dataForURL: url) {
				return imageData
			}
		} catch {
			throw LoadError.failed
		}
		
		throw LoadError.notFound
	}
}
