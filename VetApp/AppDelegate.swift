import UIKit
import CoreData
import FirebaseCore
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        NotificationManager.shared.solicitarPermiso()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VetApp")
        
        // CORRECCIÓN: Habilitamos la migración automática para evitar el error de "missing mapping model"
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // Si falla la migración, borramos el store para evitar el SIGKILL/Crash
                let fileManager = FileManager.default
                if let storeURL = container.persistentStoreDescriptions.first?.url {
                    try? fileManager.removeItem(at: storeURL)
                }
                fatalError("Error irrecuperable en Core Data: \(error)")
            }
        }
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Método que solicitaste para obtener todas las mascotas directamente desde el AppDelegate
    
    func obtenerTodasLasMascotas(usuarioUID: String) -> [MascotaEntity] {
        let request: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "usuarioUID == %@", usuarioUID)
        
        do {
            // CORRECCIÓN: Aquí es donde fallaba, usamos persistentContainer.viewContext
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error al obtener todas las mascotas: \(error)")
            return []
        }
    }
}
