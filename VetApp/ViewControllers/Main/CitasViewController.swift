import UIKit

class CitasViewController: UIViewController {
    
    var mascota: MascotaEntity?
    private var citas: [CitaEntity] = []
    
    private let tableView: UITableView = {
        let t = UITableView()
        t.register(CitaCell.self, forCellReuseIdentifier: "CitaCell")
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 80
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                             target: self,
                                                             action: #selector(didTapAdd))
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
        if let mascota = mascota, let id = mascota.id {
            citas = CoreDataManager.shared.obtenerCitas(mascotaId: id)
        } else if let uid = FirebaseAuthService.shared.uidActual {
            citas = CoreDataManager.shared.obtenerTodasLasCitas(usuarioUID: uid)
        }
        tableView.reloadData()
        emptyLabel.isHidden = !citas.isEmpty
    }
    
    @objc private func didTapAdd() {
        let vc = AgendarCitaViewController()
        vc.mascota = mascota
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CitasViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { citas.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitaCell", for: indexPath) as! CitaCell
        cell.configure(with: citas[indexPath.row])
        return cell
    }
}

class CitaCell: UITableViewCell {
    
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let mascotaImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 25
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nombreLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        return l
    }()
    
    private let servicioLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = .systemBlue
        return l
    }()
    
    private let fechaLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let estadoBadge = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        [mascotaImageView, nombreLabel, servicioLabel, fechaLabel, estadoBadge].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
        
        // Estilo Badge
        estadoBadge.font = .systemFont(ofSize: 11, weight: .bold)
        estadoBadge.textColor = .white
        estadoBadge.layer.cornerRadius = 10
        estadoBadge.clipsToBounds = true
        estadoBadge.textAlignment = .center
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            mascotaImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            mascotaImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            mascotaImageView.widthAnchor.constraint(equalToConstant: 50),
            mascotaImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nombreLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            nombreLabel.leadingAnchor.constraint(equalTo: mascotaImageView.trailingAnchor, constant: 12),
            
            servicioLabel.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 2),
            servicioLabel.leadingAnchor.constraint(equalTo: nombreLabel.leadingAnchor),
            
            fechaLabel.topAnchor.constraint(equalTo: servicioLabel.bottomAnchor, constant: 2),
            fechaLabel.leadingAnchor.constraint(equalTo: nombreLabel.leadingAnchor),
            
            estadoBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            estadoBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            estadoBadge.widthAnchor.constraint(equalToConstant: 75),
            estadoBadge.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with cita: CitaEntity) {
        // Nombre y Foto
        nombreLabel.text = cita.mascota?.nombre ?? "Desconocido"
        if let data = cita.mascota?.fotoData, let img = UIImage(data: data) {
            mascotaImageView.image = img
        } else {
            mascotaImageView.image = UIImage(systemName: "pawprint.fill")
            mascotaImageView.tintColor = .systemTeal
        }
        
        servicioLabel.text = cita.tipoServicio
        
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fechaLabel.text = "\(fmt.string(from: cita.fecha ?? Date())) · \(cita.hora ?? "")"
        
        estadoBadge.text = cita.estado?.uppercased()
        estadoBadge.backgroundColor = cita.estado == "Pendiente" ? .systemOrange : .systemGreen
    }
}
