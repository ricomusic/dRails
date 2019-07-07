//  - File.swift Created 2019-07-03

import Foundation
import Persistancy

public class Trafikverket {
    let APIKey = "0ff4569d55f64a4db0a16996385a6d8e"
    let baseURL = "https://api.trafikinfo.trafikverket.se/v2/data.json"

    public init() {}

    func requestWith(_ body: String) -> URLRequest {
        guard let url = URL(string: baseURL) else { fatalError() }

        var request = URLRequest(url: url)
        request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        return request
    }

    func trainStationsBody() -> String {
        return #"""
        <REQUEST>
        <LOGIN authenticationkey="\#(APIKey)" />
        <QUERY objecttype="TrainStation" schemaversion="1">
        <FILTER />
        </QUERY>
        </REQUEST>
        """#
    }
    func trainAnnouncementBody(from origin: String, to destination: String?, limit: Int = 10) -> String {
        var body = #"""
        <REQUEST>
        <LOGIN authenticationkey="\#(APIKey)" />
        <QUERY objecttype="TrainAnnouncement" schemaversion="1.3"
        orderby="AdvertisedTimeAtLocation" limit="\#(limit)">
        <FILTER><AND>
        <EQ name="ActivityType" value="Avgang" />
        <EQ name="LocationSignature" value="\#(origin)" />
        <OR><AND>
        <GT name="AdvertisedTimeAtLocation" value="$dateadd(00:00:00)" />
        <LT name="AdvertisedTimeAtLocation" value="$dateadd(14:00:00)" />
        </AND>
        <AND>
        <LT name="AdvertisedTimeAtLocation" value="$dateadd(00:30:00)" />
        <GT name="EstimatedTimeAtLocation" value="$dateadd(00:00:00)" />
        </AND>
        </OR>
        """#
        if let toStation = destination {
            body += #"""
            <OR>
            <EQ name="ToLocation.LocationName" value="\#(toStation)" />
            <In name="ViaToLocation.LocationName" value="\#(toStation)" />
            </OR>
            """#
        }
        body += #"""
        </AND>
        </FILTER>
        <INCLUDE>AdvertisedTrainIdent</INCLUDE>
        <INCLUDE>AdvertisedTimeAtLocation</INCLUDE>
        <INCLUDE>TrackAtLocation</INCLUDE>
        <INCLUDE>ToLocation</INCLUDE>
        <INCLUDE>ViaToLocation</INCLUDE>
        <INCLUDE>EstimatedTimeAtLocation</INCLUDE>
        </QUERY>
        </REQUEST>
        """#
        return body
    }

    func getTrainStations(completion: @escaping (Result<[TrainStation], APIError>) -> Void) {
        let body = trainStationsBody()
        let request = requestWith(body)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return completion(.failure(APIError.error)) }
            let decoder = JSONDecoder()
            do {
                let dRails = try decoder.decode(DrailsData.self, from: data)
                guard let stations = dRails.response?.result?.first?.trainStation
                    else { return completion(.failure(APIError.error)) }
                completion(.success(stations))
            } catch {
                completion(.failure(APIError.error))
            }
        }.resume()
    }

    public func getTrainAnnouncements(fromStation: String,
                                      toStation: String? = nil,
                                      limit: Int = 10,
                                      completion: @escaping (Result<[APIResult], APIError>) -> Void) {
        let body = trainAnnouncementBody(from: fromStation, to: toStation, limit: limit)

        let request = requestWith(body)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return completion(.failure(APIError.error)) }

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom({ decoder -> Date in
                do {
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    if let date = isoFormatter.date(from: dateString) {
                        return date
                    } else {
                        fatalError("oh no")
                    }
                } catch {
                    fatalError("oh no")
                }
            })
            do {
                let dRails = try decoder.decode(DrailsData.self, from: data)
                guard let apiResult = dRails.response?.result
                    else { return completion(.failure(APIError.error)) }
                completion(.success(apiResult))
            } catch {
                completion(.failure(APIError.error))
            }
        }.resume()
    }
    func setupStations(forceUpdate: Bool = false, completion: @escaping (Bool) -> Void) {
        guard let persistancy = try? Persistancy<[String: TrainStation]>(name: "dRails")
            else { fatalError() }
        if case .success = persistancy.load("stations"),
            !forceUpdate {
            completion(true)
        } else {
            getTrainStations { result in
                switch result {
                case .failure(let error):
                    completion(false)
                    fatalError(error.localizedDescription)
                case .success(let fetchedStations):
                    var stations = [String: TrainStation]()
                    fetchedStations.forEach { station in
                        guard let signature = station.locationSignature else { return }
                        stations[signature] = station
                    }
                    try? persistancy.save(stations, in: "stations")
                    completion(true)
                }
            }
        }
    }
}
