//
//  CheckBoxbutton.swift
//  ToDo
//
//  Created by Иван Абрамов on 20.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

// Enum  for checkbox states
public enum CheckState {
    case checked
    case uncheked

    var change: CheckState {
        switch self {
        case .checked: return .uncheked
        case .uncheked: return .checked
        }
    }
}

class CheckBoxbutton: UIButton {
    var indexPath: IndexPath?
    var checkState: CheckState = .uncheked
}
