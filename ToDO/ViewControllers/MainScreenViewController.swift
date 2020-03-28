//
//  MainScreenViewController.swift
//  ToDO
//
//  Created by Иван on 17.02.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit
import RealmSwift

class MainScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    var toDoNotes: Results<Note>!
    var doneNotes: Results<Note>!
    
    @IBOutlet weak var tableView: UITableView!
    var menuOut = false
    let defaults = UserDefaults.standard
    var userEmail = ""
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let userEmail =  defaults.string(forKey: "userEmail") else {
            return
        }
        print("User email: \(userEmail)")
        
        toDoNotes = realm.objects(Note.self).filter("userEmail == %@ AND done == false", userEmail).sorted(byKeyPath: "priority", ascending: false)
        doneNotes = realm.objects(Note.self).filter("userEmail == %@ AND done == true", userEmail).sorted(byKeyPath: "priority", ascending: false)
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
//        tableView.refreshControl = refreshControl
//        tableView.addSubview(refreshControl!)
        
        defaults.set("EN", forKey: "language")
        defaults.set("red", forKey: "urgent")
        defaults.set("green", forKey: "noturgent")
        
//        if #available(iOS 10.0, *) {
//             let refreshControl = UIRefreshControl()
//            tableView.refreshControl = refreshControl
//        } else {
//             let refreshControl = UIRefreshControl()
//            tableView.addSubview(refreshControl)
//        }
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh notes...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.tableFooterView  = UIView(frame: .zero)
        
        addSwipeHandlers()
        addObservers()
        
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
    }
    
    func addSwipeHandlers() {
        let swipeRight = UISwipeGestureRecognizer(target: self
                  , action: #selector(menuPressedObj))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
      
      
        let swipeLeft = UISwipeGestureRecognizer(target: self
          , action: #selector(menuPressedObj))
      
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func refresh() {
        tableView.reloadData()
        print("Start refreshing")
        let refreshControl = tableView.refreshControl
        print("End refreshing")
        refreshControl?.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return toDoNotes.count
        }
        else {
            return doneNotes.count
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        if indexPath.section == 0 {
            let note = toDoNotes[indexPath.row]
            
            cell.setColor(priority: note.priority)
            cell.titleLabel.text = note.text
            cell.totaTime = note.timeInterval
            
            let currentTime = NSDate().timeIntervalSince1970
            
            if let creationTime = TimeInterval(exactly: note.creationTime) {
                let timeDifference = findDateDiff(time1: creationTime, time2: currentTime)
    //            print("Time difference: \(timeDifference)")
                if let timeInterval = TimeInterval(exactly: note.timeInterval) {
    //                print("Time interval: \(timeInterval)")
                    let remainingTime = findDateDiff(time1: timeDifference, time2: timeInterval)
    //                print("Remaining time: \(remainingTime)")
                    if remainingTime > 0 {
                        
                        sendNotification(time: remainingTime, identifier: note.id, title: "Time for task expired", body: "Task: \(note.text)")
                        
                        cell.expiryTimeInterval = remainingTime
                    }
                    else {
                        cell.timeCounter = 0
                        cell.onComplete()
                    }
                }
            }
            
            
            return cell
        }
        else {
            let note = doneNotes[indexPath.row]
            
            cell.setColor(priority: note.priority)
            cell.titleLabel.text = note.text
            cell.totaTime = note.timeInterval
            
            cell.timeCounter = 0
            cell.onComplete()
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "editNote", sender: nil)
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
          
        guard let newNoteVC = segue.source as? EditNoteViewController else { return }
        menuOut = false
        print("Save note")
        newNoteVC.save()
        tableView.reloadData()
    }
    
    @IBAction func cancelSegue(_ segue: UIStoryboardSegue) {
        
        
        if menuOut == true {
            menuPressed()
        }
        print("Cancel")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let note = indexPath.section == 0 ? toDoNotes[indexPath.row] : doneNotes[indexPath.row]
            let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (_, _, _) in
                self.removeNotification(identifier: String(note.id))
                StorageManager.deleteObject(note)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
  
            deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            let actions = UISwipeActionsConfiguration(actions: [deleteAction])
            return actions
            
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 0 else { return nil }
        let note = toDoNotes[indexPath.row]
        let doneAction = UIContextualAction(style: .normal, title: "Done") { (_, _, _) in
            self.removeNotification(identifier: String(note.id))
            try! realm.write {
                note.done = true
            }
            tableView.reloadData()
        }

        doneAction.image = UIImage(named: "check")
        doneAction.backgroundColor = #colorLiteral(red: 0, green: 0.7593953013, blue: 0.6479150057, alpha: 1)
        let actions = UISwipeActionsConfiguration(actions: [doneAction])
        
        return actions
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "ToDo"
        }
        else {
            return "Done"
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "editNote" else { return }
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        
        if indexPath.section == 0  {
            let note = toDoNotes[indexPath.row]
            let newPlaceVC = segue.destination as! EditNoteViewController
            
            newPlaceVC.newNote = note
        }
        else {
            let note = doneNotes[indexPath.row]
            let newPlaceVC = segue.destination as! EditNoteViewController
            
            newPlaceVC.newNote = note
        }
    }
    
    func findDateDiff(time1: TimeInterval, time2: TimeInterval) -> TimeInterval {
                let temp = time2 - time1
                return temp
    }

    func scheduleNotification(title: String, body: String) -> UNMutableNotificationContent {
           
           let content = UNMutableNotificationContent() // Содержимое уведомления
           
           content.title = title
           content.body = body
           content.sound = UNNotificationSound.default
           content.badge = 1
        
        return content
    }
    
    func sendNotification(time: TimeInterval, identifier : String,  title: String, body: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(time), repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: scheduleNotification(title: title, body: body), trigger: trigger)

        let tempClass = AppDelegate()
        
        tempClass.notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func removeNotification(identifier : String) {
        let tempClass = AppDelegate()
        
        tempClass.notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func removeAllNotifications() {
        let tempClass = AppDelegate()
        tempClass.notificationCenter.removeAllDeliveredNotifications()
    }
    
    @IBAction func menuPressed() {
        if menuOut == false {
            menuOut =  true
            
             self.trailingConstraint.constant = self.trailingConstraint.constant - 150
             self.leadingConstraint.constant = self.leadingConstraint.constant + 150
             
                 UIView.animate(
                     withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                     self.view.layoutIfNeeded() })
            
        }
        else {
            menuOut = false
            
            self.trailingConstraint.constant = self.trailingConstraint.constant + 150
            self.leadingConstraint.constant = self.leadingConstraint.constant - 150
                       
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseIn,
                animations: {
                self.view.layoutIfNeeded() })
        }
    }
    
    @objc func menuPressedObj(_ sender: UISwipeGestureRecognizer) {
        if menuOut == false  && sender.direction == .right {
               menuOut =  true
               
            self.trailingConstraint.constant = self.trailingConstraint.constant - 150
            self.leadingConstraint.constant = self.leadingConstraint.constant + 150
            
                UIView.animate(
                    withDuration: 0.2,
                   delay: 0,
                   options: .curveEaseIn,
                   animations: {
                    self.view.layoutIfNeeded() })
               
           }
        else if menuOut == true && sender.direction == .left {
               menuOut = false
               
            self.trailingConstraint.constant = self.trailingConstraint.constant + 150
            self.leadingConstraint.constant = self.leadingConstraint.constant - 150
                       
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseIn,
                animations: {
                self.view.layoutIfNeeded() })
    }
       }
    
    @IBAction func chooseLanguage(_ sender: UISegmentedControl) {
        let selectedLanguage = sender.titleForSegment(at: sender.selectedSegmentIndex)
        defaults.set(selectedLanguage, forKey: "language")
        
    }
    
    @IBAction func chooseColorUrgent(_ sender: UIButton) {
        let colors = ["red", "green", "yellow"]
        let selectedColor = colors[sender.tag]
        defaults.set(selectedColor, forKey: "urgent")
        tableView.reloadData()
    }
    
    @IBAction func chooseColorNotUrgent(_ sender: UIButton) {
        let colors = ["red", "green", "yellow"]
        let selectedColor = colors[sender.tag]
        defaults.set(selectedColor, forKey: "noturgent")
        tableView.reloadData()
    }
    
    @IBAction func logOut(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "userEmail")
        UserDefaults.standard.set(false, forKey: "isLogged")
        removeAllNotifications()
        dismiss(animated: true, completion: nil)
    }
    
    
    fileprivate  func addObservers() {
          NotificationCenter.default.addObserver(self,
                                                 selector: #selector(applicationDidBecomeActive),
                                                 name: UIApplication.didBecomeActiveNotification,
                                                 object: nil)
        }

    fileprivate  func removeObservers() {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        }

    @objc fileprivate func applicationDidBecomeActive() {
        tableView.reloadData()
    }
}
