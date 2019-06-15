//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

extension FeedImageViewModel {
	static var prototypeFeed: [FeedImageViewModel] {
		return [
			FeedImageViewModel(
				description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
				location: "East Side Gallery\nMemorial in Berlin, Germany",
				imageName: "image-0"
			),
			FeedImageViewModel(
				description: nil,
				location: "Cannon Street, London",
				imageName: "image-1"
			),
			FeedImageViewModel(
				description: "The Desert Island in Faro is beautiful!! ☀️",
				location: nil,
				imageName: "image-2"
			),
			FeedImageViewModel(
				description: nil,
				location: nil,
				imageName: "image-3"
			),
			FeedImageViewModel(
				description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales. At 1,500 feet in length, it is the second-longest pier in Wales, and the ninth longest in the British Isles.",
				location: "Garth Pier\nNorth Wales",
				imageName: "image-4"
			),
			FeedImageViewModel(
				description: "Glorious day in Brighton!! 🎢",
				location: "Brighton Seafront",
				imageName: "image-5"
			)
		]
	}
}
