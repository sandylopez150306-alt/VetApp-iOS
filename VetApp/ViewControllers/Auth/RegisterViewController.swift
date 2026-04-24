import UIKit

class RegisterViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Crear Cuenta"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let nombreField   = VetTextField(placeholder: "Nombre completo")
    private let emailField    = VetTextField(placeholder: "Correo electrónico", keyboardType: .emailAddress)
    private let passwordField = VetTextField(placeholder: "Contraseña (mín. 6 caracteres)", isSecure: true)
    
    private let registerButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Crear Cuenta", for: .normal)
        b.backgroundColor = .systemTeal
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Registro"
        setupUI()
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [nombreField, emailField, passwordField])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, stack, registerButton].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            nombreField.heightAnchor.constraint(equalToConstant: 52),
            emailField.heightAnchor.constraint(equalToConstant: 52),
            passwordField.heightAnchor.constraint(equalToConstant: 52),
            
            registerButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 24),
            registerButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    @objc private func didTapRegister() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, password.count >= 6 else {
            showAlert("Completa todos los campos. La contraseña debe tener al menos 6 caracteres.")
            return
        }
        
        FirebaseAuthService.shared.registrar(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let tabBar = MainTabBarController()
                    tabBar.modalPresentationStyle = .fullScreen
                    self?.present(tabBar, animated: true)
                case .failure(let error):
                    self?.showAlert(error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Aviso", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
