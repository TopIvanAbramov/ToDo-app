//
//  EditNoteViewController.swift
//  ToDO
//
//  Created by Иван on 17.02.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

class EditNoteViewController: UITableViewController,  UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var noteText: UITextField!
    @IBOutlet weak var setUrgency: UISegmentedControl!
    @IBOutlet weak var setTime: UIPickerView!
    var newNote : Note?
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.isScrollEnabled = false
        setTime.delegate = self
        setTime.dataSource = self
        saveButton.isEnabled = false
        setupScreen()
        setupLabels()
        noteText.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        let swipeRight = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(swipeRightHandler))
        swipeRight.edges = .left
        swipeRight.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(swipeRight)
        
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
    }
    
    @objc func swipeRightHandler(_ sender: Any) {
//        print("Gesture recognized")
        
        if let _ = newNote {
            navigationController?.popViewController(animated: true)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
//        performSegue(withIdentifier: "moveBack", sender: nil)
    }
    
    func removeBackGesture() {
        
    }
    
    @objc private func textFieldChanged() {
           
           if noteText.text?.isEmpty == false {
               saveButton.isEnabled = true
           } else {
               saveButton.isEnabled = false
           }
       }
    
    func setupScreen() {
        guard let note = newNote else { return }
        noteText.text =  note.text
        saveButton.isEnabled = true
        setUrgency.selectedSegmentIndex = 1 - note.priority
    }
    
    func setupLabels() {
        let hourLabel = UILabel()
         setTime.addSubview(hourLabel)
         
         hourLabel.translatesAutoresizingMaskIntoConstraints = false
         hourLabel.centerYAnchor.constraint(equalTo: setTime.centerYAnchor, constant: 1).isActive = true
         hourLabel.centerXAnchor.constraint(equalTo: setTime.centerXAnchor, constant: -0.22 * setTime.frame.size.width).isActive = true
         hourLabel.text = "hour"
         
         
         let minLabel = UILabel()
         setTime.addSubview(minLabel)
        
         minLabel.translatesAutoresizingMaskIntoConstraints = false
         minLabel.centerYAnchor.constraint(equalTo: setTime.centerYAnchor, constant: 1).isActive = true
         minLabel.centerXAnchor.constraint(equalTo: setTime.centerXAnchor, constant: 0.11 * setTime.frame.size.width).isActive = true
         minLabel.text = "min"
         
         let secLabel = UILabel()
          setTime.addSubview(secLabel)
         
          secLabel.translatesAutoresizingMaskIntoConstraints = false
          secLabel.centerYAnchor.constraint(equalTo: setTime.centerYAnchor, constant: 1).isActive = true
          secLabel.centerXAnchor.constraint(equalTo: setTime.centerXAnchor, constant: 0.45 * setTime.frame.size.width).isActive = true
          secLabel.text = "sec"
    }
   
    func saveNote(text : String, priority : Int, creationTime: Double, timeInterval : Double)  {
        guard let userEmail =  UserDefaults.standard.string(forKey: "userEmail") else {
            return
        }
        
        if let newNote = newNote {
            try! realm.write {
                newNote.priority = priority
                newNote.text = text
                newNote.creationTime = creationTime
                newNote.timeInterval = timeInterval
                newNote.id = String(creationTime)
                newNote.userEmail = userEmail
            }
        }
        else {
            let newNote = Note(id : String(creationTime), text: text, priority: priority, creationTime: creationTime, timeInterval: timeInterval, done: false, userEmail : userEmail)
            StorageManager.saveObject(newNote)
        }
    }
    
    func save() {
        guard let text = noteText.text else { return }
        let priority =  1 - setUrgency.selectedSegmentIndex
        let time = Double(setTime.selectedRow(inComponent: 2)) + Double(setTime.selectedRow(inComponent: 1) * 60) + Double(setTime.selectedRow(inComponent: 0) * 3600)
        
        let creationTime = NSDate().timeIntervalSince1970
            
        saveNote(text: text, priority: priority, creationTime: creationTime, timeInterval: time)
//        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 24
        case 1:
        return 60
            
        case 2:
        return 60
        
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    
}
