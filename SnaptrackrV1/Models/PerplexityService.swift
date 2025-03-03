import Foundation

// Service for Perplexity API integration
class PerplexityService {
    static let shared = PerplexityService()
    
    // API Key from the configuration
    private let apiKey = "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"
    
    private init() {}
    
    // Enum for possible errors
    enum PerplexityError: Error {
        case networkError(Error)
        case invalidResponse
        case noDataFound
        case parsingError
        case noWeblinkFound
    }
    
    // Function to get weblink for a product
    func getWeblink(for productName: String, completion: @escaping (Result<String, PerplexityError>) -> Void) {
        let baseURL = "https://api.perplexity.ai/chat/completions"
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let prompt = """
        Find a product link for '\(productName)'. Return only the URL, no additional text.
        Example format: "https://www.example.com/product"
        """
        
        let requestBody: [String: Any] = [
            "model": "mixtral-8x7b-instruct",
            "messages": [
                ["role": "system", "content": "You are a helpful shopping assistant that provides product links."],
                ["role": "user", "content": prompt]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.parsingError))
            return
        }
        
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
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // Clean and validate the URL
                    let cleanedURL = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    if cleanedURL.lowercased().hasPrefix("http") {
                        completion(.success(cleanedURL))
                    } else {
                        completion(.failure(.noWeblinkFound))
                    }
                } else {
                    completion(.failure(.parsingError))
                }
            } catch {
                completion(.failure(.parsingError))
            }
        }.resume()
    }
    
    // Function to get product recommendations
    func getRecommendations(for productName: String, completion: @escaping (Result<[String], PerplexityError>) -> Void) {
        let baseURL = "https://api.perplexity.ai/chat/completions"
        
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
        let prompt = """
        Based on the product '\(productName)', suggest 3 related items that are commonly bought together. 
        Format the response as a comma-separated list. Only include the item names, no additional text.
        Example format: "item1, item2, item3"
        """
        
        let requestBody: [String: Any] = [
            "model": "mixtral-8x7b-instruct",
            "messages": [
                ["role": "system", "content": "You are a helpful shopping assistant that provides product recommendations."],
                ["role": "user", "content": prompt]
            ]
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
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // Split the comma-separated response into an array
                    let recommendations = content
                        .split(separator: ",")
                        .map { String($0).trimmingCharacters(in: .whitespaces) }
                    
                    completion(.success(recommendations))
                } else {
                    completion(.failure(.parsingError))
                }
            } catch {
                completion(.failure(.parsingError))
            }
        }.resume()
    }
    
    // Function to get price information
    func getPriceInfo(for productName: String, completion: @escaping (Result<[String: Double], PerplexityError>) -> Void) {
        let baseURL = "https://api.perplexity.ai/chat/completions"
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let prompt = """
        What are the current prices for '\(productName)' at major retailers? 
        Format the response as a JSON object with store names as keys and prices as values.
        Example format: {"Walmart": 9.99, "Target": 10.99}
        Only include the JSON, no additional text.
        """
        
        let requestBody: [String: Any] = [
            "model": "mixtral-8x7b-instruct",
            "messages": [
                ["role": "system", "content": "You are a helpful shopping assistant that provides current price information."],
                ["role": "user", "content": prompt]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.parsingError))
            return
        }
        
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
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String,
                   let priceData = content.data(using: .utf8),
                   let prices = try JSONSerialization.jsonObject(with: priceData) as? [String: Double] {
                    
                    completion(.success(prices))
                } else {
                    completion(.failure(.parsingError))
                }
            } catch {
                completion(.failure(.parsingError))
            }
        }.resume()
    }
} 