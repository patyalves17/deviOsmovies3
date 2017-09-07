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
    
    @IBOutlet weak var mapView: MKMapView!
    var currentElement: String!
    var theater: Theater!
    var theaters: [Theater] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadXML()
        print(theaters.count)
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
