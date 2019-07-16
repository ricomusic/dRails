// dRails - TrafikverketModel+Pretty.swift Created 2019-07-06

import Foundation
import Persistancy
import TrafikverketAPI

extension TrainAnnouncement {
    func pretty(_ stations: [String: TrainStation],
                showVia: Bool,
                formatter: DateFormatter = DateFormatter()) -> String? {
        formatter.dateFormat = "HH:mm"
        var advertisedTime = advertisedTimeAtLocation.map { formatter.string(from: $0) } ?? ""
        advertisedTime += String(repeating: " ", count: 7 - advertisedTime.count)
        var destination = ""
        guard let destinationSignature = toLocation?.first?.locationName else { return nil }
        destination = stations[destinationSignature]?.advertisedLocationName ?? destinationSignature

        var via: String = showVia ? viaToLocation?
            .compactMap {
                guard let signature = $0.locationName else { return nil }
                return stations[signature]?.advertisedLocationName ?? signature
        }
        .joined(separator: ", ")
            ?? "" : ""
        destination += String(repeating: " ", count: 60 - destination.count)
        var track = trackAtLocation ?? ""
        track = String(repeating: " ", count: 4 - track.count) + track
        var estimated = estimatedTimeAtLocation.map { formatter.string(from: $0) } ?? ""
        estimated += String(repeating: " ", count: 7 - estimated.count)
        var announcementString = "*  \(advertisedTime)  *  \(destination) *  \(track)  *   \(estimated)*"
        if !via.isEmpty {
            via += String(repeating: " ", count: 55 - via.count)
            announcementString +=
            "\n*           *  via: \(via) *        *          *"
        }
        return announcementString
    }
}

extension APIResult {
    func pretty(_ stations: [String: TrainStation],
                showVia: Bool,
                formatter: DateFormatter = DateFormatter()) -> [String] {
        if let trainAnnouncement = trainAnnouncement,
            trainAnnouncement.count > 0 {
            var resultStrings = [String]()
            resultStrings.append(String(repeating: "*", count: 97))
            resultStrings.append("""
*  Tid      *  Destination                                                  \
*  Spår  *   Ny Tid *
""")
            resultStrings.append(String(repeating: "*", count: 97))
            resultStrings.append(contentsOf: trainAnnouncement.compactMap {
                $0.pretty(stations, showVia: showVia, formatter: formatter)
            })
            resultStrings.append(String(repeating: "*", count: 97))
            return resultStrings
        } else {
            return ["Nothing"]
        }
    }
}

extension TrainStation {
    var prettyShort: String {
        guard
            let signature = locationSignature,
            let name = advertisedLocationName
            else { return "?" }
        return "\(signature): \(name)"
    }
    var detailedDescription: String {
        let flag: String = countryCode.map {
            switch $0 {
            case "SE": return "🇸🇪"
            case "DE": return "🇩🇪"
            case "DK": return "🇩🇰"
            case "NO": return "🇳🇴"
            default: return ""
            }
        } ?? ""
        let name = advertisedLocationName ?? "?"
        let coordinates = geometry?.wgs84 ?? "?"
        let information = locationInformationText ?? ""
        let signature = locationSignature ?? "?"
        let platform = platformLine?.joined(separator: ", ") ?? ""
        return """
        Name: \(name) \(flag)
        Signature: \(signature)
        Coordinates: \(coordinates)
        Platforms: \(platform)
        Additional Information: \(information)
        """
    }
}
