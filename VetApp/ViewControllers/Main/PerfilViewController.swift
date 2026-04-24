import UIKit
import FirebaseAuth

class PerfilViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Header de perfil
    private let profileCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.06, green: 0.53, blue: 0.49, alpha: 1)
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        iv.layer.cornerRadius = 50
        iv.clipsToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nombreLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let emailLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let editarFotoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cambiar foto", for: .normal)
        b.setTitleColor(UIColor.white.withAlphaComponent(0.9), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // MARK: - Sección de info
    private lazy var infoSection: UIView = buildSection(title: "Información de la Cuenta", items: [
        ProfileRow(icon: "envelope.fill",       color: .systemTeal,   title: "Correo",     value: Auth.auth().currentUser?.email ?? "–"),
        ProfileRow(icon: "calendar.badge.clock", color: .systemOrange, title: "Miembro desde", value: memberSince()),
        ProfileRow(icon: "iphone",              color: .systemBlue,   title: "Dispositivo",value: UIDevice.current.name)
    ])
    
    // MARK: - Sección de app
    private lazy var appSection: UIView = buildSection(title: "Acerca de VetApp", items: [
        ProfileRow(icon: "app.badge.fill",      color: .systemPurple, title: "Versión",    value: "1.0.0"),
        ProfileRow(icon: "mappin.circle.fill",  color: .systemRed,    title: "Clínica",    value: "Animal Planet Vets"),
        ProfileRow(icon: "location.fill",       color: .systemGreen,  title: "Ubicación",  value: "Alto Moche · Miramar")
    ])
    
    // MARK: - Sección de seguridad
    private let cambiarPasswordButton = SectionButton(
        title: "Cambiar contraseña",
        icon: "lock.rotation",
        color: .systemIndigo
    )
    
    // MARK: - Logout
    private let logoutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cerrar Sesión", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = UIColor(red: 0.91, green: 0.30, blue: 0.30, alpha: 1)
        b.layer.cornerRadius = 14
        b.layer.shadowColor = UIColor(red: 0.91, green: 0.30, blue: 0.30, alpha: 1).cgColor
        b.layer.shadowOpacity = 0.3
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 8
        b.translatesAutoresizingMaskIntoConstraints = false
        
        // Ícono dentro del botón
        var config = UIButton.Configuration.filled()
        config.title = "Cerrar Sesión"
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        config.imagePadding = 10
        config.baseBackgroundColor = UIColor(red: 0.91, green: 0.30, blue: 0.30, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        b.configuration = config
        return b
    }()
    
    private let deleteAccountButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Eliminar cuenta", for: .normal)
        b.setTitleColor(UIColor(red: 0.91, green: 0.30, blue: 0.30, alpha: 1), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mi Perfil"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        setupUI()
        cargarDatosUsuario()
        setupAcciones()
    }
    
    // MARK: - Setup
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [profileCard, infoSection, appSection, cambiarPasswordButton, logoutButton, deleteAccountButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = true
            contentView.addSubview($0)
        }
        
        profileCard.addSubview(avatarImageView)
        profileCard.addSubview(nombreLabel)
        profileCard.addSubview(emailLabel)
        profileCard.addSubview(editarFotoButton)
        
        [profileCard, infoSection, appSection, cambiarPasswordButton, logoutButton, deleteAccountButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Profile card
            profileCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            profileCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            profileCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: profileCard.safeAreaLayoutGuide.topAnchor, constant: 24),
            avatarImageView.centerXAnchor.constraint(equalTo: profileCard.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nombreLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            nombreLabel.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 20),
            nombreLabel.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -20),
            
            editarFotoButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16),
            editarFotoButton.centerXAnchor.constraint(equalTo: profileCard.centerXAnchor),
            editarFotoButton.widthAnchor.constraint(equalToConstant: 130),
            editarFotoButton.heightAnchor.constraint(equalToConstant: 32),
            editarFotoButton.bottomAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: -28),
            
            // Info section
            infoSection.topAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: 24),
            infoSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // App section
            appSection.topAnchor.constraint(equalTo: infoSection.bottomAnchor, constant: 16),
            appSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            appSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Cambiar password button
            cambiarPasswordButton.topAnchor.constraint(equalTo: appSection.bottomAnchor, constant: 16),
            cambiarPasswordButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cambiarPasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cambiarPasswordButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Logout button
            logoutButton.topAnchor.constraint(equalTo: cambiarPasswordButton.bottomAnchor, constant: 24),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 56),
            
            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 12),
            deleteAccountButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            deleteAccountButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func cargarDatosUsuario() {
        guard let user = Auth.auth().currentUser else { return }
        emailLabel.text = user.email
        let nombre = String(user.email?.split(separator: "@").first ?? "Usuario").capitalized
        nombreLabel.text = nombre
    }
    
    private func setupAcciones() {
        editarFotoButton.addTarget(self, action: #selector(didTapEditarFoto), for: .touchUpInside)
        cambiarPasswordButton.addTarget(self, action: #selector(didTapCambiarPassword), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
    }
    
    // MARK: - Helpers
    private func buildSection(title: String, items: [ProfileRow]) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor  = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.06
        container.layer.shadowOffset  = CGSize(width: 0, height: 2)
        container.layer.shadowRadius  = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16)
        ])
        
        var lastView: UIView = titleLabel
        for (idx, row) in items.enumerated() {
            row.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(row)
            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: idx == 0 ? 12 : 0),
                row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                row.heightAnchor.constraint(equalToConstant: 52)
            ])
            
            // Separador (excepto el último)
            if idx < items.count - 1 {
                let sep = UIView()
                sep.backgroundColor = UIColor.separator.withAlphaComponent(0.4)
                sep.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(sep)
                NSLayoutConstraint.activate([
                    sep.topAnchor.constraint(equalTo: row.bottomAnchor),
                    sep.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 52),
                    sep.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                    sep.heightAnchor.constraint(equalToConstant: 0.5)
                ])
            }
            lastView = row
        }
        
        lastView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8).isActive = true
        return container
    }
    
    private func memberSince() -> String {
        guard let date = Auth.auth().currentUser?.metadata.creationDate else { return "–" }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.locale = Locale(identifier: "es_PE")
        return fmt.string(from: date)
    }
    
    // MARK: - Actions
    @objc private func didTapEditarFoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: "Foto de perfil", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Cámara", style: .default) { _ in
                picker.sourceType = .camera
                self.present(picker, animated: true)
            })
        }
        alert.addAction(UIAlertAction(title: "Galería", style: .default) { _ in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapCambiarPassword() {
        guard let email = Auth.auth().currentUser?.email else { return }
        let alert = UIAlertController(title: "Cambiar contraseña",
                                      message: "Te enviaremos un correo a \(email) para restablecer tu contraseña.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Enviar correo", style: .default) { _ in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                let msg = error == nil ? "Correo enviado. Revisa tu bandeja de entrada." : error!.localizedDescription
                let conf = UIAlertController(title: error == nil ? "✅ Listo" : "Error", message: msg, preferredStyle: .alert)
                conf.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(conf, animated: true)
            }
        })
        present(alert, animated: true)
    }
    
    @objc private func didTapLogout() {
        let alert = UIAlertController(
            title: "¿Cerrar sesión?",
            message: "Tendrás que iniciar sesión nuevamente para acceder a tus datos.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive) { _ in
            // Animación de salida
            UIView.animate(withDuration: 0.3, animations: {
                self.view.alpha = 0
                self.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                FirebaseAuthService.shared.cerrarSesion()
                let login = UINavigationController(rootViewController: LoginViewController())
                login.modalPresentationStyle = .fullScreen
                login.modalTransitionStyle   = .crossDissolve
                self.present(login, animated: true) {
                    self.view.alpha = 1
                    self.view.transform = .identity
                }
            }
        })
        present(alert, animated: true)
    }
    
    @objc private func didTapDeleteAccount() {
        let alert = UIAlertController(
            title: "⚠️ Eliminar cuenta",
            message: "Esta acción es irreversible. Se eliminarán todos tus datos y los de tus mascotas.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Eliminar permanentemente", style: .destructive) { _ in
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    let err = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    err.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(err, animated: true)
                } else {
                    let login = UINavigationController(rootViewController: LoginViewController())
                    login.modalPresentationStyle = .fullScreen
                    login.modalTransitionStyle   = .crossDissolve
                    self.present(login, animated: true)
                }
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - ImagePicker
extension PerfilViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let img = info[.originalImage] as? UIImage {
            avatarImageView.image = img
            avatarImageView.contentMode = .scaleAspectFill
        }
        dismiss(animated: true)
    }
}

// MARK: - ProfileRow (fila de info)
class ProfileRow: UIView {
    init(icon: String, color: UIColor, title: String, value: String) {
        super.init(frame: .zero)
        let iconBg = UIView()
        iconBg.backgroundColor = color.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 10
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconBg)
        iconBg.addSubview(iconView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconBg.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 34),
            iconBg.heightAnchor.constraint(equalToConstant: 34),
            
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - SectionButton
class SectionButton: UIControl {
    init(title: String, icon: String, color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.shadowColor  = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset  = CGSize(width: 0, height: 2)
        layer.shadowRadius  = 8
        
        let iconBg = UIView()
        iconBg.backgroundColor = color.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 10
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        [iconBg, label, chevron].forEach { addSubview($0) }
        iconBg.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconBg.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 34),
            iconBg.heightAnchor.constraint(equalToConstant: 34),
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            label.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp),   for: [.touchUpInside, .touchDragExit, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func touchDown() {
        UIView.animate(withDuration: 0.12) { self.backgroundColor = UIColor.systemGray5 }
    }
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.2) { self.backgroundColor = .systemBackground }
    }
}
