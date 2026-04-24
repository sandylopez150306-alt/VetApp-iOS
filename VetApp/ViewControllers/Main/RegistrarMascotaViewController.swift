import UIKit

class RegistrarMascotaViewController: UIViewController {
    
    private var fotoSeleccionada: Data?
    private var razasDisponibles: [RazaModel] = []
    private var especieSeleccionada: String = "Perro"
    
    private let fotoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        b.setTitle("  Foto de la mascota", for: .normal)
        b.backgroundColor = .systemTeal.withAlphaComponent(0.1)
        b.tintColor = .systemTeal
        b.layer.cornerRadius = 60
        b.layer.borderWidth = 2
        b.layer.borderColor = UIColor.systemTeal.cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let nombreField = VetTextField(placeholder: "Nombre de la mascota")
    
    private let especiePicker: UISegmentedControl = {
        let s = UISegmentedControl(items: ["Perro", "Gato", "Otro"])
        s.selectedSegmentIndex = 0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let razaField: UITextField = {
        let f = UITextField()
        f.placeholder = "Buscar raza..."
        f.borderStyle = .roundedRect
        f.font = .systemFont(ofSize: 16)
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()
    
    private let razasTableView: UITableView = {
        let t = UITableView()
        t.register(UITableViewCell.self, forCellReuseIdentifier: "RazaCell")
        t.layer.borderColor = UIColor.systemGray4.cgColor
        t.layer.borderWidth = 1
        t.layer.cornerRadius = 8
        t.isHidden = true
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    private let infoRazaView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemTeal.withAlphaComponent(0.08)
        v.layer.cornerRadius = 10
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let infoRazaLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 3
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let razaImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let fechaNacPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.maximumDate = Date()
        if #available(iOS 14.0, *) { dp.preferredDatePickerStyle = .compact }
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    private let guardarButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Guardar Mascota", for: .normal)
        b.backgroundColor = .systemTeal
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private var razasTableHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nueva Mascota"
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let fechaLabel = UILabel()
        fechaLabel.text = "Fecha de nacimiento:"
        fechaLabel.font = .systemFont(ofSize: 16)
        fechaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let especieLabel = UILabel()
        especieLabel.text = "Especie:"
        especieLabel.font = .systemFont(ofSize: 16)
        especieLabel.translatesAutoresizingMaskIntoConstraints = false
        
        infoRazaView.addSubview(razaImageView)
        infoRazaView.addSubview(infoRazaLabel)
        
        [fotoButton, nombreField, especieLabel, especiePicker, razaField, razasTableView,
         infoRazaView, fechaLabel, fechaNacPicker, guardarButton].forEach { contentView.addSubview($0) }
        
        razasTableHeightConstraint = razasTableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            fotoButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            fotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            fotoButton.widthAnchor.constraint(equalToConstant: 120),
            fotoButton.heightAnchor.constraint(equalToConstant: 120),
            
            nombreField.topAnchor.constraint(equalTo: fotoButton.bottomAnchor, constant: 24),
            nombreField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nombreField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            nombreField.heightAnchor.constraint(equalToConstant: 52),
            
            especieLabel.topAnchor.constraint(equalTo: nombreField.bottomAnchor, constant: 20),
            especieLabel.leadingAnchor.constraint(equalTo: nombreField.leadingAnchor),
            
            especiePicker.topAnchor.constraint(equalTo: especieLabel.bottomAnchor, constant: 8),
            especiePicker.leadingAnchor.constraint(equalTo: nombreField.leadingAnchor),
            especiePicker.trailingAnchor.constraint(equalTo: nombreField.trailingAnchor),
            
            razaField.topAnchor.constraint(equalTo: especiePicker.bottomAnchor, constant: 16),
            razaField.leadingAnchor.constraint(equalTo: nombreField.leadingAnchor),
            razaField.trailingAnchor.constraint(equalTo: nombreField.trailingAnchor),
            razaField.heightAnchor.constraint(equalToConstant: 44),
            
            razasTableView.topAnchor.constraint(equalTo: razaField.bottomAnchor, constant: 4),
            razasTableView.leadingAnchor.constraint(equalTo: nombreField.leadingAnchor),
            razasTableView.trailingAnchor.constraint(equalTo: nombreField.trailingAnchor),
            razasTableHeightConstraint,
            
            infoRazaView.topAnchor.constraint(equalTo: razasTableView.bottomAnchor, constant: 12),
            infoRazaView.leadingAnchor.constraint(equalTo: nombreField.leadingAnchor),
            infoRazaView.trailingAnchor.constraint(equalTo: nombreField.trailingAnchor),
            
            razaImageView.leadingAnchor.constraint(equalTo: infoRazaView.leadingAnchor, constant: 10),
            razaImageView.topAnchor.constraint(equalTo: infoRazaView.topAnchor, constant: 10),
            razaImageView.bottomAnchor.constraint(equalTo: infoRazaView.bottomAnchor, constant: -10),
            razaImageView.widthAnchor.constraint(equalToConstant: 70),
            razaImageView.heightAnchor.constraint(equalToConstant: 70),
            
            infoRazaLabel.leadingAnchor.constraint(equalTo: razaImageView.trailingAnchor, constant: 10),
            infoRazaLabel.trailingAnchor.constraint(equalTo: infoRazaView.trailingAnchor, constant: -10),
            infoRazaLabel.centerYAnchor.constraint(equalTo: infoRazaView.centerYAnchor),
            
            fechaLabel.topAnchor.constraint(equalTo: infoRazaView.bottomAnchor, constant: 20),
            fechaLabel.leadingAnchor.constraint(equalTo: nombreField.leadingAnchor),
            
            fechaNacPicker.topAnchor.constraint(equalTo: fechaLabel.bottomAnchor, constant: 8),
            fechaNacPicker.leadingAnchor.constraint(equalTo: nombreField.leadingAnchor),
            
            guardarButton.topAnchor.constraint(equalTo: fechaNacPicker.bottomAnchor, constant: 30),
            guardarButton.leadingAnchor.constraint(equalTo: nombreField.leadingAnchor),
            guardarButton.trailingAnchor.constraint(equalTo: nombreField.trailingAnchor),
            guardarButton.heightAnchor.constraint(equalToConstant: 52),
            guardarButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        razasTableView.dataSource = self
        razasTableView.delegate = self
    }
    
    private func setupActions() {
        fotoButton.addTarget(self, action: #selector(didTapFoto), for: .touchUpInside)
        guardarButton.addTarget(self, action: #selector(didTapGuardar), for: .touchUpInside)
        especiePicker.addTarget(self, action: #selector(didChangeEspecie), for: .valueChanged)
        razaField.addTarget(self, action: #selector(didChangeRaza), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    @objc private func didTapFoto() {
        // AVFoundation - picker de cámara/galería
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: "Foto de mascota", message: nil, preferredStyle: .actionSheet)
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
    
    @objc private func didChangeEspecie() {
        especieSeleccionada = especiePicker.titleForSegment(at: especiePicker.selectedSegmentIndex) ?? "Perro"
        razaField.text = ""
        razasDisponibles = []
        razasTableView.reloadData()
        actualizarAlturaTabla()
        infoRazaView.isHidden = true
    }
    
    @objc private func didChangeRaza() {
        guard let query = razaField.text, query.count >= 2 else {
            razasDisponibles = []
            razasTableView.reloadData()
            actualizarAlturaTabla()
            return
        }
        
        // Llamada REST API según la especie
        let completion: ([RazaModel]) -> Void = { [weak self] razas in
            self?.razasDisponibles = razas
            self?.razasTableView.reloadData()
            self?.actualizarAlturaTabla()
        }
        
        if especieSeleccionada == "Perro" {
            APIService.shared.buscarRazasPerro(query: query, completion: completion)
        } else if especieSeleccionada == "Gato" {
            APIService.shared.buscarRazasGato(query: query, completion: completion)
        }
    }
    
    private func actualizarAlturaTabla() {
        let altura = min(CGFloat(razasDisponibles.count * 44), 176)
        razasTableHeightConstraint.constant = altura
        razasTableView.isHidden = razasDisponibles.isEmpty
        UIView.animate(withDuration: 0.2) { self.view.layoutIfNeeded() }
    }
    
    private func seleccionarRaza(_ raza: RazaModel) {
        razaField.text = raza.name
        razasDisponibles = []
        razasTableView.reloadData()
        actualizarAlturaTabla()
        razaField.resignFirstResponder()
        
        // Mostrar info de la raza obtenida de la API REST
        var info = raza.name
        if let origen = raza.origin { info += " · \(origen)" }
        if let temp = raza.temperament { info += "\n\(temp)" }
        infoRazaLabel.text = info
        infoRazaView.isHidden = false
        
        // Cargar imagen de la raza desde la API
        if let urlStr = raza.image?.url {
            APIService.shared.descargarImagen(urlStr: urlStr) { [weak self] data in
                if let data = data { self?.razaImageView.image = UIImage(data: data) }
            }
        }
    }
    
    @objc private func didTapGuardar() {
        guard let nombre = nombreField.text, !nombre.isEmpty else {
            showAlert("Ingresa el nombre de tu mascota.")
            return
        }
        guard let raza = razaField.text, !raza.isEmpty else {
            showAlert("Selecciona una raza.")
            return
        }
        guard let uid = FirebaseAuthService.shared.uidActual else { return }
        
        // Guardar en Core Data
        let mascota = CoreDataManager.shared.guardarMascota(
            nombre: nombre,
            especie: especieSeleccionada,
            raza: raza,
            fechaNacimiento: fechaNacPicker.date,
            fotoData: fotoSeleccionada,
            usuarioUID: uid
        )
        
        // Sincronizar con Firestore
        FirestoreService.shared.guardarMascota(
            mascotaId: mascota.id?.uuidString ?? UUID().uuidString,
            nombre: nombre, especie: especieSeleccionada,
            raza: raza, usuarioUID: uid
        ) { error in
            if let error = error { print("Firestore error: \(error)") }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Aviso", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableView (Razas)
extension RegistrarMascotaViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return razasDisponibles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RazaCell", for: indexPath)
        cell.textLabel?.text = razasDisponibles[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        seleccionarRaza(razasDisponibles[indexPath.row])
    }
}

// MARK: - UIImagePickerController (AVFoundation)
extension RegistrarMascotaViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let img = info[.originalImage] as? UIImage {
            fotoSeleccionada = img.jpegData(compressionQuality: 0.7)
            fotoButton.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)
            fotoButton.imageView?.contentMode = .scaleAspectFill
            fotoButton.imageView?.layer.cornerRadius = 60
            fotoButton.imageView?.clipsToBounds = true
        }
        dismiss(animated: true)
    }
}
