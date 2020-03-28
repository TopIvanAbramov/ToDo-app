//
//  LoginViewController.swift
//  ToDO
//
//  Created by Иван Абрамов on 26.03.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit
import SwiftSMTP

class LoginViewController: UIViewController {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.image = UIImage(named: "After Noon.png")
        backgroundImage.contentMode = .scaleAspectFill
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
    
    @IBOutlet weak var textFIeld: UITextField!
    
    var timesEnterVerificationCode = 0
    var userEmail = ""
    
    var state : Int = 0 {
        willSet(value) {
            if value == 0 {
                textFIeld.text =  ""
                textFIeld.placeholder = "Email"
//                descriptionText.text = "Please enter your email. We will send verification code to it"
            }
            else if value == 1 {
                textFIeld.text =  ""
                textFIeld.placeholder = "Verification code"
//                descriptionText.text = "Please enter verification code"
            }
        }
    }
    var verificationCode = ""
    
    let smtp = SMTP(
        hostname: "smtp.mail.ru",                   // SMTP server address
        email: "Vanyusha.abramov.00@mail.ru",       // username to login
        password: "namryn-5vuqje-wYsqic"            // password to login
    )
    
    
    @IBAction func send(_ sender: Any) {
        switch state {
        case 0:
            guard textFIeld.text?.isEmpty == false else { return }
            guard let tempmail = textFIeld.text else { return }
            
            userEmail = tempmail
            let secretCode = randomAlphaNumericString(length: 20)
            verificationCode = secretCode
            sendEmail(email: tempmail, subject: "Verification email", text: "Your verification code is \(secretCode)")
            state = 1
        case 1:
                guard textFIeld.text?.isEmpty == false else { return }
                if verificationCode == textFIeld.text {
                    state = 0
                    UserDefaults.standard.set(true, forKey: "isLogged")
                    
                    print("User email: \(userEmail)")
                    UserDefaults.standard.set(userEmail, forKey: "userEmail")
                    self.performSegue(withIdentifier: "moveToMainScreen", sender: self)
                }
                else {
                    if timesEnterVerificationCode + 1 == 5 {
                        state = 0
                        timesEnterVerificationCode = 0
                    }
                    else {
                        timesEnterVerificationCode += 1
                        showAlert(title: "Incorrect verification code", message: "Please, try again. You have \(5 - timesEnterVerificationCode) attempts left", buttonText: "Ok")
                    }
                }
            
        default:
            print("Unknown state")
        }
    }
    
    
    func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""

        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }

        return randomString
    }
    
    func showAlert(title : String, message : String, buttonText : String) {
               let alert = UIAlertController(title: title ,message: message, preferredStyle: .alert)
               
                           alert.addAction(UIAlertAction(title: buttonText, style: .cancel, handler: nil))
               
                           self.present(alert, animated: true)
    }
    
    func sendEmail(email : String, subject : String, text : String) {
        let user = Mail.User(email: "\(email)")
        let myMail = Mail.User(name: "Ivan", email: "Vanyusha.abramov.00@mail.ru")
        
        let mail = Mail(
            from: myMail,
            to: [user],
            subject: subject,
            text: text
        )

        smtp.send(mail) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

}
