import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {

    func testPresenterConvertModel() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        let emptyData = Data()
        let question = QuizQuestion(
            image: emptyData,
            text: "Question Text",
            correctAnswer: false
        )

        // When
        let viewModel = presenter.convert(model: question)

        // Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
