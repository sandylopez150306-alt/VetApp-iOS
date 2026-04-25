import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(red: 0.06, green: 0.53, blue: 0.49, alpha: 1)
        tabBar.backgroundColor = .systemBackground
        
        // 1. Inicio
        let home = UINavigationController(rootViewController: HomeViewController())
        home.tabBarItem = UITabBarItem(
            title: "Inicio",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // 2. Mascotas
        let mascotas = UINavigationController(rootViewController: MascotasViewController())
        mascotas.tabBarItem = UITabBarItem(
            title: "Mascotas",
            image: UIImage(systemName: "pawprint"),
            selectedImage: UIImage(systemName: "pawprint.fill")
        )
        
        // 3. Citas
        let citas = UINavigationController(rootViewController: CitasViewController())
        citas.tabBarItem = UITabBarItem(
            title: "Citas",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.badge.clock")
        )
        
        // 4. Clínica (Mapa)
        let mapa = UINavigationController(rootViewController: MapaViewController())
        mapa.tabBarItem = UITabBarItem(
            title: "Clínica",
            image: UIImage(systemName: "mappin.and.ellipse"),
            selectedImage: UIImage(systemName: "mappin.and.ellipse")
        )
        
        // 5. Perfil
        let perfil = UINavigationController(rootViewController: PerfilViewController())
        perfil.tabBarItem = UITabBarItem(
            title: "Perfil",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        viewControllers = [home, mascotas, citas, mapa, perfil]
    }
}
