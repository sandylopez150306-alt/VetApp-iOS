import FirebaseAuth

class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    
    var usuarioActual: User? { Auth.auth().currentUser }
    var uidActual: String? { Auth.auth().currentUser?.uid }
    
    func registrar(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func iniciarSesion(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func cerrarSesion() {
        try? Auth.auth().signOut()
    }
}
