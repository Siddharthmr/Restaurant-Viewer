import Foundation
import CoreLocation

class YelpService {
    private let baseURL = "https://api.yelp.com/v3/businesses/search"
    
    private let apiKey = "Bearer itoMaM6DJBtqD54BHSZQY9WdWR5xI_CnpZdxa3SG5i7N0M37VK1HklDDF4ifYh8SI-P2kI_mRj5KRSF4_FhTUAkEw322L8L8RY6bF1UB8jFx3TOR0-wW6Tk0KftNXXYx"
    
    func fetchBusinesses(location: CLLocation,
                         query: String = "restaurants",
                         offset: Int = 0,
                         limit: Int = 20) async throws -> [Restaurant] {
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            return []
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "term", value: query),
            URLQueryItem(name: "latitude", value: "\(lat)"),
            URLQueryItem(name: "longitude", value: "\(lon)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = urlComponents.url else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
        }
        
        let decoder = JSONDecoder()
        let yelpResponse = try decoder.decode(YelpSearchResponse.self, from: data)
        
        let restaurants = yelpResponse.businesses.map { business in
            Restaurant(
                id: business.id,
                name: business.name,
                imageUrl: business.image_url ?? "",
                rating: business.rating
            )
        }
        
        return restaurants
    }
}

struct YelpSearchResponse: Codable {
    let businesses: [Business]
}

struct Business: Codable {
    let id: String
    let name: String
    let image_url: String?
    let rating: Double
}
