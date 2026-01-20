struct AlertModel {
    let identifier: String?
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
