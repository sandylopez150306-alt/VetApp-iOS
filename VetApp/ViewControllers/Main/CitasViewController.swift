import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore

class CitasViewController: UIViewController {
    
    var mascota: MascotaEntity?
    private var citas: [CitaEntity] = []
    
    private let tableView: UITableView = {
        let t = UITableView()
        t.register(CitaCell.self, forCellReuseIdentifier: "CitaCell")
        t.rowHeight = 80
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No hay citas programadas.\nToca + para agendar una."
        l.numberOfLines = 2
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = mascota != nil ? "Citas de \(mascota!.nombre ?? "")" : "Mis Citas"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarCitas()
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
    
    private func cargarCitas() {
        guard let uid = FirebaseAuthService.shared.uidActual else { return }
        let db = Firestore.firestore()
        
        db.collection("citas").whereField("usuarioUID", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                self.citas.removeAll()
                
                for document in documents {
                    let data = document.data()
                    
                    guard let mascotaIdString = data["mascotaId"] as? String,
                          let mascotaId = UUID(uuidString: mascotaIdString) else { continue }
                    
                    let request: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", mascotaId as CVarArg)
                    let mascotaEncontrada = try? CoreDataManager.shared.context.fetch(request).first
                    
                    let cita = CitaEntity(context: CoreDataManager.shared.context)
                    cita.tipoServicio = data["tipoServicio"] as? String
                    cita.hora = data["hora"] as? String
                    cita.estado = data["estado"] as? String ?? "Pendiente"
                    cita.mascota = mascotaEncontrada
                    
                    if let timestamp = data["fecha"] as? Timestamp {
                        cita.fecha = timestamp.dateValue()
                    }
                    
                    self.citas.append(cita)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.emptyLabel.isHidden = !self.citas.isEmpty
                }
            }
    }
    
    @objc private func didTapAdd() {
        let vc = AgendarCitaViewController()
        vc.mascota = mascota
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CitasViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return citas.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitaCell", for: indexPath) as! CitaCell
        cell.configure(with: citas[indexPath.row])
        return cell
    }
}

// MARK: - Celda Personalizada
class CitaCell: UITableViewCell {
    private let fotoImageView = UIImageView()
    private let nombreMascotaLabel = UILabel()
    private let servicioLabel = UILabel()
    private let fechaLabel = UILabel()
    private let estadoBadge = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        fotoImageView.contentMode = .scaleAspectFill
        fotoImageView.clipsToBounds = true
        fotoImageView.layer.cornerRadius = 25
        fotoImageView.backgroundColor = .systemGray5
        
        nombreMascotaLabel.font = .systemFont(ofSize: 16, weight: .bold)
        servicioLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        fechaLabel.font = .systemFont(ofSize: 13)
        fechaLabel.textColor = .secondaryLabel
        
        estadoBadge.font = .systemFont(ofSize: 12, weight: .medium)
        estadoBadge.textColor = .white
        estadoBadge.layer.cornerRadius = 8
        estadoBadge.clipsToBounds = true
        estadoBadge.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [nombreMascotaLabel, servicioLabel, fechaLabel])
        stack.axis = .vertical
        stack.spacing = 2
        
        [fotoImageView, stack, estadoBadge].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            fotoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fotoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fotoImageView.widthAnchor.constraint(equalToConstant: 50),
            fotoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            stack.leadingAnchor.constraint(equalTo: fotoImageView.trailingAnchor, constant: 12),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: estadoBadge.leadingAnchor, constant: -8),
            
            estadoBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            estadoBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            estadoBadge.widthAnchor.constraint(equalToConstant: 80),
            estadoBadge.heightAnchor.constraint(equalToConstant: 26)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with cita: CitaEntity) {
        nombreMascotaLabel.text = cita.mascota?.nombre ?? "Lisa"
        servicioLabel.text = cita.tipoServicio
        
        if let data = cita.mascota?.fotoData {
            fotoImageView.image = UIImage(data: data)
        } else {
            fotoImageView.image = UIImage(systemName: "pawprint.fill")
        }
        
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.locale = Locale(identifier: "es_PE")
        fechaLabel.text = "\(fmt.string(from: cita.fecha ?? Date())) · \(cita.hora ?? "")"
        
        estadoBadge.text = cita.estado
        estadoBadge.backgroundColor = cita.estado == "Pendiente" ? .systemOrange : .systemGreen
    }
}
