//
//  AddCategoryViewController.swift
//  ToDo
//
//  Created by Иван Абрамов on 28.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit
import RealmSwift

class AddCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)  as! EmojiCollectionViewCell
        
        
        
        let c = Int.random(in: 0x1F601...0x1F64F)
        
        let emoji = String(UnicodeScalar(c) ?? "-")
        
        cell.emoji.text = emoji
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 73, height: 73)
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 10.0
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryName.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        addCategoryButton.isUserInteractionEnabled = true
        addCategoryButton.addGestureRecognizer(addCategoryGesture)
        
        emojiCollectionView.delegate =  self
        emojiCollectionView.dataSource = self
    }
    
    
    @IBOutlet weak var categoryName: UITextField!
    @IBOutlet weak var addCategoryButton: UIImageView!
    @IBOutlet weak var addCategoryWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var addcategoryTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var addCategoryBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    let defaults = UserDefaults.standard
    var selectedEmoji = ""
    
    private lazy var addCategoryGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
            
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        recognizer.addTarget(self, action: #selector(addTaskHandler))
        
        return recognizer
        
    }()
    
    @objc func addTaskHandler(sender: UITapGestureRecognizer) {
          print("Add pressed")
        
        guard let categoryName = categoryName.text else { return }
        
        guard let userEmail =  defaults.string(forKey: "userEmail") else { return }
        
        let timestamp = NSDate().timeIntervalSince1970
        
        StorageManager.saveCategoryObject(Category(id: String(timestamp), userEmail: userEmail, categoryName: categoryName, emoji: selectedEmoji))
        
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEmoji = (emojiCollectionView.cellForItem(at: indexPath) as! EmojiCollectionViewCell).emoji.text!
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
              if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                  let keyboardRectangle = keyboardFrame.cgRectValue
                  
                  let keyboardHeight = keyboardRectangle.height

                  addCategoryBottomConstraint.constant = keyboardHeight
                  
                  let screenWidth = UIScreen.main.bounds.width
                  
                  UIView.animate(withDuration: 2, animations: {
                      self.view.layoutIfNeeded()
                  })
                  
                  let rotateForwardAnimationDuration: TimeInterval = 1
                  let rotateBackAnimationDuration: TimeInterval = 1
                  let animationDuration: TimeInterval = rotateForwardAnimationDuration + rotateBackAnimationDuration

                  self.addcategoryTrailingConstraint.constant = 0
                  self.addCategoryWidthConstraint.constant = screenWidth
                  
                  UIView.animate(withDuration: 1, animations: {
                      self.view.layoutIfNeeded()
                  })
                          
                  UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: [], animations: {
          //            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: rotateForwardAnimationDuration) {
          //
          //            }

                  UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: rotateBackAnimationDuration) {
                      self.addCategoryButton.layer.cornerRadius = 0
                  }
                          })
              }
          }
}
