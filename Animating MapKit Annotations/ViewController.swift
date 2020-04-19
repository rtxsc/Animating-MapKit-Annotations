//
//  ViewController.swift
//  Animating MapKit Annotations
//
//  Created by Yazid on 20/04/2020.
//  Copyright © 2020 UiTM. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    
    private let marker1 = MKPointAnnotation()
    private let marker2 = MKPointAnnotation()
    
    var lat = 1.583301
    var lon = 110.388393
 
    var tick: Double! = 0.0
    var shift: Double! = 0.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // setting ViewController as the delegate of the map view
        mapView.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        // Set initial location
        let initialLocation = CLLocation(latitude: lat, longitude: lon)
        mapView.centerToLocation(initialLocation)
        
        let roi = CLLocation(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(
          center: roi.coordinate,
          latitudinalMeters: 50000,
          longitudinalMeters: 60000)
        mapView.setCameraBoundary(
          MKMapView.CameraBoundary(coordinateRegion: region),
          animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
        var newPosition1 = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        var newPosition2 = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        // Add annotation to map.
        marker1.title = "sc1"
        marker1.coordinate = initialLocation.coordinate
        marker2.title = "sc2"
        marker2.coordinate = initialLocation.coordinate
      
       mapView.addAnnotation(marker1)
       mapView.addAnnotation(marker2)
        
          // Show artwork on map
          let label = PopUpLabel(
            title: "HQ Location",
            locationName: "eScooter HQ",
            discipline: "Building",
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        mapView.addAnnotation(label)
        
        var labelmarker1 = PopUpLabel(
                           title: "sc1",
                           locationName: "\(self.marker1.coordinate.latitude), \(self.marker1.coordinate.longitude)",
                           discipline: "Vehicle",
                           coordinate: initialLocation.coordinate)
        
       var labelmarker2 = PopUpLabel(
                       title: "sc2",
                       locationName: "\(self.marker2.coordinate.latitude), \(self.marker2.coordinate.longitude)",
                       discipline: "Vehicle",
                       coordinate: initialLocation.coordinate)
        
        self.mapView.addAnnotation(labelmarker1)
        self.mapView.addAnnotation(labelmarker2)
          
        // Set timer of 5 seconds before beginning the animation.
       weak var timer: Timer?
       
       //in a function or viewDidLoad() --- start global timer for func timerAction
       timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
       func updatePosition() {
           // Set timer to run after 5 seconds.
           timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
               // Set animation to last 5 seconds.
               UIView.animate(withDuration: 5, animations: {
                
                // update new coordinates every 5 seconds
                   newPosition1 = CLLocationCoordinate2D(latitude: self!.lat, longitude: self!.lon + self!.shift)
                   newPosition2 = CLLocationCoordinate2D(latitude: self!.lat, longitude: self!.lon - self!.shift)
                labelmarker1.coordinate = newPosition1
                labelmarker2.coordinate = newPosition2
                   print(newPosition1)
                   print(newPosition2)


                   // Update annotation coordinate to be the destination coordinate
                    self?.marker1.title = "sc1"
                    self?.marker1.subtitle = "\(self!.marker1.coordinate.latitude), \(self!.marker1.coordinate.longitude)"
                    self?.marker2.title = "sc2"
                    self?.marker2.subtitle = "\(self!.marker2.coordinate.latitude), \(self!.marker2.coordinate.longitude)"
                    self?.marker1.coordinate = newPosition1
                    self?.marker2.coordinate = newPosition2
                
              

               }, completion: nil)
           }
       }
       // Start moving annotations every 5 seconds
       updatePosition()
    
    } // end of ViewDidLoad
    
    // timer function to calculate longitude shift value
   @objc func timerAction(){
       tick += 1
       shift = tick / 10000
       print("second: \(tick!) & lon shifted by: \(shift!)")
    
       }
    
} // end of UIViewController

extension ViewController: MKMapViewDelegate {
  // 1
  func mapView(
    _ mapView: MKMapView,
    viewFor annotation: MKAnnotation
  ) -> MKAnnotationView? {
    // 2
    guard let annotation = annotation as? PopUpLabel else {
      return nil
    }
    // 3
    let identifier = "popuplabel"
    var view: MKMarkerAnnotationView
    // 4
    if let dequeuedView = mapView.dequeueReusableAnnotationView(
      withIdentifier: identifier) as? MKMarkerAnnotationView {
      dequeuedView.annotation = annotation
      view = dequeuedView
    } else {
      // 5
      view = MKMarkerAnnotationView(
        annotation: annotation,
        reuseIdentifier: identifier)
      view.canShowCallout = true
      view.calloutOffset = CGPoint(x: -5, y: 5)
      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    return view
  }
}

private extension MKMapView {

  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
