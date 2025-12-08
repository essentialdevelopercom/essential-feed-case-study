//	
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

@MainActor
public protocol ResourceLoadingView {
	func display(_ viewModel: ResourceLoadingViewModel)
}
