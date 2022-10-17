//
//  ViewController.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 17.10.2022.
//
// Line added to create a pull request

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var locationCoordinates: UITextField!

    let locationManager = CLLocationManager()
    var userDeviceLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is necessary to DRAW a route line between the two points, not just CALCULATE it
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLocation()
    }
    
    func setupLocation(){
        locationManager.delegate = self
        checkAuth()
    }
    
    //Checks, if user authorizes us to track him/her
    func checkAuth(){
        switch locationManager.authorizationStatus{
            
        case .notDetermined:  //default
            //This popup is defined in Info.plist
            //Privacy - Location When In Use Usage Description
            //Input text on the right side: "Please kindly allow to track your location..."
            locationManager.requestWhenInUseAuthorization()
        case .restricted: //works with parent control
            print("Location Access Restricted By Parent(s)")
            break
        case .denied:
            print("Location Access Restricted")
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default: //reserved for unknown errors
            print("Unknown Error")
        }
    }

    //We type in a location and the new pin is set for it
    //There can be as many pins as we want
    
    @IBAction func searchButton(_ sender: Any) {
        if locationCoordinates.text?.count != 0{
            searchInMap(locationCoordinates: locationCoordinates.text!) { endPointLocation in
                self.setPin(location: endPointLocation)
                
                //print(endPointLocation)
                
                //let geoCoder = CLGeocoder()
                //geoCoder.reverseGeocodeLocation(endPointLocation, completionHandler: { places, error in
                    //print(places?.last)
                    
                    
                //})
                
                //This func receives userDeviceLocation and endPoint
                //And builds a route between them
                self.setRoute(start: self.userDeviceLocation!.coordinate, end: endPointLocation.coordinate)
                
                
            }
        }
    }
    
    //We just need the coords, so we just use 2D coordinates (smaller data array)
    func setRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        
        let startPoint = MKPlacemark(coordinate: start)
        let destinationPoint = MKPlacemark(coordinate: end)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPoint)
        request.destination = MKMapItem(placemark: destinationPoint)
        request.transportType = .automobile
        //Ask for alt routes. It returns an array, we take $0 element,
        //normally it is the shortest one, but we can also select them via check cycle to be sure
        request.requestsAlternateRoutes = true
        
        //This is similar to URL Session request: we combine everything
        //and then send a request
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            //Check for possible errors
            if let error = error {
                print(error.localizedDescription)
                return
            }
            //Check if the route is possible: maybe we want
            //to go by car from Moscow to NYC, which is impossible
            guard let response = response else {
                print("No route available...")
                return
            }
            //We select the first from the alternate routes
            //because earlier we stated that we want alt routes
            let minRoute = response.routes[0]
            //Otherwise we can use for... in.. cycle and check
            //minRoute.distance  for mnimal distance
            
            //And finally we add route line to the mapView
            self.mapView.addOverlay(minRoute.polyline)
            
            
        }
    }
    
    func searchInMap(locationCoordinates: String, completion: @escaping (CLLocation) -> ()) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationCoordinates) { placemarks, error in
            //If something is wrong, we display error message
            if let error = error {
                print(error.localizedDescription)
                return
            }
            //If there is no error, we check for geotags
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first?.location
            completion(placemark!)  //MARK: Replace force unwrap with if...let here
            
        }
    }
    /// Accepts the point location for our two points (userDeviceLocation and destinationLocation)
    func setPin(location: CLLocation){
        //Let's add a pin onto a map
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        
        //Span is a magnification rate
        self.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)), animated: true)
        
        self.mapView.addAnnotation(pin)
    }
    
}

//Here we check, if tracking is allowed by the user
//This method is performed each time the location changes
extension ViewController: CLLocationManagerDelegate {
    
    //Focus the map on our location
    //Otherwise we just see the whole global map and have to search
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.userDeviceLocation = location
        
        setPin(location: location)
        
        print("Map updated") //By default the map updates every second
        //This is not necessary here, so we
        locationManager.stopUpdatingLocation()
    }
    
    /// Works every time we change location - maybe we do not have a permission any more?
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuth()
    }
}

extension ViewController: MKMapViewDelegate {
    //This method is used to draw something on the map
    //In our case we're going to draw a route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        //Set line color
        render.strokeColor = .red
        return render
    }
}

