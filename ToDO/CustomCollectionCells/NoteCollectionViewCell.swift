//
//  NoteCollectionViewCell.swift
//  ToDo
//
//  Created by Иван Абрамов on 14.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit
import RealmSwift



// Enum  for cell states
 public enum State {
    case expanded
    case collapsed
    
    var change: State {
        switch self {
        case .expanded: return .collapsed
        case .collapsed: return .expanded
        }
    }
}


class NoteCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate {

     var tasks: Results<Task>!
     @IBOutlet weak var backgroundImage: UIImageView!
     @IBOutlet weak var noteText: UILabel!
     @IBOutlet weak var noteEmoji: UILabel!
     
     @IBOutlet weak var progressBar: UIProgressView!
     @IBOutlet weak var addTask: UIImageView!
     
     @IBOutlet weak var addTaskTrailingConstraint: NSLayoutConstraint!
     var oldAdTaskTrailingConstraint: CGFloat?
     
     @IBOutlet weak var addTaskWidthConstraint: NSLayoutConstraint!
     var oldAddTaskWidthConstraint: CGFloat?
     
     @IBOutlet weak var backButton: UIButton!
     @IBOutlet weak var menuButton: UIButton!
     
     var addButtonTapAction : ((String, UITableView, NoteCollectionViewCell)->())?
     var deleteCell : (()->())?
     var disableLongPressGesture: (() -> ())?
    
     @IBOutlet weak var profileWelcomeMessage: UILabel!
     
     @IBOutlet weak var tableNotes: UITableView!
     
     @IBOutlet var topNoteTextConstraint: NSLayoutConstraint!
     private var oldTopNoteTextConstraint: CGFloat?
     
     private var newTopNoteTextConstraint: CGFloat?
     
     var longpressGesture: UILongPressGestureRecognizer?
     var categoryId: String?
     @IBOutlet var deleteCategory: UIButton!
    
     private var animationProgress: CGFloat = 0
     
     var profileImage: UIImageView!
     weak var containerView: UIView!
     
     var collectionView: UICollectionView?
     @IBOutlet weak var profileDescription: UILabel?
     
     var index: Int?
     
     weak var time : UILabel!
     var timer : Timer?
     var timeCounter: Double = 0
     var totaTime : Double = 0
    
     private var initialFrame: CGRect?
    var state: State = .collapsed
     private lazy var animator: UIViewPropertyAnimator = {
         return UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
     }()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }
    
    func deleteTask(task: Task) {
            try! realm.write {
                realm.delete(task)
            }
    }
    
    
    
    @IBAction func deleteCategoryHandler(sender: UIButton) {
        deleteCell?()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! TasksTableViewCell
        
        // Configure the cell’s contents.

        
        let task = tasks[indexPath.row]
        
        cell.checkBoxButton.addTarget(self, action: #selector(onClickedMapButton(_:)), for: .touchUpInside)
        cell.checkBoxButton.indexPath = indexPath
        
        cell.trashButton.task = task
        
        cell.buttonAction = { sender in
            self.deleteTask(task: task)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("Tapped action")
        }
        
        if task.done == true {
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: task.text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.taskText.attributedText = attributeString
            
            cell.checkBoxButton.setBackgroundImage(UIImage(systemName: "checkmark.square"), for: .normal)
            cell.trashButton.isHidden = false
            
            
        } else {
            cell.checkBoxButton.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            cell.taskText.attributedText = NSAttributedString(string: task.text)
            cell.trashButton.isHidden = true
        }
            
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    @objc func onClickedMapButton(_ sender: CheckBoxbutton) {
        guard let indexPath = sender.indexPath else { return }
        
        let task = tasks[indexPath.row]
        
        let cell = tableNotes.cellForRow(at: indexPath) as! TasksTableViewCell
        
        guard let button = cell.checkBoxButton else { return }
        guard let trashButton = cell.trashButton else { return }
        
        if button.checkState == .checked {
          
            trashButton.isHidden = true
            button.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            saveTaskDoneState(task: task, done: false)
        } else {
            
            trashButton.isHidden = false
            button.setBackgroundImage(UIImage(systemName: "checkmark.square"), for: .normal)
            saveTaskDoneState(task: task, done: true)
        }
        button.checkState = button.checkState.change
        tableNotes.reloadData()
        
        setupProgressBar()
    }

    func saveTaskDoneState(task: Task, done: Bool) {
        try! realm.write {
            task.done =  done
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
            case 0:
                sectionName = "Today"
            case 1:
                sectionName = "Tomorror"
            default:
                sectionName = ""
        }
        return sectionName
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let sectionName: String
//        switch section {
//            case 0:
//                sectionName = "Today"
//            case 1:
//                sectionName = "Tomorror"
//            // ...
//            default:
//                sectionName = ""
//        }
//
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
//
//        headerView.textla
//        headerView.backgroundColor = .clear
//
//
//        return headerView
//    }
    
    
    func setupProgressBar() {
        let numberOfCompleteTasks = tasks.filter("done == true").count
        let totalNumberOfTasks = tasks.count
        
        if totalNumberOfTasks != 0 {
            progressBar.setProgress(Float(numberOfCompleteTasks) / Float(totalNumberOfTasks), animated: true)
        } else {
            progressBar.setProgress(0.0, animated: true)
        }
    }
    
    @IBOutlet weak var emojiTopConstraint: NSLayoutConstraint!
    var oldEmojiTopConstraint : CGFloat = 0.0
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let sectionName: String
        switch section {
            case 0:
                sectionName = "Today"
            case 1:
                sectionName = "Tomorror"
            // ...
            default:
                sectionName = ""
        }
        
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        
        header.textLabel?.text = sectionName
        header.textLabel?.font = UIFont(name: "System", size: 11)
        header.textLabel?.textColor = UIColor.gray
    }
    
    
    
    
   
    @IBAction func close(_ sender: Any) {
        toggle()
    }
     
    func toggle() {
        switch state {
        case .expanded:
            collapse()
        case .collapsed:
            expand()
        }
    }
    
    
    
    func expand() {
        guard let collectionView = self.collectionView, let index = self.index else { return }

        disableLongPressGesture?()
        setupProgressBar()
        
        
        animator.addAnimations {
            
            self.profileImage.alpha = 0
            self.containerView.alpha = 0
            self.profileWelcomeMessage.alpha = 0
            self.profileDescription?.alpha = 0

            self.menuButton.isHidden = true
            
            self.tableNotes.alpha = 1
            self.addTask.alpha = 1
            self.backButton.alpha = 1
            
            
            let collectionSize = self.collectionView?.frame
            self.emojiTopConstraint.constant =  150
            self.topNoteTextConstraint.constant = 210
            self.initialFrame = self.frame
            self.frame = CGRect(x:collectionView.contentOffset.x, y:0 , width: collectionSize!.width, height: collectionSize!.height)
            
            if let leftCell = collectionView.cellForItem(at: IndexPath(row: index - 1, section: 0)) {
                leftCell.center.x -= 500
            }
            
            if let rightCell = collectionView.cellForItem(at: IndexPath(row: index + 1, section: 0)) {
                rightCell.center.x += 500
            }
            
            self.layoutIfNeeded()
        }
        
        animator.addCompletion { position in
            switch position {
            case .end:
                self.state = self.state.change
                collectionView.isScrollEnabled = false
                collectionView.allowsSelection = false
            default:
                ()
            }
        }
        
        animator.startAnimation()
    }
    
    
    func collapse() {
        guard let collectionView = self.collectionView, let index = self.index else { return }
        
        animator.addAnimations {
                    
            self.profileWelcomeMessage.alpha = 1
            self.profileDescription?.alpha = 1
            self.profileImage.alpha = 1
            self.containerView.alpha =  1
            self.menuButton.isHidden = false
            
            
            self.tableNotes.alpha = 0
            self.backButton.alpha = 0
            self.addTask.alpha = 0
        
            self.emojiTopConstraint.constant = self.oldEmojiTopConstraint
            self.topNoteTextConstraint.constant = self.oldTopNoteTextConstraint!
            self.frame = self.initialFrame!
            
            
            if let leftCell = collectionView.cellForItem(at: IndexPath(row: index - 1, section: 0)) {
                leftCell.center.x += 500
            }
            
            if let rightCell = collectionView.cellForItem(at: IndexPath(row: index + 1, section: 0)) {
                rightCell.center.x -= 500
            }
            
            self.layoutIfNeeded()
        }
        
        animator.addCompletion { position in
            switch position {
            case .end:
                self.state = self.state.change
                collectionView.isScrollEnabled = true
                collectionView.allowsSelection = true
            default:
                ()
            }
        }
        
        animator.startAnimation()
    }
    
    private lazy var addTaskGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
            
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        recognizer.addTarget(self, action: #selector(addTaskHandler))
        
        return recognizer
        
    }()
    
    @objc func addTaskHandler(sender: UITapGestureRecognizer) {
        
        oldAdTaskTrailingConstraint = addTaskTrailingConstraint.constant
        self.oldAddTaskWidthConstraint = self.addTaskWidthConstraint.constant
        
        guard let categoryId = categoryId else { return }
        addButtonTapAction?(categoryId, tableNotes, self)
    }
    
    
    private lazy var popupOffset: CGFloat = (self.collectionView?.frame.height ?? 0 - self.frame.height)
    
    lazy var swipeUp: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
            
        recognizer.delegate = self
        recognizer.addTarget(self, action: #selector(popupViewPanned))
        
        return recognizer
        
    }()
    

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return abs((swipeUp.velocity(in: swipeUp.view)).y) > abs((swipeUp.velocity(in: swipeUp.view)).x)
    }
    
    @objc func swipeUpDown(sender: UISwipeGestureRecognizer) {
        
        if (sender.direction == .up && state == .collapsed)  {
            toggle()
        }
        
        if (sender.direction == .down && state == .expanded)  {
                   toggle()
        }
    }
    
    @objc func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animationProgress = animator.fractionComplete
            toggle()
            animator.pauseAnimation()
            
        case .changed:
            let translation = recognizer.translation(in: collectionView)
            var fraction = -translation.y / popupOffset
            if state == .expanded {
                fraction *= -1
            }
            animator.fractionComplete = fraction + animationProgress
            animator.fractionComplete = fraction
            
        case .ended:
            let velocity = recognizer.velocity(in: self)
            let shouldComplete = velocity.y > 0
            
            if (state == .collapsed && velocity.y > 0) {
                collapse()
            }
            
            if (state == .expanded && velocity.y < 0) {
                expand()
            }
            
            if velocity.y == 0 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
            
            switch state {
            case .expanded:
                if !shouldComplete && !animator.isReversed { animator.isReversed = !animator.isReversed }
                if shouldComplete && animator.isReversed { animator.isReversed = !animator.isReversed }
            case .collapsed:
                if shouldComplete && !animator.isReversed { animator.isReversed = !animator.isReversed }
                if !shouldComplete && animator.isReversed { animator.isReversed = !animator.isReversed }
            }
            
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            
        default:
            ()
        }
    }
    
    func setupAddTaskButton() {
        addTask.layer.shadowColor =  #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        addTask.layer.shadowOffset = CGSize(width: 3, height: 7)
        addTask.layer.shadowRadius = 1.0
        addTask.layer.shadowOpacity = 0.5
        addTask.layer.masksToBounds = false
    }
    
    override func awakeFromNib() {
        self.addGestureRecognizer(swipeUp)
        
        addTask.isUserInteractionEnabled = true
        addTask.addGestureRecognizer(addTaskGesture)
        
        tableNotes.delegate = self
        tableNotes.dataSource = self
        
        tableNotes.alpha = 0
        addTask.alpha = 0
        addTask.layer.cornerRadius = 55 / 2
        
        tableNotes.tableFooterView = UIView()
        
        backButton.alpha =  0
        menuButton.isHidden =  false
        
        oldEmojiTopConstraint = emojiTopConstraint.constant
        oldTopNoteTextConstraint = topNoteTextConstraint.constant
        
        setupAddTaskButton()
    }
}
