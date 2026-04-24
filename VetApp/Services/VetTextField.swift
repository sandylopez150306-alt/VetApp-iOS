import UIKit

class VetTextField: UITextField {
    init(placeholder: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecure
        self.borderStyle = .none
        self.font = .systemFont(ofSize: 16)
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 12
        self.translatesAutoresizingMaskIntoConstraints = false
        // Padding interno
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    required init?(coder: NSCoder) { fatalError() }
}
