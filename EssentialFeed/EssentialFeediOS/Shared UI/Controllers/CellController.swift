//	
// Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit

public struct CellController {
	let id: AnyHashable
	let dataSource: UITableViewDataSource
	let delegate: UITableViewDelegate?
	let dataSourcePrefetching: UITableViewDataSourcePrefetching?
	
	public init(id: AnyHashable, _ dataSource: UITableViewDataSource) {
		self.id = id
		self.dataSource = dataSource
		self.delegate = dataSource as? UITableViewDelegate
		self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
	}
}

extension CellController: Equatable {
	public static func == (lhs: CellController, rhs: CellController) -> Bool {
		lhs.id == rhs.id
	}
}

extension CellController: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
