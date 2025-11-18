//	
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

enum AsyncResult {
	case success
	case failure
	case cancelled
}

@MainActor
class LoaderSpy<Param, Resource: Sendable> {
	private(set) var requests = [(
		param: Param,
		stream: AsyncThrowingStream<Resource, Error>,
		continuation: AsyncThrowingStream<Resource, Error>.Continuation,
		result: AsyncResult?
	)]()
	
	private struct NoResponse: Error {}
	private struct Timeout: Error {}
	
	func load(_ param: Param) async throws -> Resource {
		let (stream, continuation) = AsyncThrowingStream<Resource, Error>.makeStream()
		let index = requests.count
		requests.append((param, stream, continuation, nil))
		
		do {
			for try await result in stream {
				try Task.checkCancellation()
				requests[index].result = .success
				return result
			}
			
			try Task.checkCancellation()
			
			throw NoResponse()
		} catch {
			requests[index].result = Task.isCancelled ? .cancelled : .failure
			throw error
		}
	}
	
	func complete(with resource: Resource, at index: Int) {
		requests[index].continuation.yield(resource)
		requests[index].continuation.finish()
		
		while requests[index].result == nil { RunLoop.current.run(until: Date()) }
	}
	
	func fail(with error: Error, at index: Int) {
		requests[index].continuation.finish(throwing: error)
		
		while requests[index].result == nil { RunLoop.current.run(until: Date()) }
	}
	
	func result(at index: Int, timeout: TimeInterval = 1) async throws -> AsyncResult {
		let maxDate = Date() + timeout
		
		while Date() <= maxDate {
			if let result = requests[index].result {
				return result
			}
			
			await Task.yield()
		}
		
		throw Timeout()
	}
	
	func cancelPendingRequests() async throws {
		for (index, request) in requests.enumerated() where request.result == nil {
			request.continuation.finish(throwing: CancellationError())
			
			while requests[index].result == nil { await Task.yield() }
		}
	}
}
