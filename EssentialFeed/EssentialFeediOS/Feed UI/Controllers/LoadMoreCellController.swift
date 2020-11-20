//	
// Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
	private let cell = LoadMoreCell()
	private let callback: () -> Void
	private var offsetObserver: NSKeyValueObservation?
	
	public init(callback: @escaping () -> Void) {
		self.callback = callback
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		cell.selectionStyle = .none
		return cell
	}
	
	public func tableView(_ tableView: UITableView, willDisplay: UITableViewCell, forRowAt indexPath: IndexPath) {
		reloadIfNeeded()
		
		offsetObserver = tableView.observe(\.contentOffset, options: .new) { [weak self] (tableView, _) in
			guard tableView.isDragging else { return }
			
			self?.reloadIfNeeded()
		}
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		offsetObserver = nil
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		reloadIfNeeded()
	}
	
	private func reloadIfNeeded() {
		guard !cell.isLoading else { return }
		
		callback()
	}
}

extension LoadMoreCellController: ResourceLoadingView, ResourceErrorView {
	public func display(_ viewModel: ResourceErrorViewModel) {
		cell.message = viewModel.message
	}
	
	public func display(_ viewModel: ResourceLoadingViewModel) {
		cell.isLoading = viewModel.isLoading
	}
}
