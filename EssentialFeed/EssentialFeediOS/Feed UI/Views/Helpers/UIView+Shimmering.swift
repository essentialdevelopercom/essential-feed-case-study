//
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

extension UIView {
	public var isShimmering: Bool {
		set {
			if newValue {
				startShimmering()
			} else {
				stopShimmering()
			}
		}
		
		get {
			layer.mask is ShimmeringLayer
		}
	}
	
	private func startShimmering() {
		layer.mask = ShimmeringLayer(size: bounds.size)
	}
	
	private func stopShimmering() {
		layer.mask = nil
	}
	
	private class ShimmeringLayer: CAGradientLayer {
		private var observer: Any?
		
		convenience init(size: CGSize) {
			self.init()
			
			let white = UIColor.white.cgColor
			let alpha = UIColor.white.withAlphaComponent(0.75).cgColor
			
			colors = [alpha, white, alpha]
			startPoint = CGPoint(x: 0.0, y: 0.4)
			endPoint = CGPoint(x: 1.0, y: 0.6)
			locations = [0.4, 0.5, 0.6]
			frame = CGRect(x: -size.width, y: 0, width: size.width*3, height: size.height)
			
			let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
			animation.fromValue = [0.0, 0.1, 0.2]
			animation.toValue = [0.8, 0.9, 1.0]
			animation.duration = 1.25
			animation.repeatCount = .infinity
			add(animation, forKey: "shimmer")
			
			observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
				self?.add(animation, forKey: "shimmer")
			}
		}
	}
}
