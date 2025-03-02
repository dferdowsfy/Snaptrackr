import Foundation

// Service for Perplexity API integration
class PerplexityService {
    static let shared = PerplexityService()
    
    // API Key (in a real app, this would be stored securely)
    private let apiKey = "YOUR_PERPLEXITY_API_KEY" // Replace with your actual API key
    
    private init() {}
    
    // Enum for possible errors
    enum PerplexityError: Error {
        case networkError(Error)
        case invalidResponse
        case noDataFound
        case parsingError
    }
    
    // Function to retrieve a weblink for a product
    func getWeblink(for productName: String, completion: @escaping (Result<String, PerplexityError>) -> Void) {
        // In a real implementation, this would make an API call to Perplexity API
        // For now, we'll simulate the lookup with mock data
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Generate a mock weblink based on the product name
            let formattedName = productName.lowercased().replacingOccurrences(of: " ", with: "-")
            let weblink = "https://www.example.com/products/\(formattedName)"
            
            completion(.success(weblink))
        }
    }
    
    // MARK: - Real API Implementation (commented out)
    /*
    // Function to retrieve a weblink for a product (real implementation)
    func getWeblinkReal(for productName: String, completion: @escaping (Result<String, PerplexityError>) -> Void) {
        // Construct the API URL for Perplexity
        let baseURL = "https://api.perplexity.ai/search"
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create the request body
        let query = "Find a purchase link for \(productName)"
        let requestBody: [String: Any] = [
            "query": query,
            "max_tokens": 100
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.parsingError))
            return
        }
        
        // Make the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noDataFound))
                return
            }
            
            do {
                // Parse the JSON response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let answer = json["answer"] as? String {
                    
                    // Extract URL from the answer using regex
                    let urlPattern = #"https?://[^\s]+"#
                    if let urlRange = answer.range(of: urlPattern, options: .regularExpression) {
                        let weblink = String(answer[urlRange])
                        completion(.success(weblink))
                    } else {
                        // No URL found in the answer
                        completion(.failure(.parsingError))
                    }
                } else {
                    completion(.failure(.parsingError))
                }
            } catch {
                completion(.failure(.parsingError))
            }
        }.resume()
    }
    */
} 