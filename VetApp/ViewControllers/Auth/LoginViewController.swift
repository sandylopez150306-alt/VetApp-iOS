import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI
    private let logoLabel: UILabel = {
        let l = UILabel()
        l.text = "🐾 VetApp"
        l.font = .systemFont(ofSize: 40, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Animal Planet Vets"
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let emailField = VetTextField(placeholder: "Correo electrónico", keyboardType: .emailAddress)
    private let passwordField = VetTextField(placeholder: "Contraseña", isSecure: true)
    
    private let loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Iniciar Sesión", for: .normal)
        b.backgroundColor = UIColor(named: "AccentColor") ?? .systemTeal
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let registerButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("¿No tienes cuenta? Regístrate", for: .normal)
        b.setTitleColor(.systemTeal, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.hidesWhenStopped = true
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let stack = UIStackView(arrangedSubviews: [emailField, passwordField])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        [logoLabel, subtitleLabel, stack, loginButton, registerButton, activityIndicator].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            emailField.heightAnchor.constraint(equalToConstant: 52),
            passwordField.heightAnchor.constraint(equalToConstant: 52),
            
            loginButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 52),
            
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func didTapLogin() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(mensaje: "Por favor completa todos los campos.")
            return
        }
        
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        
        FirebaseAuthService.shared.iniciarSesion(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.loginButton.isEnabled = true
                switch result {
                case .success:
                    let tabBar = MainTabBarController()
                    tabBar.modalPresentationStyle = .fullScreen
                    self?.present(tabBar, animated: true)
                case .failure(let error):
                    self?.showAlert(mensaje: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func didTapRegister() {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    private func showAlert(mensaje: String) {
        let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
