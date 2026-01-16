import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var backgroundForAlertView: UIView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Public Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = presenter?.splitInTwoLines(text: step.question)
        counterLabel.text = step.questionNumber
    }
    
    func showAlert(result: QuizResultsViewModel) {
        UIView.animate(withDuration: 0.1) {
            self.backgroundForAlertView.alpha = 1
        }
        let model = AlertModel(title: result.title,
                               message: result.text,
                               buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.removeImageBorder()
            self.backgroundForAlertView.alpha = 0
            self.presenter?.restartGame()
        }
        
        presenter?.presentAlert(in: self, model: model)
    }

    func showNetworkError() {
        hideLoadingIndicator()
        
        let model = AlertModel(title: AlertModel.Error.title.rawValue,
                               message: AlertModel.Error.message.rawValue,
                               buttonText: AlertModel.Error.buttonText.rawValue) { [weak self] in
            guard let self = self else { return }
            self.showLoadingIndicator()
            self.presenter?.tryLoadData()
        }
        
        presenter?.presentAlert(in: self, model: model)
    }

    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderWidth = 8
        self.imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func removeImageBorder() {
        self.imageView.layer.borderWidth = 0
    }
    
    func isEnabledButtons(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
}
