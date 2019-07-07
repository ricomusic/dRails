import Foundation

// MARK: - Drails
struct DrailsData: Codable {
    let response: APIResponse?

    enum CodingKeys: String, CodingKey {
        case response = "RESPONSE"
    }
}

// MARK: - Response
struct APIResponse: Codable {
    let result: [APIResult]?

    enum CodingKeys: String, CodingKey {
        case result = "RESULT"
    }
}

// MARK: - TrainStation
struct TrainStation: Codable {
    let advertised: Bool?
    let advertisedLocationName, advertisedShortLocationName, countryCode: String?
    let countyNo: [Int]?
    let geometry: Geometry?
    let locationSignature, modifiedTime: String?
    let locationInformationText: String?
    let platformLine: [String]?
    let prognosticated: Bool?

    enum CodingKeys: String, CodingKey {
        case advertised = "Advertised"
        case advertisedLocationName = "AdvertisedLocationName"
        case advertisedShortLocationName = "AdvertisedShortLocationName"
        case countryCode = "CountryCode"
        case countyNo = "CountyNo"
        case geometry = "Geometry"
        case locationSignature = "LocationSignature"
        case locationInformationText = "LocationInformationText"
        case modifiedTime = "ModifiedTime"
        case platformLine = "PlatformLine"
        case prognosticated = "Prognosticated"
    }
}

// MARK: - Geometry
struct Geometry: Codable {
    let sweref99Tm, wgs84: String?

    enum CodingKeys: String, CodingKey {
        case sweref99Tm = "SWEREF99TM"
        case wgs84 = "WGS84"
    }
}

// MARK: - Result
public struct APIResult: Codable {
    let trainStation: [TrainStation]?
    let trainAnnouncement: [TrainAnnouncement]?

    enum CodingKeys: String, CodingKey {
        case trainAnnouncement = "TrainAnnouncement"
        case trainStation = "TrainStation"
    }
}

// MARK: - TrainAnnouncement
struct TrainAnnouncement: Codable {
    let advertisedTimeAtLocation: Date?
    let advertisedTrainIdent: String?
    let toLocation: [ToLocation]?
    let viaToLocation: [ToLocation]?
    let trackAtLocation: String?
    let estimatedTimeAtLocation: Date?

    enum CodingKeys: String, CodingKey {
        case advertisedTimeAtLocation = "AdvertisedTimeAtLocation"
        case advertisedTrainIdent = "AdvertisedTrainIdent"
        case toLocation = "ToLocation"
        case viaToLocation = "ViaToLocation"
        case trackAtLocation = "TrackAtLocation"
        case estimatedTimeAtLocation = "EstimatedTimeAtLocation"
    }
}

// MARK: - ToLocation
struct ToLocation: Codable {
    let locationName: String?
    let priority, order: Int?

    enum CodingKeys: String, CodingKey {
        case locationName = "LocationName"
        case priority = "Priority"
        case order = "Order"
    }
}
