// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class NetworkManager {
    public static let shared = NetworkManager()
    
    public init() {}
    
    public func fetchData<T: Decodable>(url: String, apiKey: String? = nil, headerField: String? = "X-Api-Key", completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo:[NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        
        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(NSError(domain: "", code: -1, userInfo:[NSLocalizedDescriptionKey: "Invalid Response"])))
            }
            
            guard (200...299).contains(response.statusCode) else {
                print("Wrong Response, Status Code:", response.statusCode)
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo:[NSLocalizedDescriptionKey: "No Data"])))
                return
            }
            
            do {
                let newResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(newResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
