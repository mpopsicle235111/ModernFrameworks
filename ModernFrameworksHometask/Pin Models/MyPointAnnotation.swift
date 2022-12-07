//
//  MyPointAnnotation.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 31.10.2022.
//

import MapKit

//A class to show nice custom pins in MapKit
//Source: https://stackoverflow.com/questions/55273097/mapkit-get-current-coordinates-of-placemarker

class MyPointAnnotation: MKPointAnnotation {
    var identifier: String?
    //var image: UIImage?
    var lat: Double!
    var lon: Double!
}
