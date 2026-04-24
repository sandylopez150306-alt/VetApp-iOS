import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .systemTeal
        
        let mascotas = UINavigationController(rootViewController: MascotasViewController())
        mascotas.tabBarItem = UITabBarItem(title: "Mascotas", image: UIImage(systemName: "pawprint.fill"), tag: 0)
        
        let citas = UINavigationController(rootViewController: CitasViewController())
        citas.tabBarItem = UITabBarItem(title: "Citas", image: UIImage(systemName: "calendar"), tag: 1)
        
        let mapa = UINavigationController(rootViewController: MapaViewController())
        mapa.tabBarItem = UITabBarItem(title: "Clínica", image: UIImage(systemName: "mappin.and.ellipse"), tag: 2)
        
        viewControllers = [mascotas, citas, mapa]
    }
}
