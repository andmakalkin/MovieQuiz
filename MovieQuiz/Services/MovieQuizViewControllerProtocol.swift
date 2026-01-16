import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert(result: QuizResultsViewModel)
    func showNetworkError()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func removeImageBorder()
    func isEnabledButtons(_ isEnabled: Bool)
}
