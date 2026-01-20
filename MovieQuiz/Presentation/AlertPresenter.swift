import UIKit
final class AlertPresenter {
    
    func show(in viewController: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            model.completion()
        }
        alert.addAction(action)
        alert.view.accessibilityIdentifier = model.identifier
        viewController.present(alert, animated: true)
    }
}
