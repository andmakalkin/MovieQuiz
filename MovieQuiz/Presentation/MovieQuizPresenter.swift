import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Initialization
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        alertPresenter = AlertPresenter()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        print(error.localizedDescription)
        viewController?.showNetworkError()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Public Methods
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    func presentAlert(in vc: UIViewController, model: AlertModel) {
        alertPresenter?.show(in: vc, model: model)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func tryLoadData() {
        questionFactory?.loadData()
    }
    
    func splitInTwoLines(text: String) -> String {
        let words = text.components(separatedBy: " ")
        if words.count > 3 {
            let firstLine = words[0...2].joined(separator: " ")
            let secondLine = words[3...].joined(separator: " ")
            return firstLine + "\n" + secondLine
        } else {
            return text
        }
    }
    
    // MARK: - Private Methods
    
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.isEnabledButtons(false)
        
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            self.viewController?.isEnabledButtons(true)
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let quizResults = setQuizResultsViewModel() else { return }
            viewController?.showAlert(result: quizResults)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            viewController?.removeImageBorder()
        }
    }
    
    private func setQuizResultsViewModel() -> QuizResultsViewModel? {
        guard let gamesCount = statisticService?.gamesCount else { return nil }
        guard let bestGame = statisticService?.bestGame else { return nil }
        guard let totalAccuracy = statisticService?.totalAccuracy else { return nil }
        
        let quizResults = QuizResultsViewModel(
            text: """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))% 
            """)
        
        return quizResults
    }
    
    private func didAnswer(isYes givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        self.correctAnswers += isCorrectAnswer ? 1 : 0
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
}
