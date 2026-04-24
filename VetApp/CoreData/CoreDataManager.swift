import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    // El contexto se obtiene de forma segura desde el AppDelegate
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Mascotas
    
    func guardarMascota(nombre: String, especie: String, raza: String,
                        fechaNacimiento: Date, fotoData: Data?, usuarioUID: String) -> MascotaEntity {
        let mascota = MascotaEntity(context: self.context)
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
    
    // Método unificado para obtener todas las mascotas
    func obtenerMascotas(usuarioUID: String) -> [MascotaEntity] {
        let request: NSFetchRequest<MascotaEntity> = MascotaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "usuarioUID == %@", usuarioUID)
        request.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        do {
            return try self.context.fetch(request)
        } catch {
            print("Error al obtener mascotas: \(error)")
            return []
        }
    }
    
    // Alias para que AgendarCitaViewController no de error
    func obtenerTodasLasMascotas(usuarioUID: String) -> [MascotaEntity] {
        return obtenerMascotas(usuarioUID: usuarioUID)
    }
    
    func eliminarMascota(_ mascota: MascotaEntity) {
        self.context.delete(mascota)
        saveContext()
    }
    
    // MARK: - Citas
    
    func guardarCita(fecha: Date, hora: String, tipoServicio: String,
                     mascotaId: UUID, firestoreId: String) -> CitaEntity {
        let cita = CitaEntity(context: self.context)
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
            return try self.context.fetch(request)
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
            return try self.context.fetch(request)
        } catch {
            return []
        }
    }
    
    // MARK: - Save
    
    func saveContext() {
        if self.context.hasChanges {
            do {
                try self.context.save()
            } catch {
                print("Error al guardar Core Data: \(error)")
            }
        }
    }
}
