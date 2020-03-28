//
//  LaunchViewController.swift
//  ToDO
//
//  Created by Иван Абрамов on 23.03.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoView.layer.shadowColor = UIColor.black.cgColor
        logoView.layer.shadowOpacity = 1
        logoView.layer.shadowOffset = .zero
        logoView.layer.shadowRadius = 10
    }
    
    @IBOutlet weak var logoView: UIView!
   

}
