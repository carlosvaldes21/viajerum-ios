//
//  PlaceViewController.swift
//  Viajerum
//
//  Created by Carlos Valdes on 18/03/23.
//

import UIKit
import Cosmos
import CoreLocation
import MapKit


class PlaceViewController: UIViewController {

    var place : Place?
    @IBOutlet weak var placeImageView: UIImageView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    
    @IBOutlet weak var cosmosView: CosmosView!
    
    @IBOutlet weak var addRatingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reviewTableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        nameLabel.text = place?.name
        descriptionLabel.text = place?.description
        ratingLabel.text = "\(place!.rating)"
        
        cosmosView.rating = place!.rating
        cosmosView.settings.updateOnTouch = false
        
        if ( place!.wasReviewed ) {
            addRatingButton.setTitle("Escribir nueva reseña", for: .normal)
        }
        
        
        self.heightConstant.constant = CGFloat((place?.reviews?.count ?? 1) * 200)
        
        if let imageUrl = URL(string: place!.img) {
            // Implementando descarga en segundo plano con URLSession
            // 1. Establecemos la configuración para la sesión o usamos la básica
            let urlSessionConfig: URLSessionConfiguration = URLSessionConfiguration.ephemeral
            
            // 2. Se crea la sesión de descarga con la configuración definida
            let urlSession: URLSession = URLSession(configuration: urlSessionConfig)
            
            // 3. Se genera la petición para especificar qué queremos obtener
            let urlRequest: URLRequest = URLRequest(url: imageUrl)
            
            // 4. Creamos la tarea de descarga
            let task: URLSessionDataTask = urlSession.dataTask(with: urlRequest) { data, response, error in
                // Qué haremos cuando obtengamos una repuesta
                if error == nil {
                    guard let imageData: Data = data else { return }
                    DispatchQueue.main.async {
                        self.placeImageView.image = UIImage(data: imageData)
                    }
                }
            }
            // 5. Iniciamos tarea
            task.resume()
        }
    }
    
    @IBAction func onTapInstructions(_ sender: Any) {

        let latitude: CLLocationDegrees = Double(place!.latitude)!
        let longitude: CLLocationDegrees = Double(place!.longitude)!
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place!.name
        mapItem.openInMaps(launchOptions: options)
            
    }
    
    
    @IBAction func addReview(_ sender: Any) {
        performSegue(withIdentifier: "addReview", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addReview" {
            let destination = segue.destination as! AddReviewViewController
            destination.place =  place
        }
    }
    

}

extension PlaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        place?.reviews?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reviewTableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
            
        cell.nameLabel.text = "\(place!.reviews![indexPath.row].name)"
        cell.commentLabel.text = place!.reviews![indexPath.row].comment
        var ratingFormatted = Double(round(10 * place!.reviews![indexPath.row].rating) / 10)
        cell.ratingLabel.text = "\(ratingFormatted)"
        return cell
    }
    
    
    
}
