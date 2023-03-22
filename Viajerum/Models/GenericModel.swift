// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let genericModel = try? JSONDecoder().decode(GenericModel.self, from: jsonData)

import Foundation

// MARK: - GenericModel
struct GenericModel: Codable {
    let code: Int?
    let message, token: String?
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let user: User?
    let places, nearbyPlaces: [Place]?

    enum CodingKeys: String, CodingKey {
        case user, places
        case nearbyPlaces = "nearby_places"
    }
}

// MARK: - Place
struct Place: Codable {
    let id, userID: Int
    let name, description: String
    let img: String
    let cost, latitude, longitude: String
    let distance: Double?
    let reviews: [Review]?
    let wasReviewed: Bool
    let rating: Double

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name, description, img, cost, latitude, longitude
        case distance, reviews
        case wasReviewed = "was_reviewed"
        case rating
    }
}

// MARK: - Review
struct Review: Codable {
    let id, userID, placeID: Int
    let rating : Double
    let comment: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case placeID = "place_id"
        case rating, comment
        case name
    }
}



// MARK: - User
struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let emailVerifiedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case emailVerifiedAt = "email_verified_at"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
