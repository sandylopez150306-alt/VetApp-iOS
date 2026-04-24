import UIKit
import FirebaseFirestore
import FirebaseAuth

class AgendarCitaViewController: UIViewController {
    
    var mascota: MascotaEntity?
    private var todasMisMascotas: [MascotaEntity] = []
    private var mascotaSeleccionada: MascotaEntity?
    
    private let servicios = ["Consulta general", "Vacunación", "Desparasitación", "Cirugía menor", "Baño y peluquería", "Control de peso"]
    private var servicioSeleccionado = "Consulta general"
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mascotaPickerView = UIPickerView()
    private let servicioPickerView = UIPickerView()
    
    private let fechaPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.minimumDate = Date()
        if #available(iOS 14.0, *) { dp.preferredDatePickerStyle = .compact }
        return dp
    }()
    
    // Selector de hora profesional
    private let horaPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .compact
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
        
        // Cargar mascotas del usuario
        if let uid = FirebaseAuthService.shared.uidActual {
            todasMisMascotas = CoreDataManager.shared.obtenerTodasLasMascotas(usuarioUID: uid)
        }
        mascotaSeleccionada = mascota ?? todasMisMascotas.first
        
        setupScrollUI()
        
        servicioPickerView.delegate = self; servicioPickerView.dataSource = self
        mascotaPickerView.delegate = self; mascotaPickerView.dataSource = self
        guardarButton.addTarget(self, action: #selector(didTapGuardar), for: .touchUpInside)
    }
    
    private func setupScrollUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Organizamos con tarjetas para mejor diseño
        let mascotaCard = createCard(with: [makeLabel("Mascota:"), mascotaPickerView])
        let servicioCard = createCard(with: [makeLabel("Tipo de servicio:"), servicioPickerView])
        let fechaCard = createCard(with: [makeLabel("Fecha:"), fechaPicker, makeLabel("Hora:"), horaPicker])
        
        let stack = UIStackView(arrangedSubviews: [mascotaCard, servicioCard, fechaCard, guardarButton])
        stack.axis = .vertical
        stack.spacing = 20
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
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            mascotaPickerView.heightAnchor.constraint(equalToConstant: 80),
            servicioPickerView.heightAnchor.constraint(equalToConstant: 80),
            guardarButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func createCard(with views: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 20
        let cardStack = UIStackView(arrangedSubviews: views)
        cardStack.axis = .vertical
        cardStack.spacing = 8
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardStack)
        
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }
    
    private func makeLabel(_ text: String) -> UILabel {
        let l = UILabel(); l.text = text; l.font = .systemFont(ofSize: 16, weight: .bold); return l
    }
    
    @objc private func didTapGuardar() {
        guard let selectedMascota = mascotaSeleccionada else { return }
        
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        let horaString = fmt.string(from: horaPicker.date)
        
        guard let uid = FirebaseAuthService.shared.uidActual else { return }
        
        FirestoreService.shared.guardarCita(
            mascotaId: selectedMascota.id?.uuidString ?? "",
            fecha: fechaPicker.date,
            hora: horaString,
            tipoServicio: servicioSeleccionado,
            usuarioUID: uid
        ) { [weak self] result in
            guard let self = self else { return }
            if case .success(let firestoreId) = result {
                let nuevaCita = CoreDataManager.shared.guardarCita(
                    fecha: self.fechaPicker.date,
                    hora: horaString,
                    tipoServicio: self.servicioSeleccionado,
                    mascotaId: selectedMascota.id ?? UUID(),
                    firestoreId: firestoreId
                )
                
                nuevaCita.mascota = selectedMascota
                CoreDataManager.shared.saveContext()
                
                DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
            }
        }
    }
}

extension AgendarCitaViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == mascotaPickerView ? todasMisMascotas.count : servicios.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == mascotaPickerView ? todasMisMascotas[row].nombre : servicios[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == mascotaPickerView { mascotaSeleccionada = todasMisMascotas[row] }
        else { servicioSeleccionado = servicios[row] }
    }
}
