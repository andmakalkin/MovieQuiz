import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var backgroundForAlertView: UIView!
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        
        statisticService = StatisticService()
        alertPresenter = AlertPresenter()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        print(error.localizedDescription)
        showNetworkError()
    }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            activityIndicator.isHidden = true
        }
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Private Methods
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func splitInTwoLines(text: String) -> String {
        let words = text.components(separatedBy: " ")
        if words.count > 3 {
            let firstLine = words[0...2].joined(separator: " ")
            let secondLine = words[3...].joined(separator: " ")
            return firstLine + "\n" + secondLine
        } else {
            return text
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = splitInTwoLines(text: step.question)
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        correctAnswers += isCorrect ? 1 : 0
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let quizResults = setQuizResultsViewModel() else { return }
            showAlert(result: quizResults)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            imageView.layer.borderWidth = 0
        }
    }
    
    private func showAlert(result: QuizResultsViewModel) {
        UIView.animate(withDuration: 0.1) {
            self.backgroundForAlertView.alpha = 1
        }
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.backgroundForAlertView.alpha = 0
            self.restartGame()
        }
        alertPresenter?.show(in: self, model: model)
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func showNetworkError() {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Что-то пошло не так(",
                               message: "Невозможно загрузить данные",
                               buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.show(in: self, model: model)
        
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
}
