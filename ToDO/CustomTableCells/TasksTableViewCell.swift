//
//  TasksTableViewCell.swift
//  ToDo
//
//  Created by Иван Абрамов on 20.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit
import RealmSwift

class TasksTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBoxButton: CheckBoxbutton!
    @IBOutlet weak var taskText: UILabel!
    @IBOutlet weak var trashButton: TrashButton!
    var buttonAction: ((Any) -> Void)?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func buttonPressed(sender: Any) {
        self.buttonAction?(sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        trashButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
//        trashButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
    }
    
   
}
