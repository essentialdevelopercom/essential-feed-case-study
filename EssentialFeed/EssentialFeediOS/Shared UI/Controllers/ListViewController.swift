//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
	@IBOutlet private(set) public var errorView: ErrorView?

    private var loadingControllers = [IndexPath: CellController]()
    
	private var tableModel = [CellController]() {
		didSet { tableView.reloadData() }
	}

	public var onRefresh: (() -> Void)?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.sizeTableHeaderToFit()
	}
	
	@IBAction private func refresh() {
        onRefresh?()
	}
	
	public func display(_ cellControllers: [CellController]) {
        loadingControllers = [:]
		tableModel = cellControllers
	}

	public func display(_ viewModel: ResourceLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: ResourceErrorViewModel) {
		errorView?.message = viewModel.message
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let controller = cellController(forRowAt: indexPath)
        return controller.tableView(tableView, cellForRowAt: indexPath)
	}
	
	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(forRowAt: indexPath)
        controller?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath)
            controller.tableView(tableView, prefetchRowsAt: [indexPath])
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = removeLoadingController(forRowAt: indexPath)
            controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
	}
	
	private func cellController(forRowAt indexPath: IndexPath) -> CellController {
		let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
	}
	
	private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellController? {
		let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
	}
}
