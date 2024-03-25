//
//  Copyright © Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	enum StoreError: Error {
		case modelNotFound
		case failedToLoadPersistentContainer(Error)
	}
	
	public enum ContextQueue {
		case main
		case background
	}
	
	public var contextQueue: ContextQueue {
		context == container.viewContext ? .main : .background
	}
	
	public init(storeURL: URL, contextQueue: ContextQueue = .background) throws {
		guard let model = CoreDataFeedStore.model else {
			throw StoreError.modelNotFound
		}
		
		do {
			container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
			context = contextQueue == .main ? container.viewContext : container.newBackgroundContext()
		} catch {
			throw StoreError.failedToLoadPersistentContainer(error)
		}
	}
	
	func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
		let context = self.context
		var result: Result<R, Error>!
		context.performAndWait { result = action(context) }
		return try result.get()
	}
	
	public func perform(_ action: @escaping () -> Void) {
		context.perform(action)
	}
	
	private func cleanUpReferencesToPersistentStores() {
		context.performAndWait {
			let coordinator = self.container.persistentStoreCoordinator
			try? coordinator.persistentStores.forEach(coordinator.remove)
		}
	}
	
	deinit {
		cleanUpReferencesToPersistentStores()
	}
}
