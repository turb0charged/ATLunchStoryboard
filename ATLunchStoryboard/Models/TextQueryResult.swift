//    // This file was generated from JSON Schema using quicktype, do not modify it directly.
//    // To parse the JSON, add this file to your project and do:
//    //
//    //   let textQueryResult = try? newJSONDecoder().decode(TextQueryResult.self, from: jsonData)
//
//import Foundation
//
//    // MARK: - TextQueryResult
//struct TextQueryResult: Codable {
//    let htmlAttributions: [JSONAny]
//    let nextPageToken: String
//    let results: [Result]
//    let status: String
//
//    enum CodingKeys: String, CodingKey {
//        case htmlAttributions = "html_attributions"
//        case nextPageToken = "next_page_token"
//        case results, status
//    }
//}
//
//    // MARK: - Result
//struct Result: Codable {
//    let businessStatus: String
//    let formattedAddress: String
//    let geometry: Geometry
//    let icon: String
//    let iconBackgroundColor: String
//    let iconMaskBaseURI: String
//    let name: String
//    let openingHours: OpeningHours
//    let photos: [Photo]
//    let placeID: String
//    let plusCode: PlusCode
//    let priceLevel: Int?
//    let rating: Double
//    let reference: String
//    let types: [String]
//    let userRatingsTotal: Int
//
//    enum CodingKeys: String, CodingKey {
//        case businessStatus = "business_status"
//        case formattedAddress = "formatted_address"
//        case geometry, icon
//        case iconBackgroundColor = "icon_background_color"
//        case iconMaskBaseURI = "icon_mask_base_uri"
//        case name
//        case openingHours = "opening_hours"
//        case photos
//        case placeID = "place_id"
//        case plusCode = "plus_code"
//        case priceLevel = "price_level"
//        case rating, reference, types
//        case userRatingsTotal = "user_ratings_total"
//    }
//}
//
//
//
//
