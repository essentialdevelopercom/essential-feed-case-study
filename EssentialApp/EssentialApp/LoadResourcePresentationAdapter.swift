//
//  Copyright © Essential Developer. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS

@MainActor
final class AsyncLoadResourcePresentationAdapter<Resource, View: ResourceView> {
	private let loader: () async throws -> Resource
	private var cancellable: Task<Void, Never>?
	private var isLoading = false
	
	var presenter: LoadResourcePresenter<Resource, View>?
	
	init(loader: @escaping () async throws -> Resource) {
		self.loader = loader
	}
	
	func loadResource() {
		guard !isLoading else { return }
		
		presenter?.didStartLoading()
		isLoading = true
		
		cancellable = Task.immediate { @MainActor [weak self] in
			defer { self?.isLoading = false }
			
			do {
				if let resource = try await self?.loader() {
					if Task.isCancelled { return }
					
					self?.presenter?.didFinishLoading(with: resource)
				}
			} catch {
				if Task.isCancelled { return }
				
				self?.presenter?.didFinishLoading(with: error)
			}
		}
	}
	
	deinit {
		cancellable?.cancel()
	}
}

extension AsyncLoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
	func didRequestImage() {
		loadResource()
	}
	
	func didCancelImageRequest() {
		cancellable?.cancel()
		cancellable = nil
		isLoading = false
	}
}

@MainActor
final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
	private let loader: () -> AnyPublisher<Resource, Error>
	private var cancellable: Cancellable?
	private var isLoading = false
	
	var presenter: LoadResourcePresenter<Resource, View>?
	
	init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
		self.loader = loader
	}
	
	func loadResource() {
		guard !isLoading else { return }
		
		presenter?.didStartLoading()
		isLoading = true
		
		cancellable = loader()
			.dispatchOnMainThread()
			.handleEvents(receiveCancel: { [weak self] in
				self?.isLoading = false
			})
			.sink(
				receiveCompletion: { [weak self] completion in
					switch completion {
					case .finished: break
						
					case let .failure(error):
						self?.presenter?.didFinishLoading(with: error)
					}
					
					self?.isLoading = false
				}, receiveValue: { [weak self] resource in
					self?.presenter?.didFinishLoading(with: resource)
				})
	}
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
	func didRequestImage() {
		loadResource()
	}
	
	func didCancelImageRequest() {
		cancellable?.cancel()
		cancellable = nil
	}
}
