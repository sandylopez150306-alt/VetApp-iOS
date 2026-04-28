import UIKit

class AgendarCitaViewController: UIViewController {
    
    var mascota: MascotaEntity?
    private var todasLasMascotas: [MascotaEntity] = []
    private var mascotaSeleccionada: MascotaEntity?
    
    private let servicios = ["Consulta general", "Vacunación", "Desparasitación", "Cirugía menor", "Baño y peluquería", "Control de peso"]
    private var servicioSeleccionado = "Consulta general"
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mascotaPicker = UIPickerView()
    private let servicioPicker = UIPickerView()
    
    // --- NUEVOS ELEMENTOS PARA INFO DE MASCOTA ---
    private let mascotaInfoView = UIView()
    private let fotoMascota: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let nombreMascotaLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let fechaPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        dp.preferredDatePickerStyle = .compact
        return dp
    }()
    
    private let horaPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .compact
        dp.locale = Locale(identifier: "es_PE")
        return dp
    }()
    
    private let guardarButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Confirmar Cita", for: .normal)
        b.backgroundColor = .systemTeal
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        b.layer.cornerRadius = 16
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Agendar Cita"
        view.backgroundColor = .systemGroupedBackground
        
        if let uid = FirebaseAuthService.shared.uidActual {
            self.todasLasMascotas = CoreDataManager.shared.obtenerTodasLasMascotas(usuarioUID: uid)
            DispatchQueue.main.async { self.mascotaPicker.reloadAllComponents() }
        }
        
        mascotaSeleccionada = mascota ?? todasLasMascotas.first
        if let ms = mascotaSeleccionada { actualizarVistaMascota(ms) }
        
        setupUI()
        configurarDelegates()
        guardarButton.addTarget(self, action: #selector(didTapGuardar), for: .touchUpInside)
    }
    
    private func configurarDelegates() {
        mascotaPicker.delegate = self; mascotaPicker.dataSource = self
        servicioPicker.delegate = self; servicioPicker.dataSource = self
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configurar vista de info mascota
        mascotaInfoView.backgroundColor = .systemBackground
        mascotaInfoView.layer.cornerRadius = 16
        mascotaInfoView.addSubview(fotoMascota)
        mascotaInfoView.addSubview(nombreMascotaLabel)
        
        let mascotaCard = createCardView(title: "Mis Mascotas", picker: mascotaPicker)
        let servicioCard = createCardView(title: "Nuestros Servicios", picker: servicioPicker)
        
        let stack = UIStackView(arrangedSubviews: [
            mascotaInfoView, mascotaCard, servicioCard,
            makeLabel(" Fecha:"), fechaPicker,
            makeLabel(" Hora:"), horaPicker,
            guardarButton
        ])
        
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
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
            
            // Constraints info mascota
            mascotaInfoView.heightAnchor.constraint(equalToConstant: 80),
            fotoMascota.leadingAnchor.constraint(equalTo: mascotaInfoView.leadingAnchor, constant: 16),
            fotoMascota.centerYAnchor.constraint(equalTo: mascotaInfoView.centerYAnchor),
            fotoMascota.widthAnchor.constraint(equalToConstant: 60),
            fotoMascota.heightAnchor.constraint(equalToConstant: 60),
            nombreMascotaLabel.leadingAnchor.constraint(equalTo: fotoMascota.trailingAnchor, constant: 16),
            nombreMascotaLabel.centerYAnchor.constraint(equalTo: mascotaInfoView.centerYAnchor),
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            guardarButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func actualizarVistaMascota(_ mascota: MascotaEntity) {
        nombreMascotaLabel.text = mascota.nombre
        if let data = mascota.fotoData { fotoMascota.image = UIImage(data: data) }
        else { fotoMascota.image = UIImage(systemName: "pawprint.fill") }
    }
    
    private func createCardView(title: String, picker: UIPickerView) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        let label = makeLabel(title)
        label.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        container.addSubview(picker)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            picker.topAnchor.constraint(equalTo: label.bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            picker.heightAnchor.constraint(equalToConstant: 100)
        ])
        return container
    }

    private func makeLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 16, weight: .bold)
        return l
    }
    
    @objc private func didTapGuardar() {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        fmt.locale = Locale(identifier: "es_PE")
        let horaString = fmt.string(from: horaPicker.date)
        
        guard let selectedMascota = mascotaSeleccionada else { return }
        guard let uid = FirebaseAuthService.shared.uidActual else { return }
        
        let mascotaId = selectedMascota.id ?? UUID()
        
        FirestoreService.shared.guardarCita(
            mascotaId: mascotaId.uuidString,
            fecha: fechaPicker.date,
            hora: horaString,
            tipoServicio: servicioSeleccionado,
            usuarioUID: uid
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let firestoreId):
                _ = CoreDataManager.shared.guardarCita(
                    fecha: self.fechaPicker.date, hora: horaString,
                    tipoServicio: self.servicioSeleccionado, mascotaId: mascotaId, firestoreId: firestoreId
                )
                DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
            case .failure(let error):
                DispatchQueue.main.async { self.showAlert(error.localizedDescription) }
            }
        }
    }
    
    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Aviso", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AgendarCitaViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == mascotaPicker ? todasLasMascotas.count : servicios.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == mascotaPicker ? todasLasMascotas[row].nombre : servicios[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == mascotaPicker {
            mascotaSeleccionada = todasLasMascotas[row]
            actualizarVistaMascota(todasLasMascotas[row])
        } else { servicioSeleccionado = servicios[row] }
    }
}
