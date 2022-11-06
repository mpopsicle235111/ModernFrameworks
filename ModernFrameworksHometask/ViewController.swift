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
    let appleGarageCoordinates = CLLocationCoordinate2D(latitude: 37.34033264974476, longitude: -122.06892632102273)
    var userDeviceLocation: CLLocation?
    var marker: MKPointAnnotation?
    //CLGeocoder is a very heavy class
    //It takes coordinates and outputs street names etc.
    var globalGeocoder: CLGeocoder?
    //To draw a route line
    var routeData : MKRoute?
    var trackedRouteCoordinates: [CLLocation] = []
    var trackedRouteLine: MKPolylineRenderer?
    var routeOverlay : MKOverlay?
    var trackingOn : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is necessary to DRAW a route line between the two points, not just CALCULATE it
        mapView.delegate = self
        //Start updating the user location (blue dot)
        locationManager.startUpdatingLocation()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLocation()
    }
    
    func setupLocation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //Included to optimize the map scope
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
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

    private func addMarker() {
        marker = MKPointAnnotation()
        marker?.coordinate = appleGarageCoordinates
        marker?.title = "Apple Garage"
        marker?.subtitle = "Where Apple Was Born"
        mapView.addAnnotation(marker!)
    }
    
    private func removeMarker() {
        mapView.removeAnnotation(marker!)
        marker = nil //We also have to delete the marker object itself
    }
    
    private func drawRoute(routeData: [CLLocation]) {
        
        if routeData.count == 0 {
                    print("No coordinates to draw a line")
                    return
                }
                let trackedCoordinates = trackedRouteCoordinates.map { location -> CLLocationCoordinate2D in
                    return location.coordinate
                }
                
                DispatchQueue.main.async {
                    self.routeOverlay = MKPolyline(coordinates: trackedCoordinates, count: trackedCoordinates.count)
                    self.mapView.addOverlay(self.routeOverlay!, level: .aboveRoads)
                    let customEdgePadding : UIEdgeInsets = UIEdgeInsets (
                        top: 10,
                        left: 10,
                        bottom: 10,
                        right: 10
                    )
                    self.mapView.setVisibleMapRect(self.routeOverlay!.boundingMapRect, edgePadding: customEdgePadding, animated: true)
                }
    }
    
   
    @IBAction func addMarkerDidTap(_ sender: Any) {
        //Was before:
        //addMarker()
        //Now we check, if the marker exists already.
        //If there is no marker - we add a new marker
        //If it already exists - we delete it
        if marker == nil {
            mapView.setCenter(appleGarageCoordinates, animated: true)//Center map on the new marker
            addMarker()
        } else {
           removeMarker()
        }
    }
    
    
    @IBAction func startTrackingDidTap(_ sender: UIButton) {
        if trackingOn == false {
            trackingOn = true
            print("Started tracking")
            mapView.setCenter(userDeviceLocation?.coordinate ?? appleGarageCoordinates, animated: true)
            //locationManager.requestLocation()
            //guard let location = locations.first else { return }
            //self.userDeviceLocation = location
            //trackedRouteCoordinates.append(location)
            drawRoute(routeData: trackedRouteCoordinates)
        } else {
           trackingOn = false
           print("Finished tracking")
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
        self.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        self.mapView.addAnnotation(pin)
    }
    
}

//Here we check, if tracking is allowed by the user
//This method is performed each time the location changes
extension ViewController: CLLocationManagerDelegate {
    
    //Focus the map on our location
    //Otherwise we just see the whole global map and have to search
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //This is how we show user location (blue dot) on mapView
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locations[0].coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        mapView.delegate = self
        
        guard let location = locations.first else { return }
        self.userDeviceLocation = location
        
        //setPin(location: location)
        
        print("Map updated") //By default the map updates every second
        //This is not necessary here, so we
        //locationManager.stopUpdatingLocation()
        print(location.coordinate)
        trackedRouteCoordinates.append(location)
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
        //Set line color and width
        render.lineWidth = 5
        render.strokeColor = .systemBlue
        render.strokeColor = .red
        return render
    }
    
    
    //Three funcs below show nice custom pins, using the MyPointAnnotation Class.
    //Source: https://stackoverflow.com/questions/55273097/mapkit-get-current-coordinates-of-placemarker
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else {
                return nil
            }

            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView?.pinTintColor = UIColor.red
                pinView?.canShowCallout = true
            }
            else {
                pinView?.annotation = annotation
            }
            return pinView
        }

//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//            if view.annotation is MyPointAnnotation {
//                if let selectedAnnotation = view.annotation as? MyPointAnnotation {
//                    if let id = selectedAnnotation.identifier {
//                        for pin in mapView.annotations as! [MyPointAnnotation] {
//                            if let myIdentifier = pin.identifier {
//                                if myIdentifier == id {
//                                    print(pin.lat ?? 0.0)
//                                    print(pin.lon ?? 0.0)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }

//        func addNewAnnotationPin(title: String, subTitle: String, lat: Double, lon: Double) {
//            let myPin = MyPointAnnotation()
//            myPin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//            myPin.title = title
//            myPin.subtitle = subTitle
//            myPin.identifier = UUID().uuidString
//            myPin.lat = lat
//            myPin.lon = lon
//            self.mapView.addAnnotation(myPin)
//        }
    
    //Looks like this is a standard MapKit func to get tap coordinates on map
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {
            let touchPoint = touch.location(in: mapView)
            let location = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            print ("\(location.latitude), \(location.longitude)")
            
            //Place markers in the touched places
            //We can save them in some array or CoreDdata
            let manualMarker = MKPointAnnotation(__coordinate: location)
            //Add to center map on each new marker
            //mapView.setCenter(location, animated: true)
            mapView.addAnnotation(manualMarker)
            
            //These lines add street names, ets. to the coordinates
            //Was before:
            //globalGeocoder = CLGeocoder()
            //Because the class CLGeoCoder is extremely heavy,
            //it's best to inset check:
            if globalGeocoder == nil {
                globalGeocoder = CLGeocoder()
            }
            
            globalGeocoder?.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude),
                completionHandler: { places, error in
                print(places?.last)
                
            })
        }
    
    }
}

