//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore {
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	public init(storeURL: URL) throws {
		let bundle = Bundle(for: CoreDataFeedStore.self)
		container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
		context = container.newBackgroundContext()
	}

	func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform { action(context) }
	}
}
