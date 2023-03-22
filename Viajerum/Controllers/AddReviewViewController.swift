//
//  AddReviewViewController.swift
//  Viajerum
//
//  Created by Carlos Valdes on 21/03/23.
//

import UIKit
import Cosmos

class AddReviewViewController: UIViewController {

    var place : Place?
    var token: String?
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var textFieldComment: UITextView!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var saveButton: LoaderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        if let receivedData = KeyChain.load(key: "auth_token") {
            let result = String(decoding: receivedData, as: UTF8.self)
            token = result
        }
        
        cosmosView.rating = 0
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSaveReview(_ sender: LoaderButton) {
        if ( validateFields() ) {
            let ad = UIApplication.shared.delegate as! AppDelegate
            if ad.internetStatus {
                rate()
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

        
    func rate() {
        saveButton.isLoading = true
        errorLabel.text = nil
        //loginButton.isHidden = true
        let endpoint = "https://asistik.com/api/rate"
        guard let apiUrl: URL = URL(string: endpoint) else {
            return
        }
        
        var request = URLRequest(url: apiUrl)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body: [String: AnyHashable] = [
            "comment": textFieldComment.text,
            "rating":cosmosView.rating,
            "place_id":place!.id,
            "user_id":place!.userID
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let response = try JSONDecoder().decode(GenericModel.self, from: data)
                
                if ( response.code == 200 ) {
                    DispatchQueue.main.async {
                        
                        self.saveButton.isLoading = false
                        self.performSegue(withIdentifier: "unwindToHome", sender: self)

                    }
            
                    
                } else {
                    DispatchQueue.main.async {
                        self.saveButton.isLoading = false
                        self.errorLabel.text = response.message
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorLabel.text = "No podemos guardar tu opinión, inténtalo en otro momento"
                }
                print(error)
            }
        }
        task.resume()
    }
    
    private func validateFields() -> Bool
    {
        if ( textFieldComment.text!.count <= 0 ) {
            errorLabel.text = "Debes ingresar un comentario"
            return false
        }
        
        if ( cosmosView.rating <= 0 ) {
            errorLabel.text = "Selecciona una calificación"
            return false
        }
        
        return true
    }
    
    

}
