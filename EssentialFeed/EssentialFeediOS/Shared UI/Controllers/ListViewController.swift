//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
	private(set) public var errorView = ErrorView()
	
	private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
		.init(tableView: tableView) { (tableView, index, controller) in
			controller.dataSource.tableView(tableView, cellForRowAt: index)
		}
	}()
	
	public var onRefresh: (() -> Void)?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		configureTableView()
		refresh()
	}
	
	private func configureTableView() {
		dataSource.defaultRowAnimation = .fade
		tableView.dataSource = dataSource
		tableView.tableHeaderView = errorView.makeContainer()
		
		errorView.onHide = { [weak self] in
			self?.tableView.beginUpdates()
			self?.tableView.sizeTableHeaderToFit()
			self?.tableView.endUpdates()
		}
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
		if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
			tableView.reloadData()
		}
	}
	
	@IBAction private func refresh() {
		onRefresh?()
	}
	
	public func display(_ sections: [CellController]...) {
		var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
		sections.enumerated().forEach { section, cellControllers in
			snapshot.appendSections([section])
			snapshot.appendItems(cellControllers, toSection: section)
		}
		dataSource.apply(snapshot)
	}
	
	public func display(_ viewModel: ResourceLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: ResourceErrorViewModel) {
		errorView.message = viewModel.message
	}
	
	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let dl = cellController(at: indexPath)?.delegate
		dl?.tableView?(tableView, didSelectRowAt: indexPath)
	}
	
	public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let dl = cellController(at: indexPath)?.delegate
		dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
	}
	
	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let dl = cellController(at: indexPath)?.delegate
		dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let dsp = cellController(at: indexPath)?.dataSourcePrefetching
			dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let dsp = cellController(at: indexPath)?.dataSourcePrefetching
			dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
		}
	}
	
	private func cellController(at indexPath: IndexPath) -> CellController? {
		dataSource.itemIdentifier(for: indexPath)
	}
}
