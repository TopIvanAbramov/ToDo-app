//
//  AddCategoryCollectionViewCell.swift
//  ToDo
//
//  Created by Иван Абрамов on 21.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

class AddCategoryCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var addCategory: UIImageView!
    var addButtonTapAction : (()->())?
    
    private lazy var addCategoryGesture: UITapGestureRecognizer = {
            let recognizer = UITapGestureRecognizer()
                
            recognizer.numberOfTapsRequired = 1
            recognizer.numberOfTouchesRequired = 1
            recognizer.addTarget(self, action: #selector(addTaskHandler))
            
            return recognizer
            
        }()
        
        @objc func addTaskHandler(sender: UITapGestureRecognizer) {
             addButtonTapAction?()
        }
    
    override func awakeFromNib() {
        addCategory.isUserInteractionEnabled = true
        addCategory.addGestureRecognizer(addCategoryGesture)
    }    
}
