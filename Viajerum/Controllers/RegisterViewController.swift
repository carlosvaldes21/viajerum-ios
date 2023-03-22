//
//  RegisterViewController.swift
//  Viajerum
//
//  Created by Carlos Valdes on 16/03/23.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var roundedView: UIView!
    
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        roundedView.layer.cornerRadius = 40
        roundedView.clipsToBounds = true
    }
    

    @IBAction func onTapRegister(_ sender: LoaderButton) {
        if ( validateFields() ) {
            let ad = UIApplication.shared.delegate as! AppDelegate
            if ad.internetStatus {
                register(button:sender)
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
    
    func register(button: LoaderButton)
    {
        button.isLoading = true
        errorLabel.text = nil
        //loginButton.isHidden = true
        let endpoint = "https://asistik.com/api/register"
        guard let apiUrl: URL = URL(string: endpoint) else { return }
        
        var request = URLRequest(url: apiUrl)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: AnyHashable] = [
            "name": nameTextField.text,
            "email": emailTextField.text,
            "password":passwordTextField.text
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let response = try JSONDecoder().decode(GenericModel.self, from: data)
                
                if ( response.code == 200 ) {
                    
                    //Guardamos el token en el keychain de manera segura
                    let token = response.token
                    let tokenData: Data = token?.data(using: .utf8) ?? Data()
                    let status = KeyChain.save(key: "auth_token", data: tokenData)
                    
                    DispatchQueue.main.async {
                        self.showHome()
                    }
            
                    
                } else {
                    DispatchQueue.main.async {
                        button.isLoading = false
                        self.errorLabel.text = response.message
                    }
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    private func showHome()
    {
        performSegue(withIdentifier: "showHomeFromRegister", sender: self)
    }
    
    private func validateFields() -> Bool
    {
        if ( nameTextField.text!.count <= 0 ) {
            errorLabel.text = "Debes ingresar un nombre"
            return false
        }
        
        if ( emailTextField.text!.count <= 0 ) {
            errorLabel.text = "Debes ingresar un correo"
            return false
        }
        
        if ( passwordTextField.text!.count <= 6 ) {
            errorLabel.text = "Tu contraseña debe tener más de 6 caracteres"
            return false
        }
        
        return true
    }
    

}
