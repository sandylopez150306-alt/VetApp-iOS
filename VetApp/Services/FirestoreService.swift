import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // MARK: - Mascotas
    
    func guardarMascota(mascotaId: String, nombre: String, especie: String,
                        raza: String, usuarioUID: String,
                        completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "nombre": nombre,
            "especie": especie,
            "raza": raza,
            "usuarioUID": usuarioUID,
            "fechaCreacion": Timestamp()
        ]
        db.collection("mascotas").document(mascotaId).setData(data, completion: completion)
    }
    
    // MARK: - Citas
    
    func guardarCita(mascotaId: String, fecha: Date, hora: String,
                     tipoServicio: String, usuarioUID: String,
                     completion: @escaping (Result<String, Error>) -> Void) {
        let ref = db.collection("citas").document()
        let data: [String: Any] = [
            "mascotaId": mascotaId,
            "fecha": Timestamp(date: fecha),
            "hora": hora,
            "tipoServicio": tipoServicio,
            "estado": "Pendiente",
            "usuarioUID": usuarioUID
        ]
        ref.setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(ref.documentID))
            }
        }
    }
}
