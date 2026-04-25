import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var mascotas: [MascotaEntity] = []
    private var citasProximas: [CitaEntity] = []
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.06, green: 0.53, blue: 0.49, alpha: 1) // teal oscuro
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let waveMask: WaveView = {
        let w = WaveView()
        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v.layer.cornerRadius = 28
        v.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36)
        ])
        return v
    }()
    private let mascotasCard   = StatCard(icon: "pawprint.fill",   color: UIColor(red: 0.06, green: 0.53, blue: 0.49, alpha: 1), title: "Mascotas")
    private let citasCard      = StatCard(icon: "calendar.badge.clock", color: UIColor(red: 0.96, green: 0.58, blue: 0.20, alpha: 1), title: "Citas")
    private let proximaCard    = StatCard(icon: "bell.badge.fill", color: UIColor(red: 0.91, green: 0.30, blue: 0.30, alpha: 1), title: "Próxima")
    
    // Próximas citas
    private let citasSectionLabel: UILabel = {
        let l = UILabel()
        l.text = "Próximas Citas"
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let citasCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 220, height: 120)
        layout.minimumLineSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.register(CitaProximaCell.self, forCellWithReuseIdentifier: "CitaProximaCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let noCitasLabel: UILabel = {
        let l = UILabel()
        l.text = "Sin citas próximas "
        l.font = UIFont.systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let accionesSectionLabel: UILabel = {
        let l = UILabel()
        l.text = "Acciones Rápidas"
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let accionesStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let mascotasSectionLabel: UILabel = {
        let l = UILabel()
        l.text = "Mis Mascotas"
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let mascotasCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 110, height: 130)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.register(MascotaMiniCell.self, forCellWithReuseIdentifier: "MascotaMiniCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let noMascotasLabel: UILabel = {
        let l = UILabel()
        l.text = "Registra tu primera mascota +"
        l.font = UIFont.systemFont(ofSize: 15)
        l.textColor = .systemTeal
        l.textAlignment = .center
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.systemGroupedBackground
        setupScrollView()
        setupHeader()
        setupStats()
        setupCitasSection()
        setupAccionesRapidas()
        setupMascotasSection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        cargarDatos()
        animateCards()
    }
    
    // MARK: - Setup
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeader() {
        contentView.addSubview(headerView)
        headerView.addSubview(waveMask)
        headerView.addSubview(greetingLabel)
        headerView.addSubview(nameLabel)
        headerView.addSubview(avatarView)
        
        // Círculos decorativos en el header
        addDecorativeCircle(to: headerView, size: 120, x: -30, y: -30, alpha: 0.08)
        addDecorativeCircle(to: headerView, size: 80, x: UIScreen.main.bounds.width - 60, y: 10, alpha: 0.10)
        addDecorativeCircle(to: headerView, size: 50, x: UIScreen.main.bounds.width - 20, y: 70, alpha: 0.07)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200),
            
            greetingLabel.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 24),
            greetingLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            
            nameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: avatarView.leadingAnchor, constant: -12),
            
            avatarView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            avatarView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            avatarView.widthAnchor.constraint(equalToConstant: 56),
            avatarView.heightAnchor.constraint(equalToConstant: 56),
            
            waveMask.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            waveMask.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            waveMask.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            waveMask.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: greetingLabel.text = "Buenos días"
        case 12..<18: greetingLabel.text = "Buenas tardes"
        default: greetingLabel.text = "Buenas noches"
        }
    }
    
    private func addDecorativeCircle(to view: UIView, size: CGFloat, x: CGFloat, y: CGFloat, alpha: CGFloat) {
        let circle = UIView()
        circle.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        circle.layer.cornerRadius = size / 2
        circle.frame = CGRect(x: x, y: y, width: size, height: size)
        view.addSubview(circle)
    }
    
    private func setupStats() {
        let statsStack = UIStackView(arrangedSubviews: [mascotasCard, citasCard, proximaCard])
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 12
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsStack)
        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            statsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsStack.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupCitasSection() {
        contentView.addSubview(citasSectionLabel)
        contentView.addSubview(citasCollectionView)
        contentView.addSubview(noCitasLabel)
        citasCollectionView.dataSource = self
        citasCollectionView.delegate = self
        NSLayoutConstraint.activate([
            citasSectionLabel.topAnchor.constraint(equalTo: mascotasCard.bottomAnchor, constant: 28),
            citasSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            citasCollectionView.topAnchor.constraint(equalTo: citasSectionLabel.bottomAnchor, constant: 12),
            citasCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            citasCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            citasCollectionView.heightAnchor.constraint(equalToConstant: 130),
            noCitasLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            noCitasLabel.centerYAnchor.constraint(equalTo: citasCollectionView.centerYAnchor)
        ])
    }
    
    private func setupAccionesRapidas() {
        let acciones: [(String, String, UIColor, Selector)] = [
            ("plus.circle.fill",   "Nueva\nMascota",  UIColor(red: 0.06, green: 0.53, blue: 0.49, alpha: 1), #selector(irAMascotas)),
            ("calendar.badge.plus","Agendar\nCita",   UIColor(red: 0.96, green: 0.58, blue: 0.20, alpha: 1), #selector(irACitas)),
            ("mappin.and.ellipse", "Ver\nClínica",    UIColor(red: 0.91, green: 0.30, blue: 0.30, alpha: 1), #selector(irAMapa))
        ]
        
        for (icon, title, color, action) in acciones {
            let btn = QuickActionButton(icon: icon, title: title, color: color)
            btn.addTarget(self, action: action, for: .touchUpInside)
            accionesStack.addArrangedSubview(btn)
        }
        
        contentView.addSubview(accionesSectionLabel)
        contentView.addSubview(accionesStack)
        NSLayoutConstraint.activate([
            accionesSectionLabel.topAnchor.constraint(equalTo: citasCollectionView.bottomAnchor, constant: 28),
            accionesSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            accionesStack.topAnchor.constraint(equalTo: accionesSectionLabel.bottomAnchor, constant: 12),
            accionesStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            accionesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            accionesStack.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupMascotasSection() {
        contentView.addSubview(mascotasSectionLabel)
        contentView.addSubview(mascotasCollectionView)
        contentView.addSubview(noMascotasLabel)
        mascotasCollectionView.dataSource = self
        mascotasCollectionView.delegate = self
        NSLayoutConstraint.activate([
            mascotasSectionLabel.topAnchor.constraint(equalTo: accionesStack.bottomAnchor, constant: 28),
            mascotasSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mascotasCollectionView.topAnchor.constraint(equalTo: mascotasSectionLabel.bottomAnchor, constant: 12),
            mascotasCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mascotasCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mascotasCollectionView.heightAnchor.constraint(equalToConstant: 140),
            mascotasCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            noMascotasLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            noMascotasLabel.centerYAnchor.constraint(equalTo: mascotasCollectionView.centerYAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(irAMascotas))
        noMascotasLabel.addGestureRecognizer(tap)
        noMascotasLabel.isUserInteractionEnabled = true
    }
    
    // MARK: - Data
        private func cargarDatos() {
            guard let uid = FirebaseAuthService.shared.uidActual else { return }
            let email = Auth.auth().currentUser?.email ?? "Usuario"
            let nombre = String(email.split(separator: "@").first ?? "Usuario")
            nameLabel.text = nombre.capitalized
            
            let db = Firestore.firestore()

            db.collection("mascotas").whereField("usuarioUID", isEqualTo: uid)
                .addSnapshotListener { [weak self] snapshot, _ in
                    guard let self = self, let documents = snapshot?.documents else { return }
    
                    self.mascotasCard.updateValue("\(documents.count)")
                    
                    // Control de visibilidad
                    self.noMascotasLabel.isHidden = !documents.isEmpty
                    self.mascotasCollectionView.isHidden = documents.isEmpty
                    
                    // Recarga la colección de miniaturas
                    self.mascotasCollectionView.reloadData()
                    print("DEBUG: \(documents.count) mascotas sincronizadas desde la nube.")
                }

            db.collection("citas").whereField("usuarioUID", isEqualTo: uid)
                .addSnapshotListener { [weak self] snapshot, _ in
                    guard let self = self, let documents = snapshot?.documents else { return }
                    
                    // Actualiza el contador visual de citas
                    self.citasCard.updateValue("\(documents.count)")
                    
                    // Control de visibilidad de la sección
                    self.noCitasLabel.isHidden = !documents.isEmpty
                    self.citasCollectionView.isHidden = documents.isEmpty
                    
                    // Lógica para detectar la fecha de la cita más próxima
                    if let primeraCita = documents.first?.data(),
                       let timestamp = primeraCita["fecha"] as? Timestamp {
                        let fecha = timestamp.dateValue()
                        let fmt = DateFormatter()
                        fmt.dateFormat = "d MMM"
                        fmt.locale = Locale(identifier: "es_PE")
                        self.proximaCard.updateValue(fmt.string(from: fecha))
                    } else {
                        self.proximaCard.updateValue("–")
                    }

                    self.citasCollectionView.reloadData()
                    print("DEBUG: \(documents.count) citas sincronizadas desde la nube.")
                }
        }
    
    // MARK: - Animations
    private func animateCards() {
        let cards = [mascotasCard, citasCard, proximaCard]
        cards.enumerated().forEach { idx, card in
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 30)
            UIView.animate(withDuration: 0.5, delay: Double(idx) * 0.1,
                           usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                card.alpha = 1
                card.transform = .identity
            }
        }
    }
    
    // MARK: - Navigation
    @objc private func irAMascotas() {
        tabBarController?.selectedIndex = 1
    }
    @objc private func irACitas() {
        tabBarController?.selectedIndex = 2
    }
    @objc private func irAMapa() {
        tabBarController?.selectedIndex = 3
    }
}

// MARK: - CollectionView
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == citasCollectionView { return citasProximas.count }
        return mascotas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == citasCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CitaProximaCell", for: indexPath) as! CitaProximaCell
            cell.configure(with: citasProximas[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MascotaMiniCell", for: indexPath) as! MascotaMiniCell
            cell.configure(with: mascotas[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mascotasCollectionView {
            let vc = CitasViewController()
            vc.mascota = mascotas[indexPath.row]
            // Navegar al tab de mascotas primero
            tabBarController?.selectedIndex = 1
        }
    }
}

// MARK: - WaveView (forma decorativa del header)
class WaveView: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.4))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height * 0.4),
                          controlPoint: CGPoint(x: rect.width / 2, y: -rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.close()
        UIColor.systemGroupedBackground.setFill()
        path.fill()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
}

// MARK: - StatCard
class StatCard: UIView {
    private let iconView    = UIImageView()
    private let valueLabel  = UILabel()
    private let titleLabel  = UILabel()
    
    init(icon: String, color: UIColor, title: String) {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        let iconBg = UIView()
        iconBg.backgroundColor = color.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 10
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel.text = "–"
        valueLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconBg)
        iconBg.addSubview(iconView)
        addSubview(valueLabel)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconBg.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            iconBg.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconBg.widthAnchor.constraint(equalToConstant: 32),
            iconBg.heightAnchor.constraint(equalToConstant: 32),
            
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            valueLabel.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func updateValue(_ value: String) {
        UIView.transition(with: valueLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.valueLabel.text = value
        }
    }
}

// MARK: - QuickActionButton
class QuickActionButton: UIControl {
    init(icon: String, title: String, color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color.withAlphaComponent(0.10)
        layer.cornerRadius = 16
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = color
        label.numberOfLines = 2
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 28),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        ])
        
        // Efecto tap
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func touchDown() {
        UIView.animate(withDuration: 0.12) { self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94) }
    }
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
            self.transform = .identity
        }, completion: nil)
    }
}

// MARK: - CitaProximaCell
class CitaProximaCell: UICollectionViewCell {
    private let serviceLabel = UILabel()
    private let dateLabel    = UILabel()
    private let mascotaLabel = UILabel()
    private let iconView     = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.07
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        
        iconView.image = UIImage(systemName: "calendar.circle.fill")
        iconView.tintColor = .systemOrange
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        serviceLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        serviceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mascotaLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        mascotaLabel.textColor = .systemTeal
        mascotaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [iconView, serviceLabel, dateLabel, mascotaLabel].forEach { contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            serviceLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            serviceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            serviceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            dateLabel.topAnchor.constraint(equalTo: serviceLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mascotaLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            mascotaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with cita: CitaEntity) {
        serviceLabel.text = cita.tipoServicio
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.locale = Locale(identifier: "es_PE")
        dateLabel.text = "\(fmt.string(from: cita.fecha ?? Date())) · \(cita.hora ?? "")"
        
        // Buscar nombre de mascota en Core Data
        let req: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", cita.mascotaId! as CVarArg)
        let result = try? CoreDataManager.shared.context.fetch(req)
        mascotaLabel.text = "🐾 \(result?.first?.nombre ?? "Mascota")"
    }
}

// MARK: - MascotaMiniCell
class MascotaMiniCell: UICollectionViewCell {
    private let fotoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 35
        iv.backgroundColor = .systemTeal.withAlphaComponent(0.15)
        iv.image = UIImage(systemName: "pawprint.fill")
        iv.tintColor = .systemTeal
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nombreLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let especieLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.07
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        [fotoView, nombreLabel, especieLabel].forEach { contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            fotoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            fotoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            fotoView.widthAnchor.constraint(equalToConstant: 70),
            fotoView.heightAnchor.constraint(equalToConstant: 70),
            nombreLabel.topAnchor.constraint(equalTo: fotoView.bottomAnchor, constant: 8),
            nombreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nombreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            especieLabel.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 2),
            especieLabel.leadingAnchor.constraint(equalTo: nombreLabel.leadingAnchor),
            especieLabel.trailingAnchor.constraint(equalTo: nombreLabel.trailingAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with mascota: MascotaEntity) {
        nombreLabel.text = mascota.nombre
        especieLabel.text = mascota.especie
        if let data = mascota.fotoData, let img = UIImage(data: data) {
            fotoView.image = img
        }
    }
}
