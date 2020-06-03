//
//  TrashButton.swift
//  ToDo
//
//  Created by Иван Абрамов on 29.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit
import RealmSwift

// Enum  for checkbox states
public enum TrashState {
    case visible
    case hidden

    var change: TrashState {
        switch self {
        case .visible: return .hidden
        case .hidden: return .visible
        }
    }
}

class TrashButton: UIButton {
    var task: Task?
    
    var visibilityState: TrashState = .hidden
    
   
}
