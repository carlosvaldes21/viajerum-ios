//
//  HomeViewController.swift
//  Viajerum
//
//  Created by Carlos Valdes on 17/03/23.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {

    var token : String?
    var places : [Place] = []
    var nearbyPlaces : [Place] = []
    var latitude: String?
    var longitude: String?
    var makeRequest = true
    var selectedIndex = 0
    
    var locationManager: CLLocationManager!

    @IBOutlet weak var verticalTableView: UITableView!
    
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    
    
    @IBOutlet weak var horizontalCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        // la precisión determina la frecuencia con que se van a estar obteniendo lecturas, y por lo tanto el gasto de la batería
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
        
        //Hide back button and functionality
        navigationItem.hidesBackButton = true
        
        if let receivedData = KeyChain.load(key: "auth_token") {
            let result = String(decoding: receivedData, as: UTF8.self)
            token = result
        }
        
        horizontalCollectionView.register(UINib(nibName: "HorizontalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "horizontalCell")
        
        verticalTableView.register(UINib(nibName: "VerticalTableViewCell", bundle: nil), forCellReuseIdentifier: "verticalCell")
        
        
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
        
        verticalTableView.delegate = self
        verticalTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        verifyLocation()
    }

    
    @IBAction func logout(_ sender: Any) {
        KeyChain.remove(key: "auth_token")
        performSegue(withIdentifier: "unwindFromHome", sender: self)
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let permiso = manager.authorizationStatus
        if permiso == .authorizedAlways || permiso == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            print("GPS NO autorizado")
            verifyLocation()

            //exit(666)
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first {
            self.latitude = String(location.coordinate.latitude)
            self.longitude = String(location.coordinate.longitude)
            if ( makeRequest ) {
                getPlaces(latitude: self.latitude!, longitude: self.longitude!)
                makeRequest = false
            }
            

        }
        
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("error \(error)")
    }
    
    func verifyLocation()
    {
        DispatchQueue.main.async {
            // Verificamos si la geolocalización está activada en el dispositivo
            if CLLocationManager.locationServicesEnabled() {
                // Verificar permisos para mi aplicación
                if self.locationManager.authorizationStatus == .authorizedAlways ||
                    self.locationManager.authorizationStatus == .authorizedWhenInUse {
                    // si tengo permiso de usar el gps, entonces iniciamos la detección
                    self.locationManager.startUpdatingLocation()
                } else {
                    if self.locationManager.authorizationStatus == .denied {
                        let ac = UIAlertController(title:"Error", message:"Para utilizar esta app, necesitamos utilizar tu ubicación, quieres activarla en configuración?", preferredStyle: .alert)
                        let action = UIAlertAction(title: "SI", style: .default) {
                            action1 in
                            // abrimos los setting del dispositivo para que habilite la localizacion
                            let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                            if UIApplication.shared.canOpenURL(settingsURL) {
                                UIApplication.shared.open(settingsURL, options: [:])
                            }
                        }
                        ac.addAction(action)
                        let action2 = UIAlertAction(title: "NO, CERRAR APP", style: .default) {
                            action2 in
                            // Si necesitamos terminar una app. El código indica el tipo de error
                            exit(666)
                        }
                        ac.addAction(action2)
                        self.present(ac, animated: true)
                    } else {
                        // no tenemos permisos, hay que volver a solicitarlos
                        self.locationManager.requestAlwaysAuthorization()
                    }
                    
                }
            } else {
                let ac = UIAlertController(title:"Error", message:"Lo sentimos, pero al parecer no hay geolocalización. Deseas habilitarla?", preferredStyle: .alert)
                let action = UIAlertAction(title: "SI", style: .default) {
                    action1 in
                    // abrimos los setting del dispositivo para que habilite la localizacion
                    let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                    if UIApplication.shared.canOpenURL(settingsURL) {
                        UIApplication.shared.open(settingsURL, options: [:])
                    }
                }
                ac.addAction(action)
                let action2 = UIAlertAction(title: "NO", style: .default) {
                    action2 in
                    // Si necesitamos terminar una app. El código indica el tipo de error
                    exit(666)
                }
                ac.addAction(action2)
                self.present(ac, animated: true)
            }
        }
    }
    
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {
        getPlaces(latitude: self.latitude!, longitude: self.longitude!)
    }
    

    func getPlaces(latitude:String, longitude:String)
    {
        let ad = UIApplication.shared.delegate as! AppDelegate
        if ad.internetStatus {
            
            //loginButton.isHidden = true
            let endpoint = "https://asistik.com/api/places"
            //guard let apiUrl: URL = URL(string: endpoint) else { return }
            var url = URLComponents(string: "https://asistik.com/api/places")!
            
            url.queryItems = [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
            ]
            
            
            var request = URLRequest(url: url.url!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    print("Error es \(error)")
                    return
                }
                do {
                    let response = try JSONDecoder().decode(GenericModel.self, from: data)
                    if ( response.code == 200 ) {
                        
                        //Guardamos el token en el keychain de manera segura
                        self.places = response.data?.places ?? []
                        self.nearbyPlaces = response.data?.nearbyPlaces ?? []
                        
                        DispatchQueue.main.async {
                            self.horizontalCollectionView.reloadData()
                            self.verticalTableView.reloadData()
                            self.heightConstant.constant = CGFloat((self.places.count) * 230)
                        }
                        
                        
                    } else {
                        DispatchQueue.main.async {
                            //Show cant load
                        }
                    }
                } catch {
                    print(error)
                }
            }
            task.resume()
        } else {
            let ac = UIAlertController(title:"Error", message:"Para utilizar la aplicación, necesitas conectarte a internet, ¿quieres que abramos las configuraciones?", preferredStyle: .alert)
            let action = UIAlertAction(title: "SÍ", style: .default) {
                action1 in
                // abrimos los setting del dispositivo para que habilite la localizacion
                let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:])
                }
            }
            ac.addAction(action)
            let action2 = UIAlertAction(title: "NO, CERRAR APP", style: .default) {
                action2 in
                // Si necesitamos terminar una app. El código indica el tipo de error
                exit(666)
            }
            ac.addAction(action2)
            self.present(ac, animated: true)
        }
    }
    
    
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = verticalTableView.dequeueReusableCell(withIdentifier: "verticalCell", for: indexPath) as! VerticalTableViewCell
        
        cell.placeImageView.image = UIImage()
        cell.nameLabel.text = places[indexPath.row].name
        cell.descriptionLabel.text = places[indexPath.row].description
        cell.costLabel.text = "Promedio: $\(places[indexPath.row].cost)"
        
        if let imageUrl = URL(string: places[indexPath.row].img) {
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
                        cell.placeImageView.image = UIImage(data: imageData)
                    }
                }
            }
            // 5. Iniciamos tarea
            task.resume()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return nearbyPlaces.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = horizontalCollectionView.dequeueReusableCell(withReuseIdentifier: "horizontalCell", for: indexPath) as! HorizontalCollectionViewCell
            
            cell.placeImageView.image = UIImage()
            cell.nameLabel.text = nearbyPlaces[indexPath.row].name
            
            if let imageUrl = URL(string: nearbyPlaces[indexPath.row].img) {
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
                            cell.placeImageView.image = UIImage(data: imageData)
                        }
                    }
                }
                // 5. Iniciamos tarea
                task.resume()
            }
            return cell
 
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        showPlace(identifier: "showNearbyPlace")
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPlace(identifier: "showPlace")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlace" {
            let destination = segue.destination as! PlaceViewController
            destination.place =  places[verticalTableView.indexPathForSelectedRow!.row]
        }
        
        if segue.identifier == "showNearbyPlace" {
            let destination = segue.destination as! PlaceViewController
            destination.place =  nearbyPlaces[self.selectedIndex]
        }
        
    }
    
    func showPlace(identifier:String)
    {
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    
    
}
