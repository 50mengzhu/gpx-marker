//
//  MapView.swift
//  gpx marker
//
//  Created by mica dai on 2024/11/17.
//
import SwiftUI
import MapKit

#if os(iOS)
typealias PlatformMapViewRepresentable = UIViewRepresentable
import UIKit
typealias PlatformColor = UIColor
#elseif os(macOS)
typealias PlatformMapViewRepresentable = NSViewRepresentable
import AppKit
typealias PlatformColor = NSColor
#endif

struct MapView: PlatformMapViewRepresentable {
    var tracks: [Track]
    var waypoints: [Waypoint]
    
#if os(iOS)
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateMapView(uiView)
    }
#elseif os(macOS)
    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateNSView(_ nsView: MKMapView, context: Context) {
        updateMapView(nsView)
    }
#endif
    
    // 统一更新地图的内容
    private func updateMapView(_ mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // 添加轨迹
        for track in tracks {
            let polyline = MKPolyline(coordinates: track.coordinates, count: track.coordinates.count)
            mapView.addOverlay(polyline)
        }
        
        // 添加标记点
        for waypoint in waypoints {
            let annotation = MKPointAnnotation()
            annotation.coordinate = waypoint.coordinate
            annotation.title = waypoint.name
            annotation.subtitle = waypoint.description
            mapView.addAnnotation(annotation)
        }
        
        // 设置地图显示区域
        if let firstCoordinate = tracks.first?.coordinates.first {
            let region = MKCoordinateRegion(center: firstCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator 处理地图回调
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        // 渲然折线
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = .red
                renderer.lineWidth = 3.0
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        
        
        // 自定义标记点的样式
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else {
                return nil // 使用默认用户位置样式
            }
            
            let identifier = "WaypointAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true // 显示气泡
            } else {
                annotationView?.annotation = annotation
            }
            
            // 设置自定义样式
#if os(iOS)
            annotationView?.image = UIImage(systemName: "star.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
#elseif os(macOS)
            if let nsImage = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil) {
                annotationView?.image = nsImage.colored(with: PlatformColor.systemRed).toUIImage()
            }
#endif
            
            return annotationView
        }
        
    }
}
