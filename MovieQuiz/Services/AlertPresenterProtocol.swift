import UIKit

protocol AlertPresenterProtocol {
    func show(in vc: UIViewController, model: AlertModel)
}
