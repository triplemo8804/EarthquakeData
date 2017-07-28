//
//  EarthquakeMapViewController.swift
//  AsynchronousEarthquake
//
//  Created by Moses Monroe on 7/28/17.
//  Copyright © 2017 Moses Monroe. All rights reserved.
//

import UIKit
import MapKit

struct Earthquake {
    let magnitude: Float
    let location: String
    let date: Date
    let coordinates: CLLocationCoordinate2D
}

class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}


class EarthquakeMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    var earthquakes = [Earthquake]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.layoutIfNeeded()
        mapView.delegate = self
        let fakeAnnotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(47.5650), longitude: CLLocationDegrees(122.6270)), title: "asdf", subtitle: "asdfasf'")
        mapView.addAnnotation(fakeAnnotation)
        
        fetchEarthquakes()
    }
    
    
    // MARK: -
    func fetchEarthquakes() {
        // Logic
        let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson")!
        let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            var annotations = [Annotation]()
            
            if let url = url {
                //        print(url)
                
                do {
                    let data = try Data(contentsOf: url)
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    
                    //            print(json)
                    
                    let allEarthquakes = json["features"] as! [[String: Any]]
                    
                    for earthquake in allEarthquakes {
                        
                        let properties = earthquake["properties"] as! [String: Any]
                        let epochTime = properties["time"] as! TimeInterval
                        let geometry = earthquake["geometry"] as! [String: Any]
                        let geoLocation = geometry["coordinates"] as! [CLLocationDegrees]
                        
                        let magnitude = properties["mag"] as! Float
                        let location = properties["place"] as! String
                        let date = Date(timeIntervalSince1970: epochTime)
                        let coordinates = CLLocationCoordinate2D(latitude: geoLocation.first!, longitude: geoLocation.last!)
                        
                        //                        let earthquake = Earthquake(magnitude: magnitude, location: location, date: date, coordinates: coordinates)
                        
                        print(location,"with a magnitude of",magnitude)
                        let annotation = Annotation(coordinate: coordinates, title: "test", subtitle: "asdf")
                        annotations.append(annotation)
                        
                    }
                    
//                    DispatchQueue.main.async {
//                        self.mapView.addAnnotations(annotations)
//                    }
                    
                } catch {
                    print(error)
                }
                
                
            }
        }
        task.resume()
    }
    
    
    // MARK: -
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "test")
        view?.backgroundColor = .red
        print("weee")
        return view
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("asdfasdf")
    }
    
}
