//
//  Copyright © Essential Developer. All rights reserved.
//

import UIKit

extension UIView {
	func enforceLayoutCycle() {
		layoutIfNeeded()
		RunLoop.current.run(until: Date())
	}
}
