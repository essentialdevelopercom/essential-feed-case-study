//	
// Copyright © Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

@MainActor
class CommentsUIIntegrationTests: XCTestCase {
	
	func test_commentsView_hasTitle() async {
		let (sut, _) = makeSUT()
		
		sut.simulateAppearance()
		
		XCTAssertEqual(sut.title, commentsTitle)
	}
	
	func test_loadCommentsActions_requestCommentsFromLoader() async {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view appears")
		
		sut.simulateAppearance()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view appears")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no request until previous completes")
		
		await loader.completeCommentsLoading(at: 0)
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")
		
		await loader.completeCommentsLoading(at: 1)
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadCommentsActions_runsAutomaticallyOnlyOnFirstAppearance() async {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view appears")

		sut.simulateAppearance()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view appears")

		sut.simulateAppearance()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no loading request the second time view appears")
	}
	
	func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() async {
		let (sut, loader) = makeSUT()
		
		sut.simulateAppearance()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view appears")
		
		await loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		await loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() async {
		let comment0 = makeComment(message: "a message", username: "a username")
		let comment1 = makeComment(message: "another message", username: "another username")
		let (sut, loader) = makeSUT()
		
		sut.simulateAppearance()
		assertThat(sut, isRendering: [ImageComment]())
		
		await loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])
		
		sut.simulateUserInitiatedReload()
		await loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
		assertThat(sut, isRendering: [comment0, comment1])
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() async {
		let comment = makeComment()
		let (sut, loader) = makeSUT()
		
		sut.simulateAppearance()
		await loader.completeCommentsLoading(with: [comment], at: 0)
		assertThat(sut, isRendering: [comment])
		
		sut.simulateUserInitiatedReload()
		await loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [ImageComment]())
	}
	
	func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() async {
		let comment = makeComment()
		let (sut, loader) = makeSUT()
		
		sut.simulateAppearance()
		await loader.completeCommentsLoading(with: [comment], at: 0)
		assertThat(sut, isRendering: [comment])
		
		sut.simulateUserInitiatedReload()
		await loader.completeCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment])
	}
	
	func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() async {
		let (sut, loader) = makeSUT()
		
		sut.simulateAppearance()
		XCTAssertEqual(sut.errorMessage, nil)
		
		await loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_tapOnErrorView_hidesErrorMessage() async {
		let (sut, loader) = makeSUT()
		
		sut.simulateAppearance()
		XCTAssertEqual(sut.errorMessage, nil)
		
		await loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)
		
		sut.simulateErrorViewTap()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_deinit_cancelsRunningRequest() async throws {
		let loader = LoaderSpy<Void, [ImageComment]>()
		var sut: ListViewController?
		
		autoreleasepool {
			sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadComments)

			sut?.simulateAppearance()
		}
		
		XCTAssertEqual(loader.cancelledCommentsRequestsCount, 0)
		
		sut = nil
		let result = try await loader.result(at: 0)
		
		XCTAssertEqual(result, .cancelled)
		XCTAssertEqual(loader.cancelledCommentsRequestsCount, 1)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy<Void, [ImageComment]>) {
		let loader = LoaderSpy<Void, [ImageComment]>()
		let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadComments)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		addTeardownBlock { [weak loader] in
			try await loader?.cancelPendingRequests()
		}

		return (sut, loader)
	}
	
	private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
		return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
	}
	
	private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)
		
		let viewModel = ImageCommentsPresenter.map(comments)
		
		viewModel.comments.enumerated().forEach { index, comment in
			XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
			XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
			XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
		}
	}
}

private extension LoaderSpy where Param == Void, Resource == [ImageComment] {
	var loadCommentsCallCount: Int {
		return requests.count
	}
	
	var cancelledCommentsRequestsCount: Int {
		requests.count { $0.result == .cancelled }
	}
	
	func loadComments() async throws -> [ImageComment] {
		try await load(())
	}
	
	func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) async {
		await complete(with: comments, at: index)
	}
	
	func completeCommentsLoadingWithError(at index: Int = 0) async {
		let error = NSError(domain: "an error", code: 0)
		await fail(with: error, at: index)
	}
}
