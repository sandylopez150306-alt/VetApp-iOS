import UIKit

class AgendarCitaViewController: UIViewController {
    
    var mascota: MascotaEntity?
    
    private let servicios = ["Consulta general", "Vacunación", "Desparasitación",
                              "Cirugía menor", "Baño y peluquería", "Control de peso"]
    private var servicioSeleccionado = "Consulta general"
    
    private let servicioPickerView = UIPickerView()
    private let fechaPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        if #available(iOS 14.0, *) { dp.preferredDatePickerStyle = .inline }
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    private let horaField = VetTextField(placeholder: "Hora (ej: 10:00 AM)")
    
    private let guardarButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Confirmar Cita", for: .normal)
        b.backgroundColor = .systemTeal
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Agendar Cita"
        view.backgroundColor = .systemBackground
        setupUI()
        guardarButton.addTarget(self, action: #selector(didTapGuardar), for: .touchUpInside)
        servicioPickerView.dataSource = self
        servicioPickerView.delegate = self
    }
    
    private func setupUI() {
        let servicioLabel = makeLabel("Tipo de servicio:")
        let fechaLabel    = makeLabel("Selecciona la fecha:")
        
        servicioPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [servicioLabel, servicioPickerView, fechaLabel, fechaPicker, horaField, guardarButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            servicioPickerView.heightAnchor.constraint(equalToConstant: 120),
            horaField.heightAnchor.constraint(equalToConstant: 52),
            guardarButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private func makeLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        return l
    }
    
    @objc private func didTapGuardar() {
        guard let hora = horaField.text, !hora.isEmpty else {
            showAlert("Ingresa la hora de la cita.")
            return
        }
        guard let uid = FirebaseAuthService.shared.uidActual else { return }
        let mascotaId = mascota?.id ?? UUID()
        
        // Guardar en Firestore primero para obtener el ID
        FirestoreService.shared.guardarCita(
            mascotaId: mascotaId.uuidString,
            fecha: fechaPicker.date,
            hora: hora,
            tipoServicio: servicioSeleccionado,
            usuarioUID: uid
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let firestoreId):
                // Guardar en Core Data con el ID de Firestore
                let cita = CoreDataManager.shared.guardarCita(
                    fecha: self.fechaPicker.date,
                    hora: hora,
                    tipoServicio: self.servicioSeleccionado,
                    mascotaId: mascotaId,
                    firestoreId: firestoreId
                )
                // Programar notificación push
                NotificationManager.shared.programarRecordatorio(
                    citaId: firestoreId,
                    mascotaNombre: self.mascota?.nombre ?? "tu mascota",
                    tipoServicio: self.servicioSeleccionado,
                    fecha: self.fechaPicker.date
                )
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
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
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { servicios.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { servicios[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        servicioSeleccionado = servicios[row]
    }
}
