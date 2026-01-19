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
