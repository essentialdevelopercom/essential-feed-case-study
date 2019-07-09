//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit

extension UIButton {
	func simulateTap() {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}
