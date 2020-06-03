//
//  AddTaskViewController.swift
//  ToDo
//
//  Created by Иван Абрамов on 27.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        newTask.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        addTaskButton.isUserInteractionEnabled = true
        addTaskButton.addGestureRecognizer(addCategoryGesture)
    }
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var addButtonTapAction : (()->())?
    @IBOutlet weak var newTask: UITextField!
    @IBOutlet weak var addButtonBottomconstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskButton: UIImageView!
    var categoryId = ""
    let defaults = UserDefaults.standard
    
    private lazy var addCategoryGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
            
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        recognizer.addTarget(self, action: #selector(addTaskHandler))
        
        return recognizer
        
    }()
    
    @objc func addTaskHandler(sender: UITapGestureRecognizer) {
        
        guard let taskName = newTask.text else { return }
        guard let userEmail =  defaults.string(forKey: "userEmail") else { return }
        let timestamp = NSDate().timeIntervalSince1970
        
        StorageManager.saveTaskObject(Task(categoryid: categoryId, id: String(timestamp), text: taskName, userEmail: userEmail, done: false))
        
        addButtonTapAction?()
        
//        performSegue(withIdentifier: "moveBackToNotes", sender: nil)
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                
                let keyboardHeight = keyboardRectangle.height

                addButtonBottomconstraint.constant = keyboardHeight
                
                let screenWidth = UIScreen.main.bounds.width
                
                UIView.animate(withDuration: 2, animations: {
                    self.view.layoutIfNeeded()
                })
                
                let rotateForwardAnimationDuration: TimeInterval = 1
                let rotateBackAnimationDuration: TimeInterval = 1
                let animationDuration: TimeInterval = rotateForwardAnimationDuration + rotateBackAnimationDuration

                self.addTaskTrailingConstraint.constant = 0
                self.addTaskWidthConstraint.constant = screenWidth
                
                UIView.animate(withDuration: 1, animations: {
                    self.view.layoutIfNeeded()
                })
                        
                UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: [], animations: {
        //            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: rotateForwardAnimationDuration) {
        //
        //            }

                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: rotateBackAnimationDuration) {
                    self.addTaskButton.layer.cornerRadius = 0
                }
                        })
            }
        }
}
