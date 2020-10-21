//
//  ChooseAuthorizationViewController.swift
//  ToDo
//
//  Created by Иван Абрамов on 23.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//
import UIKit

class ChooseAuthorizationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.isHidden = false
        logoImage.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isLogged") ==  true {
            print("True")
            self.performSegue(withIdentifier: "moveToMainScreen", sender: self)
        }
        else {
            print("No")
        }
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToSignUp" {
            stackView.isHidden = true
            logoImage.isHidden =  true
            let dst = segue.destination as! LoginViewController
            dst.authorizationState = .signUp
        } else if segue.identifier == "moveToSignIn" {
            stackView.isHidden = true
            logoImage.isHidden = true
            let dst = segue.destination as! LoginViewController
            
            dst.authorizationState = .singIn
        }
    }
    

}
