// dRails - DRails.swift Created 2019-07-07

import Foundation
import Persistancy

struct DRails {
    let group = DispatchGroup()
    lazy var stations: [String: TrainStation] = {
        return getStations()
    }()
    let trafikverket = Trafikverket()

    func getStations(retry: Int = 3) -> [String: TrainStation] {
        guard let persistancy = try? Persistancy<[String: TrainStation]>(name: "dRails")
            else { exit(1) }

        guard case .success(let stations) = persistancy.load("stations")
            else {
                group.enter()
                trafikverket.setupStations { _ in
                    self.group.leave()
                }
                group.wait()
                guard retry > 0 else { exit(2) }
                return getStations(retry: retry - 1)
        }
        return stations
    }

    func showTrains(from origin: String, to destination: String?, showVia: Bool, retry: Int = 3) {
        let stations = getStations()
        group.enter()
        trafikverket.getTrainAnnouncements(fromStation: origin,
                                           toStation: destination) { result in
                                            switch result {
                                            case .failure(let error):
                                                print("Oh no: \(error.localizedDescription)")
                                            case .success(let apiResult):
                                                let formatter = DateFormatter()
                                                apiResult
                                                    .flatMap { $0.pretty(stations,
                                                                         showVia: showVia,
                                                                         formatter: formatter) }
                                                    .forEach { print($0) }
                                            }
                                            self.group.leave()
        }
        group.wait()
    }
}
