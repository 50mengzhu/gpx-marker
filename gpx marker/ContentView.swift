//
//  ContentView.swift
//  gpx marker
//
//  Created by mica dai on 2024/11/17.
//

import SwiftUI
import MapKit


struct ContentView: View {
    @State private var tracks: [Track] = []
    @State private var waypoints: [Waypoint] = []

    var body: some View {
        MapView(tracks: tracks, waypoints: waypoints)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        if let fileURL = Bundle.main.url(forResource: "example", withExtension: "gpx") {
                            let parser = GPXParser()
                            parser.parseGPX(fileURL: fileURL)
                            tracks = parser.tracks
                            waypoints = parser.waypoints
                        }
                    }
    }
}

#Preview {
    ContentView()
}


