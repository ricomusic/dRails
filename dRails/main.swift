// dRails - main.swift Created 2019-07-06

import Foundation
import SPMUtility
import TrafikverketAPI

do {
    let parser = ArgumentParser(usage: "<origin> <destination> [options]",
                                overview: "dRails lists coming departures in swedish railway")
    let originArgument = parser.add(positional: "origin",
                                    kind: String.self,
                                    usage: """
Station for whom the timetable is requested. \
        Use station signature (e.g. Cst for Stockholm C)
""")
    let destinationArgument = parser.add(positional: "destination",
                                         kind: String.self,
                                         optional: true,
                                         usage: "Lists only departures to this destination",
                                         completion: nil)

    let stationsArgument = parser.add(option: "--stations",
                                      shortName: "-s",
                                      kind: Bool.self,
                                      usage: """
Lists the station containing the search string. \
Leave empty to list all stations. (e.g. dRails -s Stockholm)
""",
                                      completion: nil)

    let stationDetailArgument = parser.add(option: "--info",
                                           shortName: "-i",
                                           kind: Bool.self,
                                           usage: "Get detailed information about a station (e.g. dRails -i Cst)",
                                           completion: nil)
    let viaArgument = parser.add(option: "--via",
                                 shortName: "-v",
                                 kind: Bool.self,
                                 usage: "Show intermediate stations",
                                 completion: nil)

    let arguments = Array(CommandLine.arguments.dropFirst())
    let result = try parser.parse(arguments)
    let dRails = DRails()
    if result.get(stationsArgument) == true {
        dRails
            .getStations()
            .filter {
                guard let origin = result.get(originArgument) else { return true }
                return $0.value.advertisedLocationName?.lowercased().contains(origin.lowercased()) == true
        }
        .sorted { $0.key < $1.key }
            .forEach { station in
                print(station.value.prettyShort)
        }
    } else if result.get(stationDetailArgument) == true {
        guard let origin = result.get(originArgument) else { exit(3) }
        dRails
            .getStations()
            .filter {
                return $0.value.advertisedLocationName?.lowercased().contains(origin.lowercased()) == true
        }
        .sorted { $0.key < $1.key }
            .forEach { station in
                print(station.value.detailedDescription)
                print("")
        }
    } else {
        guard let origin = result.get(originArgument)
            else { print("Usage bla bla"); exit(1) }
        dRails.showTrains(from: origin,
                          to: result.get(destinationArgument),
                          showVia: result.get(viaArgument) ?? false)
    }
} catch {
    print("ERROR: \(error.localizedDescription)")
    switch error {
    case ArgumentParserError.expectedValue(option: let option):
        print("Option: \(option)")
    case ArgumentParserError.expectedArguments(let parser, let stuff):
        print("Stuff: \(parser) \(stuff)")
    default: break
    }
}

//import Cocoa
//NSWorkspace.shared.open(URL(string: "http://maps.apple.com?q=Cupertino")!)
