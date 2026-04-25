import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Mascotas
    
    func guardarMascota(nombre: String, especie: String, raza: String,
                        fechaNacimiento: Date, fotoData: Data?, usuarioUID: String) -> MascotaEntity {
        let mascota = MascotaEntity(context: context)
        mascota.id = UUID()
        mascota.nombre = nombre
        mascota.especie = especie
        mascota.raza = raza
        mascota.fechaNacimiento = fechaNacimiento
        mascota.fotoData = fotoData
        mascota.usuarioUID = usuarioUID
        saveContext()
        return mascota
    }
    
    func obtenerMascotas(usuarioUID: String) -> [MascotaEntity] {
        let request: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "usuarioUID == %@", usuarioUID)
        request.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error al obtener mascotas: \(error)")
            return []
        }
    }
    
    func eliminarMascota(_ mascota: MascotaEntity) {
        context.delete(mascota)
        saveContext()
    }
    
    // MARK: - Citas
    
    func guardarCita(fecha: Date, hora: String, tipoServicio: String,
                     mascotaId: UUID, firestoreId: String) -> CitaEntity {
        let cita = CitaEntity(context: context)
        cita.id = UUID()
        cita.fecha = fecha
        cita.hora = hora
        cita.tipoServicio = tipoServicio
        cita.estado = "Pendiente"
        cita.mascotaId = mascotaId
        cita.firestoreId = firestoreId
        saveContext()
        return cita
    }
    
    func obtenerCitas(mascotaId: UUID) -> [CitaEntity] {
        let request: NSFetchRequest<CitaEntity> = CitaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "mascotaId == %@", mascotaId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "fecha", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error al obtener citas: \(error)")
            return []
        }
    }
    
    func obtenerTodasLasCitas(usuarioUID: String) -> [CitaEntity] {
        let mascotas = obtenerMascotas(usuarioUID: usuarioUID)
        let ids = mascotas.compactMap { $0.id }
        
        let request: NSFetchRequest<CitaEntity> = CitaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "mascotaId IN %@", ids)
        request.sortDescriptors = [NSSortDescriptor(key: "fecha", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
    
    // MARK: - Save
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error al guardar Core Data: \(error)")
            }
        }
    }
}
