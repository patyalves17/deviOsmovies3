//
//  TheaterMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 06/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit

class TheaterMapViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    lazy var locationManage = CLLocationManager()
    
    var currentElement: String!
    var theater: Theater!
    var theaters: [Theater] = []

    override func viewDidLoad() {
         mapView.delegate = self
        super.viewDidLoad()
        loadXML()
       // print(theaters.count)
       
    }
    
    func requestUserLocationAuthorization(){
        if CLLocationManager.locationServicesEnabled(){
            locationManage.delegate = self
            locationManage.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManage.allowsBackgroundLocationUpdates = true
            locationManage.pausesLocationUpdatesAutomatically = true
            locationManage.pausesLocationUpdatesAutomatically = true
            
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("usuário liberou a bagaça")
                case .denied:
                    print("usuário negou a bagaça")
                case .notDetermined:
                    print("Ainda não foi solicitado o acesso")
                    locationManage.requestWhenInUseAuthorization()
                case .restricted:
                    print("Não tenho acesso ao GPS")
            
           }
        }
    }
    
    func addTheaters(){
        for theater in theaters{
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            let annotation = TheaterAnnotation(coordinate: coordinate)
            
            annotation.title=theater.name
            annotation.subtitle=theater.address
            
            mapView.addAnnotation(annotation)
        }
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadXML(){
        if let xmlURL = Bundle.main.url(forResource: "theaters", withExtension: "xml"),
            let xmlParser = XMLParser(contentsOf: xmlURL){
            xmlParser.delegate = self
            xmlParser.parse()
        }
    }
    

   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TheaterMapViewController: XMLParserDelegate{
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //print("Conteudo ",elementName)
        currentElement = elementName
        if elementName == "Theater" {
            theater = Theater()
            
        }
    }
    
 
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("Conteudo: ", string)
        
        let content=string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !content.isEmpty {
            switch currentElement {
            case "name":
                theater.name = content
            case "address":
                theater.address = content
            case "latitude":
                theater.latitude = Double(content)!
            case "longitude":
                theater.longitude = Double(content)!
            case "url":
                theater.url = content
            default:
                break
            }
        }
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("Fim: ",elementName)
        if elementName == "Theater"{
            theaters.append(theater)
            
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        addTheaters()
    }
    
}

extension TheaterMapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!
        if annotation is TheaterAnnotation{
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Theater")
            
            if annotationView == nil {
                annotationView=MKAnnotationView(annotation: annotation, reuseIdentifier: "Theater")
                annotationView.image = UIImage(named: "theaterIcon")
                annotationView.canShowCallout = true
            }else{
                annotationView.annotation = annotation
            }
        }
        return annotationView
    }

}

extension TheaterMapViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        default:
            break
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.location!.speed)
        
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 100, 100)
        mapView.setRegion(region, animated: true)
    }
}





