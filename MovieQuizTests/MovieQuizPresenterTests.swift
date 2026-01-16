import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {}
    func showAlert(result: MovieQuiz.QuizResultsViewModel) {}
    func showNetworkError() {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func removeImageBorder() {}
    func isEnabledButtons(_ isEnabled: Bool) {}
}

class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: false)
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        
    }
}
