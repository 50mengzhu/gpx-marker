//
//  GpxParser.swift
//  gpx marker
//
//  Created by mica dai on 2024/11/17.
//
import Foundation
import CoreLocation

struct Waypoint {
    let coordinate: CLLocationCoordinate2D
    let name: String?
    let description: String?
}

struct Track {
    let coordinates: [CLLocationCoordinate2D]
    let name: String?
}

class GPXParser: NSObject, XMLParserDelegate {
    var waypoints: [Waypoint] = []
    var tracks: [Track] = []

    private var currentElement = ""
    private var currentTrackName: String? = nil
    private var currentTrackCoordinates: [CLLocationCoordinate2D] = []
    private var currentName: String? = nil
    private var currentLat: Double? = nil
    private var currentLon: Double? = nil
    private var currentDescription: String? = nil

    func parseGPX(fileURL: URL) {
        let parser = XMLParser(contentsOf: fileURL)
        parser?.delegate = self
        parser?.parse()
    }

    // XMLParserDelegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName

        if elementName == "wpt" {
            currentName = nil
            if let latString = attributeDict["lat"], let lonString = attributeDict["lon"],
               let latitude = Double(latString), let longitude = Double(lonString) {
                currentLat = latitude
                currentLon = longitude
            }
        } else if elementName == "trk" {
            currentTrackName = nil
            currentTrackCoordinates = []
        } else if elementName == "trkpt" {
            if let latString = attributeDict["lat"], let lonString = attributeDict["lon"],
               let latitude = Double(latString), let longitude = Double(lonString) {
                currentLat = latitude
                currentLon = longitude
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "name" {
            if currentTrackName != nil {
                currentTrackName = (currentTrackName ?? "") + string.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                currentName = (currentName ?? "") + string.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        if currentElement == "description" {
            currentDescription = (currentDescription ?? "") + string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "wpt", let lat = currentLat, let lon = currentLon {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            waypoints.append(Waypoint(coordinate: coordinate, name: currentName, description: currentDescription))
        } else if elementName == "trkpt", let lat = currentLat, let lon = currentLon {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            currentTrackCoordinates.append(coordinate)
        } else if elementName == "trk" {
            let track = Track(coordinates: currentTrackCoordinates, name: currentTrackName)
            tracks.append(track)
        }

        currentElement = ""
    }
}

