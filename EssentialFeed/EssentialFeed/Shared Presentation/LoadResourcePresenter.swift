//
// Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol ResourceView {
	associatedtype ResourceViewModel
	
	func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
	public typealias Mapper = (Resource) throws -> View.ResourceViewModel
	
	private let resourceView: View
	private let loadingView: ResourceLoadingView
	private let errorView: ResourceErrorView
	private let mapper: Mapper
	
	public static var loadError: String {
		NSLocalizedString("GENERIC_CONNECTION_ERROR",
						  tableName: "Shared",
						  bundle: Bundle(for: Self.self),
						  comment: "Error message displayed when we can't load the resource from the server")
	}
	
	public init(resourceView: View, loadingView: ResourceLoadingView, errorView: ResourceErrorView, mapper: @escaping Mapper) {
		self.resourceView = resourceView
		self.loadingView = loadingView
		self.errorView = errorView
		self.mapper = mapper
	}
	
	public init(resourceView: View, loadingView: ResourceLoadingView, errorView: ResourceErrorView) where Resource == View.ResourceViewModel {
		self.resourceView = resourceView
		self.loadingView = loadingView
		self.errorView = errorView
		self.mapper = { $0 }
	}
	
	public func didStartLoading() {
		errorView.display(.noError)
		loadingView.display(ResourceLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoading(with resource: Resource) {
		do {
			resourceView.display(try mapper(resource))
			loadingView.display(ResourceLoadingViewModel(isLoading: false))
		} catch {
			didFinishLoading(with: error)
		}
	}
	
	public func didFinishLoading(with error: Error) {
		errorView.display(.error(message: Self.loadError))
		loadingView.display(ResourceLoadingViewModel(isLoading: false))
	}
}
