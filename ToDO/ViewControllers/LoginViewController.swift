//
//  LoginViewController.swift
//  ToDO
//
//  Created by Иван Абрамов on 26.03.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit
import SwiftSMTP
import RealmSwift

// Enum  for checkbox states
public enum AuthorizationState {
    case signUp
    case singIn
}

var accounts: Results<Category>!

class LoginViewController: UIViewController {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var footerView: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var footerHeight: NSLayoutConstraint!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var bottomButtonConstraints: NSLayoutConstraint!
    
    var authorizationState: AuthorizationState = .singIn
    var oldFooterHeight: CGFloat = 0
    var oldCornerRadius: CGFloat = 0
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveCategories()
        
//        backgroundImage.image = UIImage(named: "After Noon.png")
//        backgroundImage.contentMode = .scaleAspectFill
        
        footerView.layer.cornerRadius = 50
        footerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        footerView.clipsToBounds = true
        
        
        if let image = UIImage(named: "email") {
            email.tintColor = .gray
            email.setIcon(image)
        }
        
        
        if let image = UIImage(named: "password") {
                   password.tintColor = .gray
                   password.setIcon(image)
        }
        
        
        if let image = UIImage(named: "username") {
            if authorizationState == .signUp {
                   username.tintColor = .gray
                   username.setIcon(image)
            }
        }
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: email.bounds.height - 20, width: email.frame.width, height: 1.0)
        bottomLine.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5176470588, blue: 0.8823529412, alpha: 1)
        email.borderStyle = UITextField.BorderStyle.none
        email.layer.addSublayer(bottomLine)
        
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: password.bounds.height - 20, width: password.frame.width, height: 1.0)
        bottomLine2.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5176470588, blue: 0.8823529412, alpha: 1)
        password.borderStyle = UITextField.BorderStyle.none
        password.layer.addSublayer(bottomLine2)
        
        if authorizationState == .signUp {
            let bottomLine3 = CALayer()
            bottomLine3.frame = CGRect(x: 0.0, y: password.bounds.height - 20, width: password.frame.width, height: 1.0)
            bottomLine3.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5176470588, blue: 0.8823529412, alpha: 1)
            username.borderStyle = UITextField.BorderStyle.none
            username.layer.addSublayer(bottomLine2)
        }
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
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
    
    
    var timesEnterVerificationCode = 0
    var userEmail = ""
    
    var state : Int = 0 {
        willSet(value) {
            if value == 0 {
                email.text =  ""
                email.placeholder = "Email"
//                descriptionText.text = "Please enter your email. We will send verification code to it"
            }
            else if value == 1 {
                email.text =  ""
                email.placeholder = "Verification code"
//                descriptionText.text = "Please enter verification code"
            }
        }
    }
    var verificationCode = ""
    
    let smtp = SMTP(
        hostname: "smtp.mail.ru",                                        // SMTP server address
        email: ProcessInfo.processInfo.environment["email"]!,            // username to login
        password: ProcessInfo.processInfo.environment["emailPassword"]!  // password to login
    )
    
    @IBAction func tapAction(_ sender: Any) {
//        if let keyboardHeight =  keyboardHeight {
//            print("Height: \(keyboardHeight)")
//            oldFooterHeight = footerHeight.constant
//            footerHeight.constant = footerHeight.constant + keyboardHeight
//        }
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
            
//            let keyboardHeight = keyboardRectangle.height
            
//            print("Height: \(keyboardHeight)")
            
            guard oldFooterHeight == 0 else { return }
            
//            guard keyboardHeight != 0 else { return }
            
            var constant = CGFloat(0)
            
            if authorizationState == .singIn {
                constant = CGFloat(75.0)
            }
            
            oldCornerRadius = footerView.layer.cornerRadius
            footerView.layer.cornerRadius =  0
            
            oldFooterHeight = footerHeight.constant
            footerHeight.constant = footerHeight.constant + abs(footerView.frame.size.height - (sendButton.frame.size.height + sendButton.frame.origin.y))
            
            footerHeight.constant = footerHeight.constant - constant
            
            UIView.animate(withDuration: 2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    @IBAction func send(_ sender: Any) {
        guard var email = email.text else {
            showAlert(title: "No email supplied", message: "Please, enter email", buttonText: "ok")
            return
        }
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard var password = password.text else {
            showAlert(title: "No password supplied", message: "Please, enter password", buttonText: "ok")
            return
        }
        
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let account = realm.objects(Account.self).filter("userEmail == %@", email).first else {
            showAlert(title: "No account found", message: "Please, recheck email. No account this provided email foun", buttonText: "Ok")
            
            return
        }
        

        if account.password ==  password {
            UserDefaults.standard.set(true, forKey: "isLogged")
            print("User email: \(userEmail)")
            UserDefaults.standard.set(email, forKey: "userEmail")
            self.performSegue(withIdentifier: "moveToMainScreen", sender: self)
        }
        else {
            showAlert(title: "Incorrect password or email", message: "Please, recheck email and password", buttonText: "Ok")
        }
        
        
//        switch state {
//        case 0:
//            guard textFIeld.text?.isEmpty == false else { return }
//            guard let tempmail = textFIeld.text else { return }
//
//            userEmail = tempmail
//            let secretCode = randomAlphaNumericString(length: 20)
//            verificationCode = secretCode
//            sendEmail(email: tempmail, subject: "Verification email", text: "Your verification code is \(secretCode)")
//            state = 1
//        case 1:
//                guard textFIeld.text?.isEmpty == false else { return }
//                if verificationCode.isEmpty == false/*textFIeld.text*/ {
//                    state = 0
//                    UserDefaults.standard.set(true, forKey: "isLogged")
//
//                    print("User email: \(userEmail)")
//                    UserDefaults.standard.set(userEmail, forKey: "userEmail")
//                    self.performSegue(withIdentifier: "moveToMainScreen", sender: self)
//                }
//                else {
//                    if timesEnterVerificationCode + 1 == 5 {
//                        state = 0
//                        timesEnterVerificationCode = 0
//                    }
//                    else {
//                        timesEnterVerificationCode += 1
//                        showAlert(title: "Incorrect verification code", message: "Please, try again. You have \(5 - timesEnterVerificationCode) attempts left", buttonText: "Ok")
//                    }
//                }
//
//        default:
//            print("Unknown state")
//        }
    }
    
    
    @IBAction func changeAuthorizationType(_ sender: Any) {
        if authorizationState == .signUp {
            performSegue(withIdentifier: "changeToSignIn", sender: self)
        } else {
            performSegue(withIdentifier: "changeToSignUp", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeToSignIn"  {
            let dst = segue.destination as! LoginViewController
            dst.authorizationState = .singIn
        }
        else if segue.identifier == "changeToSignUp" {
            let dst = segue.destination as! LoginViewController
            dst.authorizationState = .signUp
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
        
        guard oldFooterHeight != 0 else { return }
        footerHeight.constant =  oldFooterHeight
        oldFooterHeight = 0
        footerView.layer.cornerRadius = oldCornerRadius
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
     func saveCategories() {
//            let task1 = Task(categoryid: "1", id: "1", text: "Make design", userEmail: "Vanyusha.abramov.00@mail.ru", done: false)
//            let task2 = Task(categoryid: "1", id: "2", text: "store tasks", userEmail: "Vanyusha.abramov.00@mail.ru", done: false)
//            let task3 = Task(categoryid: "1", id: "3", text: "Fix bug with exoansion", userEmail: "Vanyusha.abramov.00@mail.ru", done: false)
//
//            StorageManager.saveTaskObject(task1)
//            StorageManager.saveTaskObject(task2)
//            StorageManager.saveTaskObject(task3)
    
    
    
    
//           let category1 = Category(id: "1", userEmail: "Vanyusha.abramov.00@mail.ru", categoryName: "Work")
//           let category2 = Category(id: "2", userEmail: "Vanyusha.abramov.00@mail.ru", categoryName: "School")
//           let category3 = Category(id: "3", userEmail: "Vanyusha.abramov.00@mail.ru", categoryName: "Home")
//
//           StorageManager.saveCategoryObject(category1)
//           StorageManager.saveCategoryObject(category2)
//           StorageManager.saveCategoryObject(category3)
            
            guard let imageData = UIImage(named: "face-1")!.pngData() else { return }
            let account = Account(id: "1", name: "Ivan", surname: "Abramov", userEmail: "Vanyusha.abramov.00@mail.ru", password: "Ivan230400", image: imageData)
            
            print("Saved")
            StorageManager.saveAccountObject(account)
               
           }

}

extension UITextField {
func setIcon(_ image: UIImage) {
   let iconView = UIImageView(frame:
                  CGRect(x: 0, y: 2, width: 20, height: 20))
   iconView.image = image
   let iconContainerView: UIView = UIView(frame:
                  CGRect(x: 0, y: 0, width: 30, height: 30))
   iconContainerView.addSubview(iconView)
   leftView = iconContainerView
   leftViewMode = .always
}
}
