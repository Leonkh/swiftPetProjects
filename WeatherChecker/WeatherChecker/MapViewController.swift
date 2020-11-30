//
//  MapViewController.swift
//  WeatherChecker
//
//  Created by Леонид Хабибуллин on 21.11.2020.
//
//import CoreLocation
import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    var name: String?
    var latt: Double?
    var long: Double?
    var initialLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialLocation = CLLocationCoordinate2D(latitude: long!, longitude: latt!)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: initialLocation!, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = initialLocation!
        annotation.title = name
        mapView.addAnnotation(annotation)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(changeMapType))
    }
    
    @objc func changeMapType() {
        let ac = UIAlertController(title: "Выберите тип отображения карты", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Гибрид", style: .default, handler: {
            [weak self] _ in
            self?.mapView.mapType = .hybrid
        }))
        ac.addAction(UIAlertAction(title: "Спутник", style: .default, handler: {
            [weak self] _ in
            self?.mapView.mapType = .satellite
        }))
        ac.addAction(UIAlertAction(title: "Станарт", style: .default, handler: {
            [weak self] _ in
            self?.mapView.mapType = .standard
        }))
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(ac, animated: true)
    }
}

