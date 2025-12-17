import UIKit
final class AlertPresenter {
    
    func show(in vc: UIViewController, model: AlertModel) {
        //Тут я задаю параграф, который выравнивает по центру
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping // Зачем?
        
        //Формирую attributedString. Зачем? ЧТо это?
        let attributedMessage = NSAttributedString(
            string: model.message,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.label,
                .kern: 0 //Зачем?
            ]
        )
        let alert = UIAlertController(
            title: model.title,
            message: nil,
            preferredStyle: .alert)
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
                model.completion()
            }
        alert.addAction(action)
        
        vc.present(alert, animated: true, completion: nil)
    }
}
//Написал этот код при помощи нейросетки. Вообще, я не понял что тут происходит. То, что непонятно - отметил комментариями
// И все равно у меня текст в алерте привязан к левому краю -_-
