import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void

    enum Error: String {
        case title = "Что-то пошло не так("
        case message = "Невозможно загрузить данные"
        case buttonText = "Попробовать ещё раз"
    }
}
