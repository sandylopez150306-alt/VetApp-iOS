import UIKit
import MapKit
import CoreLocation

class MapaViewController: UIViewController {
    
    // Coordenadas de Animal Planet Vets - Alto Moche, Miramar
    private let clinicaCoord = CLLocationCoordinate2D(latitude: -8.1558, longitude: -79.0278)
    
    private let mapView: MKMapView = {
        let m = MKMapView()
        m.translatesAutoresizingMaskIntoConstraints = false
        return m
    }()
    
    private let infoCard: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.12
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let comoLlegarButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("🗺  Cómo llegar", for: .normal)
        b.backgroundColor = .systemTeal
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.layer.cornerRadius = 10
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nuestra Clínica"
        setupUI()
        configurarMapa()
        comoLlegarButton.addTarget(self, action: #selector(abrirMapsNativo), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(infoCard)
        
        let nameLabel = UILabel()
        nameLabel.text = "🏥 Animal Planet Vets"
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let addressLabel = UILabel()
        addressLabel.text = "Alto Moche - Miramar, La Libertad"
        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .secondaryLabel
        
        let horasLabel = UILabel()
        horasLabel.text = "Lun–Sáb: 8:00 AM – 7:00 PM"
        horasLabel.font = .systemFont(ofSize: 13)
        horasLabel.textColor = .systemGreen
        
        [nameLabel, addressLabel, horasLabel, comoLlegarButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            infoCard.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoCard.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            
            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            
            horasLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            horasLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            
            comoLlegarButton.topAnchor.constraint(equalTo: horasLabel.bottomAnchor, constant: 16),
            comoLlegarButton.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            comoLlegarButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            comoLlegarButton.heightAnchor.constraint(equalToConstant: 46),
            comoLlegarButton.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func configurarMapa() {
        // Agregar pin de la clínica
        let anotacion = MKPointAnnotation()
        anotacion.coordinate = clinicaCoord
        anotacion.title = "Animal Planet Vets"
        anotacion.subtitle = "Alto Moche - Miramar"
        mapView.addAnnotation(anotacion)
        
        // Centrar mapa en la clínica
        let region = MKCoordinateRegion(center: clinicaCoord,
                                        latitudinalMeters: 800,
                                        longitudinalMeters: 800)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
    }
    
    @objc private func abrirMapsNativo() {
        let coords = clinicaCoord
        let placemark = MKPlacemark(coordinate: coords)
        let item = MKMapItem(placemark: placemark)
        item.name = "Animal Planet Vets"
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

extension MapaViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        view.markerTintColor = .systemTeal
        view.glyphImage = UIImage(systemName: "cross.case.fill")
        view.canShowCallout = true
        return view
    }
}
