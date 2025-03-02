import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    
    // Store constants for price comparison
    enum Store: String, CaseIterable {
        case traderJoes = "Trader Joe's"
        case aldi = "Aldi"
        case giant = "Giant"
        case safeway = "Safeway" 
        case publix = "Publix"
    }
    
    private let openRouterAPIKey = "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"
    
    private init() {}
    
    func queryPerplexityForBarcode(_ barcode: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(openRouterAPIKey)", forHTTPHeaderField: "Authorization")
        
        let prompt = """
        I have scanned a barcode: \(barcode). Please search for information about this product.
        Return the product's:
        - Name
        - Category
        - Normal price range
        - Nutritional information (if available)
        - Any other relevant details
        
        Format the response in a clear, readable way that would be helpful for a grocery shopping app.
        """
        
        let body: [String: Any] = [
            "model": "perplexity/r1-1776",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "APIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    print("Barcode API Response: \(content)")
                    completion(.success(content))
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "Invalid response format"
                    print("Invalid Barcode API response: \(responseString)")
                    completion(.failure(NSError(domain: "APIService", code: 3, userInfo: [NSLocalizedDescriptionKey: responseString])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func processReceiptWithGemini(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "APIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(openRouterAPIKey)", forHTTPHeaderField: "Authorization")
        let prompt = """
You are an expert receipt scanner for a grocery tracking app. I have a photo of my grocery receipt.
Extract ALL grocery items with their prices.

Return the data as a list in this exact JSON format:
[
{
    "name": "Item name",
    "price": price as number,
    "quantity": quantity as number,
    "category": "Best guess category",
    "price_per_unit": price_per_unit as number,
    "date": date as string
}
]

Categories should be one of: Baby Care, Baby Products, Baby Snacks, Baked Goods, Beans, Beverages, Bread, Breakfast, Canned Goods, Cereal, Dairy, Dessert, Fresh Fruit, Fresh Vegetable, Frozen Food, Fruits, Gift, Grains, Household Items, Meat, Pantry, Pasta, Salad, Salad Dressing, Seafood, Shampoo, Snacks, Vegetables, Salt/Pepper, Yogurt, Chicken, Steak, Sauce, Chips, Cheese, Deli Meats, Coffee, Tortilla, Butter, Bars, Diapers, Cleaning products, Soap, Eggs, Pizza, Unknown, Milk, Chocolat, Oil, Gum, Dip, Mayo, Raspberries, Ginger Ale, Keto bar, Biotin, Dark Chocolate, Potassium, Vitamin B, Cinn Gum, Lettuce, Chocolate Bar, Other

Only include actual grocery items, not totals, taxes, or store information.

"price" per unit should be calculated by dividing the price by the quantity. If the quantity is not available, assume the quantity is 1 and the price per unit is equal to the total price. For items sold by weight (such as produce, meat, or bulk items), ensure the unit of measurement (pounds, ounces, grams, etc.) is included in the price per unit calculation. If a package contains multiple items, the price per unit should reflect the cost of each individual item within the package.

To extract the "date" from a grocery or store receipt, carefully scan the document for any text that indicates a date, typically found at the top or bottom of the receipt. Look for formats such as "DD/MM/YYYY", "MM/DD/YYYY", or written out as "January 1, 2023". The date may be preceded by labels like "Date:", "Purchase Date:", or "Transaction Date:". If a clear date cannot be identified, check for any time stamps or transaction numbers that may correlate with a specific date. In the event that no date is present on the receipt, use the most recent transaction date available from the store's records or, as a last resort, assign the current date as a fallback to ensure the receipt is processed with a timestamp.
"""
        
        let body: [String: Any] = [
            "model": "google/gemini-2.0-pro-exp-02-05:free",
            "messages": [
                ["role": "user", "content": [
                    ["type": "text", "text": prompt],
                    ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                ]]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Sending receipt to Google Gemini for processing...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                completion(.failure(NSError(domain: "APIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    print("Receipt API Response: \(content)")
                    
                    // Try to extract JSON from the response
                    if let jsonStart = content.range(of: "["),
                       let jsonEnd = content.range(of: "]", options: .backwards) {
                        let jsonSubstring = content[jsonStart.lowerBound...jsonEnd.upperBound]
                        print("Extracted JSON: \(jsonSubstring)")
                        completion(.success(String(jsonSubstring)))
                    } else {
                        print("Couldn't extract JSON from response, returning full text")
                        completion(.success(content))
                    }
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "Invalid response format"
                    print("Invalid Receipt API response: \(responseString)")
                    completion(.failure(NSError(domain: "APIService", code: 3, userInfo: [NSLocalizedDescriptionKey: responseString])))
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func queryPerplexityForPriceComparison(item: String, store: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(openRouterAPIKey)", forHTTPHeaderField: "Authorization")
        
        let prompt = """
        I want to compare the price of \(item) at \(store).
        Please provide:
        1. Current price at \(store)
        2. Whether it's on sale or regular price
        3. Unit price (per oz, lb, etc.) if available
        4. Brand information
        5. Comparison to prices at other major stores
        6. Any special deals or promotions

        Return the information in a structured format that's easy to parse.
        """
        
        let body: [String: Any] = [
            "model": "perplexity/r1-1776",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "APIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    print("Price comparison API Response: \(content)")
                    completion(.success(content))
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "Invalid response format"
                    print("Invalid Price comparison API response: \(responseString)")
                    completion(.failure(NSError(domain: "APIService", code: 3, userInfo: [NSLocalizedDescriptionKey: responseString])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Convenience method that takes the Store enum
    func queryPerplexityForPriceComparison(item: String, store: Store, completion: @escaping (Result<String, Error>) -> Void) {
        queryPerplexityForPriceComparison(item: item, store: store.rawValue, completion: completion)
    }
} 