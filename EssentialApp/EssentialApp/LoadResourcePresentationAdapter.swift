//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
	private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
	var presenter: LoadResourcePresenter<Resource, View>?
	
	init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
		self.loader = loader
	}
	
	func loadResource() {
		presenter?.didStartLoading()
		
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
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
