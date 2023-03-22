//
//  AuthViewController.swift
//  Viajerum
//
//  Created by Carlos Valdes on 16/03/23.
//

import UIKit

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        if let receivedData = KeyChain.load(key: "auth_token") {
            let result = String(decoding: receivedData, as: UTF8.self)
            if ( result != "" ) {
                showHome()
            } else {
                super.viewDidLoad()
            }
        }
        
    }
    
    private func showHome()
    {
        performSegue(withIdentifier: "showHome", sender: self)
    }
    
    
    @IBAction func unwindToAuth( _ sender: UIStoryboardSegue ){
        
    }


}
