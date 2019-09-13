//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageView {
	associatedtype Image
	
	func display(_ model: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
	private let view: View
	private let imageTransformer: (Data) -> Image?
	
	public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
		self.view = view
		self.imageTransformer = imageTransformer
	}
	
	public func didStartLoadingImageData(for model: FeedImage) {
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: nil,
			isLoading: true,
			shouldRetry: false))
	}
	
	public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
		let image = imageTransformer(data)
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: image,
			isLoading: false,
			shouldRetry: image == nil))
	}
	
	public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: nil,
			isLoading: false,
			shouldRetry: true))
	}
}
