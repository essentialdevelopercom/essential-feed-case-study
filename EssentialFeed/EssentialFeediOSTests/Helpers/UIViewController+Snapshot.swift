//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit

extension UIViewController {
	func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
		return SnapshotWindow(configuration: configuration, root: self).snapshot()
	}
}

struct SnapshotConfiguration {
	let size: CGSize
	let safeAreaInsets: UIEdgeInsets
	let layoutMargins: UIEdgeInsets
	let traitCollection: UITraitCollection
	
	static func iPhone13(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
		return SnapshotConfiguration(
			size: CGSize(width: 390, height: 844),
			safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
			layoutMargins: UIEdgeInsets(top: 55, left: 8, bottom: 42, right: 8),
			traitCollection: UITraitCollection(traitsFrom: [
				.init(forceTouchCapability: .unavailable),
				.init(layoutDirection: .leftToRight),
				.init(preferredContentSizeCategory: contentSize),
				.init(userInterfaceIdiom: .phone),
				.init(horizontalSizeClass: .compact),
				.init(verticalSizeClass: .regular),
				.init(displayScale: 3),
				.init(accessibilityContrast: .normal),
				.init(displayGamut: .P3),
				.init(userInterfaceStyle: style)
			]))
	}
}

private final class SnapshotWindow: UIWindow {
	private var configuration: SnapshotConfiguration = .iPhone13(style: .light)
	
	convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
		self.init(frame: CGRect(origin: .zero, size: configuration.size))
		self.configuration = configuration
		self.layoutMargins = configuration.layoutMargins
		self.rootViewController = root
		self.isHidden = false
		root.view.layoutMargins = configuration.layoutMargins
	}
	
	override var safeAreaInsets: UIEdgeInsets {
		return configuration.safeAreaInsets
	}
	
	override var traitCollection: UITraitCollection {
		return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
	}
	
	func snapshot() -> UIImage {
		let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
		return renderer.image { action in
			layer.render(in: action.cgContext)
		}
	}
}
