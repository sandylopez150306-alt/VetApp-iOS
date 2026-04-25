import Foundation

// Modelo para las razas que devuelve la API
struct RazaModel: Codable {
    let id: Int?
    let name: String
    let temperament: String?
    let origin: String?
    let description: String?
    let image: RazaImage?
    
    struct RazaImage: Codable {
        let url: String?
    }
}

class APIService {
    static let shared = APIService()
    
    private let dogAPIBase = "https://api.thedogapi.com/v1"
    private let catAPIBase = "https://api.thecatapi.com/v1"
    
    func buscarRazasPerro(query: String, completion: @escaping ([RazaModel]) -> Void) {
        let urlStr = "\(dogAPIBase)/breeds/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        fetchRazas(urlStr: urlStr, completion: completion)
    }
 
    func buscarRazasGato(query: String, completion: @escaping ([RazaModel]) -> Void) {
        let urlStr = "\(catAPIBase)/breeds/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        fetchRazas(urlStr: urlStr, completion: completion)
    }
    
    func obtenerTodasRazasPerro(completion: @escaping ([RazaModel]) -> Void) {
        fetchRazas(urlStr: "\(dogAPIBase)/breeds?limit=50", completion: completion)
    }
    
    func obtenerTodasRazasGato(completion: @escaping ([RazaModel]) -> Void) {
        fetchRazas(urlStr: "\(catAPIBase)/breeds", completion: completion)
    }
    
    private func fetchRazas(urlStr: String, completion: @escaping ([RazaModel]) -> Void) {
        guard let url = URL(string: urlStr) else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let razas = (try? JSONDecoder().decode([RazaModel].self, from: data)) ?? []
            DispatchQueue.main.async { completion(razas) }
        }.resume()
    }
    
    func descargarImagen(urlStr: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlStr) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async { completion(data) }
        }.resume()
    }
}
