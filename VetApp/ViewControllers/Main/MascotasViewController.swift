import UIKit
import FirebaseFirestore
import CoreData

class MascotasViewController: UIViewController {
    
    private var mascotas: [MascotaEntity] = []
    private var listener: ListenerRegistration? // Para gestionar el listener de Firebase
    
    private let tableView: UITableView = {
        let t = UITableView()
        t.register(MascotaCell.self, forCellReuseIdentifier: "MascotaCell")
        t.rowHeight = 90
        t.separatorStyle = .none
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
        setupNavigation()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarMascotas()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove() // Detenemos el listener al salir de la pantalla
    }
    
    private func setupNavigation() {
        title = "Mis Mascotas"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAdd)
        )
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
        let db = Firestore.firestore()
        listener = db.collection("mascotas")
            .whereField("usuarioUID", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                self.mascotas.removeAll()
                
                for document in documents {
                    let data = document.data()
                    let nombreRaw = data["nombre"] as? String ?? ""
                    let nombreLimpio = nombreRaw.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let request: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "nombre == %@ AND usuarioUID == %@", nombreLimpio, uid)
                    
                    let mascota = (try? CoreDataManager.shared.context.fetch(request).first) ?? MascotaEntity(context: CoreDataManager.shared.context)
                    
                    if mascota.id == nil { mascota.id = UUID() }
                    
                    mascota.nombre = nombreLimpio
                    mascota.especie = (data["especie"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                    mascota.raza = (data["raza"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                    mascota.usuarioUID = uid
                    if let fotoBase64 = data["fotoData"] as? String, !fotoBase64.isEmpty {
                        mascota.fotoData = Data(base64Encoded: fotoBase64)
                    } else {
                        mascota.fotoData = nil
                    }
                    
                    self.mascotas.append(mascota)
                }
                
                try? CoreDataManager.shared.context.save()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.emptyLabel.isHidden = !self.mascotas.isEmpty
                }
            }
    }
    
    @objc private func didTapAdd() {
        let vc = RegistrarMascotaViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView Extensions
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
            let mascotaAEliminar = mascotas[indexPath.row]
            guard let nombre = mascotaAEliminar.nombre?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let uid = FirebaseAuthService.shared.uidActual else { return }
            
            let db = Firestore.firestore()
    
            db.collection("mascotas")
                .whereField("usuarioUID", isEqualTo: uid)
                .whereField("nombre", isEqualTo: nombre)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error buscando para borrar: \(error)")
                        return
                    }
                    snapshot?.documents.forEach { $0.reference.delete() }
                }
        
            CoreDataManager.shared.eliminarMascota(mascotaAEliminar)
            
            mascotas.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            emptyLabel.isHidden = !mascotas.isEmpty
        }
    }
}

// MARK: - MascotaCell
class MascotaCell: UITableViewCell {
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let fotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        iv.backgroundColor = .systemGray5
        iv.image = UIImage(systemName: "pawprint.fill")
        iv.tintColor = .systemTeal
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nombreLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        return l
    }()
    
    private let infoLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupCellLayout()
    }
    
    private func setupCellLayout() {
        contentView.addSubview(containerView)
        let stack = UIStackView(arrangedSubviews: [nombreLabel, infoLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(fotoImageView)
        containerView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            fotoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            fotoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            fotoImageView.widthAnchor.constraint(equalToConstant: 60),
            fotoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            stack.leadingAnchor.constraint(equalTo: fotoImageView.trailingAnchor, constant: 15),
            stack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with mascota: MascotaEntity) {
        nombreLabel.text = mascota.nombre
        infoLabel.text = "\(mascota.especie ?? "Mascota") • \(mascota.raza ?? "Sin raza")"
        
        if let data = mascota.fotoData, let img = UIImage(data: data) {
            fotoImageView.image = img
        } else {
            fotoImageView.image = UIImage(systemName: "pawprint.circle.fill")
        }
    }
}
