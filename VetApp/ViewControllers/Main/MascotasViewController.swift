import UIKit

class MascotasViewController: UIViewController {
    
    private var mascotas: [MascotaEntity] = []
    
    private let tableView: UITableView = {
        let t = UITableView()
        t.register(MascotaCell.self, forCellReuseIdentifier: "MascotaCell")
        t.rowHeight = 80
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No tienes mascotas registradas.\nToca + para agregar una."
        l.numberOfLines = 2
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 16)
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mis Mascotas"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                             target: self,
                                                             action: #selector(didTapAdd))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Salir",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapLogout))
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarMascotas()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func cargarMascotas() {
        guard let uid = FirebaseAuthService.shared.uidActual else { return }
        mascotas = CoreDataManager.shared.obtenerMascotas(usuarioUID: uid)
        tableView.reloadData()
        emptyLabel.isHidden = !mascotas.isEmpty
    }
    
    @objc private func didTapAdd() {
        let vc = RegistrarMascotaViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapLogout() {
        let alert = UIAlertController(title: "¿Cerrar sesión?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Salir", style: .destructive) { _ in
            FirebaseAuthService.shared.cerrarSesion()
            let login = UINavigationController(rootViewController: LoginViewController())
            login.modalPresentationStyle = .fullScreen
            self.present(login, animated: true)
        })
        present(alert, animated: true)
    }
}

extension MascotasViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mascotas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MascotaCell", for: indexPath) as! MascotaCell
        cell.configure(with: mascotas[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = CitasViewController()
        vc.mascota = mascotas[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataManager.shared.eliminarMascota(mascotas[indexPath.row])
            mascotas.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            emptyLabel.isHidden = !mascotas.isEmpty
        }
    }
}

// MARK: - MascotaCell
class MascotaCell: UITableViewCell {
    private let fotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 28
        iv.backgroundColor = .systemTeal.withAlphaComponent(0.2)
        iv.image = UIImage(systemName: "pawprint.fill")
        iv.tintColor = .systemTeal
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nombreLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        return l
    }()
    
    private let especieLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        let stack = UIStackView(arrangedSubviews: [nombreLabel, especieLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fotoImageView)
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            fotoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fotoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fotoImageView.widthAnchor.constraint(equalToConstant: 56),
            fotoImageView.heightAnchor.constraint(equalToConstant: 56),
            stack.leadingAnchor.constraint(equalTo: fotoImageView.trailingAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with mascota: MascotaEntity) {
        nombreLabel.text = mascota.nombre
        especieLabel.text = "\(mascota.especie ?? "") · \(mascota.raza ?? "")"
        if let data = mascota.fotoData, let img = UIImage(data: data) {
            fotoImageView.image = img
        }
    }
}
