import UIKit

// MARK: - AlertPresenter

final class AlertPresenter: AlertPresenterProtocol {

    // MARK: - Public Methods

    func show(in viewController: UIViewController, model: AlertModel) {
        DispatchQueue.main.async {
            self.presentAlert(in: viewController, model: model)
        }
    }

    // MARK: - Private Methods

    private func presentAlert(in viewController: UIViewController, model: AlertModel) {
        let alertController = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }

        alertController.addAction(action)
        viewController.present(alertController, animated: true)
    }
}
