//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest

extension XCTestCase {
	
	func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
		let snapshotURL = makeSnapshotURL(named: name, file: file)
		let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
		
		guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
			XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
			return
		}
		
		if snapshotData != storedSnapshotData {
			let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
				.appendingPathComponent(snapshotURL.lastPathComponent)
			
			try? snapshotData?.write(to: temporarySnapshotURL)
			
			add(makeSnapshotAttachment(for: snapshot, named: "New snapshot - \(name)"))
			if let storedSnapshot = UIImage(data: storedSnapshotData) {
				add(makeSnapshotAttachment(for: storedSnapshot, named: "Stored snapshot - \(name)"))
			}
			
			XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
		}
	}
	
	func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
		let snapshotURL = makeSnapshotURL(named: name, file: file)
		let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
		
		do {
			try FileManager.default.createDirectory(
				at: snapshotURL.deletingLastPathComponent(),
				withIntermediateDirectories: true
			)
			
			try snapshotData?.write(to: snapshotURL)
			XCTFail("Record succeeded - use `assert` to compare the snapshot from now on.", file: file, line: line)
		} catch {
			XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
		}
	}
	
	private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
		return URL(fileURLWithPath: String(describing: file))
			.deletingLastPathComponent()
			.appendingPathComponent("snapshots")
			.appendingPathComponent("\(name).png")
	}
	
	private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
		guard let data = snapshot.pngData() else {
			XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
			return nil
		}
		
		return data
	}
	
	private func makeSnapshotAttachment(for snapshot: UIImage, named name: String) -> XCTAttachment {
		let attachment = XCTAttachment(image: snapshot)
		attachment.name = name
		return attachment
	}
	
}
