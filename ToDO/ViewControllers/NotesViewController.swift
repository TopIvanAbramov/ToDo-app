//
//  NotesViewController.swift
//  ToDo
//
//  Created by Иван Абрамов on 14.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit
import RealmSwift

var toDoNotes: Results<Category>!
var account: Results<Account>!

//var doneNotes: Results<Note>!

class NotesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,  UIGestureRecognizerDelegate {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionVIew: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileWelcomeMessage: UILabel!
    @IBOutlet weak var saveCategoriesChanges: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var emojiTopConstraint: NSLayoutConstraint!
    var oldEmojiTopConstraint: CGFloat = 0.0
    
    let defaults = UserDefaults.standard
    var categoryId = ""
    var tableNotes: UITableView?
    var selectedCell: NoteCollectionViewCell?
    
    var deleteActive = false
    
    @IBAction func changeProfilePhoto(sender: UIButton) {
        choosePhoto()
    }
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
           saveCategoriesChanges.isHidden = true
           menuButton.isHidden = false
           collectionVIew.dataSource = self
           collectionVIew.delegate = self
           collectionVIew.showsHorizontalScrollIndicator = false
        
        
            guard let userEmail =  defaults.string(forKey: "userEmail") else {
                return
            }
        
           toDoNotes = realm.objects(Category.self).filter("userEmail == %@", userEmail)
           account = realm.objects(Account.self).filter("userEmail == %@", userEmail)
        
          setupProfileImage()
//           doneNotes = realm.objects(Note.self).filter("userEmail == %@ AND done == true", userEmail).sorted(byKeyPath: "priority", ascending: false)
//        saveCategories()
       }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionVIew.reloadData()
    }
    
    func saveCategories() {
//        let task1 = Task(categoryid: "1", id: "1", text: "Make design", userEmail: "Vanyusha.abramov.00@mail.ru")
//        let task2 = Task(categoryid: "1", id: "2", text: "store tasks", userEmail: "Vanyusha.abramov.00@mail.ru")
//        let task3 = Task(categoryid: "1", id: "3", text: "Fix bug with exoansion", userEmail: "Vanyusha.abramov.00@mail.ru")
//
//        StorageManager.saveTaskObject(task1)
//        StorageManager.saveTaskObject(task2)
//        StorageManager.saveTaskObject(task3)
//
//
//
//
//           let category1 = Category(id: "1", userEmail: "Vanyusha.abramov.00@mail.ru", categoryName: "Work")
//           let category2 = Category(id: "2", userEmail: "Vanyusha.abramov.00@mail.ru", categoryName: "School")
//           let category3 = Category(id: "3", userEmail: "Vanyusha.abramov.00@mail.ru", categoryName: "Home")
//
//           StorageManager.saveCategoryObject(category1)
//           StorageManager.saveCategoryObject(category2)
//           StorageManager.saveCategoryObject(category3)
        
        guard let imageData = UIImage(named: "face-1")!.pngData() else { return }
        let account = Account(id: "1", name: "Ivan", surname: "Abramov", userEmail: "Vanyusha.abramov.00@mail.ru", password: "Ivan230400", image: imageData)
        
        print("Saved")
        StorageManager.saveAccountObject(account)
           
       }
    
    
    @IBAction func logOut(_ sender: Any) {
        performSegue(withIdentifier: "logOut", sender: nil)
        UserDefaults.standard.set(false, forKey: "isLogged")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
    
    func setupProfileImage() {
        containerView.layer.cornerRadius = 47 / 2
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        containerView.layer.shadowRadius = 20.0
        containerView.layer.shadowOpacity = 0.9
        
        if let data = account?.first?.image, let image = UIImage(data: data) {
            profileImage.image = image
        } else {
            profileImage.image = UIImage(named: "face")
        }
        
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 47 / 2
        profileImage.clipsToBounds = true
        profileImage.backgroundColor =  .clear
        
        if let name = account.first?.name {
            profileWelcomeMessage.text = "Hello, \(name)"
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (toDoNotes?.count ?? 0) + 1
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 290, height: 365) //365
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let insets = UIEdgeInsets(top: 355, left: 20, bottom: 10, right: 20)
        
        return insets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row >= (toDoNotes?.count ?? 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCategory", for: indexPath)  as! AddCategoryCollectionViewCell
            
            cell.backgroundImage.image = UIImage.imageWithColor(color: .white)
            cell.backgroundImage.layer.cornerRadius = 10
            cell.backgroundImage.clipsToBounds = true
            cell.backgroundImage.contentMode = .scaleAspectFill
            
            cell.layer.shadowColor =  #colorLiteral(red: 0.1536829472, green: 0.2184237838, blue: 0.4044732451, alpha: 1)
            cell.layer.shadowOffset = CGSize(width: 5, height: 10)
            cell.layer.shadowRadius = 1.0
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            
            cell.addButtonTapAction = {
                print("This")
                self.performSegue(withIdentifier: "addCategory", sender: self)
            }
            
            return cell
        }
        else {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Note", for: indexPath) as! NoteCollectionViewCell
            
            let note = toDoNotes[indexPath.row]
            
            cell.noteText.text = note.categoryName
            cell.categoryId = note.id
            cell.noteEmoji.text = "🛄"
            cell.backgroundImage.image = UIImage.imageWithColor(color: .white)
            cell.backgroundImage.layer.cornerRadius = 10
            cell.backgroundImage.clipsToBounds = true
            cell.backgroundImage.contentMode = .scaleAspectFill
            
            cell.noteEmoji.text = note.emoji
            cell.collectionView = collectionView
            cell.index = indexPath.row
            
            cell.profileImage =  profileImage
            cell.containerView = containerView
            
            cell.layer.shadowColor =  #colorLiteral(red: 0.1536829472, green: 0.2184237838, blue: 0.4044732451, alpha: 1)
            cell.layer.shadowOffset = CGSize(width: 5, height: 10)
            cell.layer.shadowRadius = 1.0
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            
            cell.tasks = realm.objects(Task.self).filter("categoryid == %@", note.id)
            cell.categoryId = note.id
            cell.addButtonTapAction = addTask
            
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(startWiggling))
            cell.addGestureRecognizer(longPressRecognizer)
        
                
            cell.disableLongPressGesture = {
                print("Disable")
                cell.removeGestureRecognizer(longPressRecognizer)
//                self.collectionVIew.removeGestureRecognizer(longPressRecognizer)
//                collectionView.removeGestureRecognizer(longPressRecognizer)
            }
            
            setupProgressBar(progressBar: cell.progressBar, tasks: cell.tasks)
            
            cell.deleteCell = {
                try! realm.write {
                    realm.delete(realm.objects(Task.self).filter("categoryid == %@", note.id))
                    realm.delete(note)
                }
                self.collectionVIew.deleteItems(at: [indexPath])
                self.collectionVIew.reloadData()
            }
            
            if deleteActive == true {
                addWiggle(cell: cell)
                cell.deleteCategory.alpha =  1
                saveCategoriesChanges.alpha = 1
                menuButton.alpha = 0
                disableGestureRecognizers(for: cell)
            } else {
                cell.deleteCategory.alpha = 0
                saveCategoriesChanges.alpha =  0
                menuButton.alpha = 1
                enableGestureRecognizers(for: cell)
            }
            
            return cell
        }
    }
    
    func disableGestureRecognizers(for cell: NoteCollectionViewCell) {
        cell.removeGestureRecognizer(cell.swipeUp)
    }
    
    func enableGestureRecognizers(for cell: NoteCollectionViewCell) {
        cell.addGestureRecognizer(cell.swipeUp)
    }
    
    func setupProgressBar(progressBar: UIProgressView, tasks: Results<Task>!) {
        let numberOfCompleteTasks = tasks.filter("done == true").count
        let totalNumberOfTasks = tasks.count
        
        if totalNumberOfTasks != 0 {
            progressBar.setProgress(Float(numberOfCompleteTasks) / Float(totalNumberOfTasks), animated: true)
        } else {
            progressBar.setProgress(0.0, animated: true)
        }
    }
    
    func addWiggle(cell: NoteCollectionViewCell) {
        let transformAnim  = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values  = [NSValue(caTransform3D: CATransform3DMakeRotation(0.02, 0.0, 0.0, 1.0)),NSValue(caTransform3D: CATransform3DMakeRotation(-0.02 , 0, 0, 1))]
        transformAnim.autoreverses = true
        transformAnim.duration  = (Double(5)) == 0 ?   0.115 : 0.105
        transformAnim.repeatCount = Float.infinity
        cell.layer.add(transformAnim, forKey: "transform")
    }
    
    @IBAction func stopWiggling(sender: UIButton!) {
        deleteActive = false
        menuButton.isHidden = false
        saveCategoriesChanges.isHidden = true
        collectionVIew.reloadData()
    }
    
    @objc func startWiggling(sender: UILongPressGestureRecognizer){
        deleteActive =  true
        saveCategoriesChanges.isHidden = false
        collectionVIew.reloadData()
    }
    
    func addTask(categoryId: String, table: UITableView, cell: NoteCollectionViewCell) -> () {
        self.categoryId = categoryId
        self.tableNotes = table
        self.selectedCell = cell
        self.performSegue(withIdentifier: "addTask", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "addTask" else { return }
        let dst = segue.destination  as! AddTaskViewController
        
        print("Passed category: \(categoryId)")
        dst.categoryId = categoryId
        
        dst.addButtonTapAction = {
            self.tableNotes?.reloadData()
        }
    }
     
    @IBOutlet weak var upperViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var upperViewTrailingConstraint: NSLayoutConstraint!
    var menuOut = false
    
    @IBAction func menuPressed() {
           if menuOut == false {
               menuOut =  true
                
               collectionVIew.isUserInteractionEnabled = false
            
                upperViewTrailingConstraint.constant = upperViewTrailingConstraint.constant - 250
                upperViewLeadingConstraint.constant = upperViewLeadingConstraint.constant + 250
                
                    UIView.animate(
                        withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        self.view.layoutIfNeeded() })
               
           }
           else {
               menuOut = false
               
               collectionVIew.isUserInteractionEnabled = true
            
               upperViewTrailingConstraint.constant = upperViewTrailingConstraint.constant + 250
               upperViewLeadingConstraint.constant = upperViewLeadingConstraint.constant - 250
                          
               UIView.animate(
                   withDuration: 0.2,
                   delay: 0,
                   options: .curveEaseIn,
                   animations: {
                   self.view.layoutIfNeeded() })
           }
       }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    
    func choosePhoto() {
        
        
        let cameraIcon = #imageLiteral(resourceName: "camera-1")
        let photoIcon = #imageLiteral(resourceName: "image")
        
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.chooseImagePicker(source: .camera)
        }
        
        camera.setValue(cameraIcon, forKey: "image")
        camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

        let photo = UIAlertAction(title: "Photo", style: .default) { _ in
            self.chooseImagePicker(source: .photoLibrary)
        }

        photo.setValue(photoIcon, forKey: "image")
        photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(cancel)

        present(actionSheet, animated: true)
    }
}

     //MARK: Work with image from color
extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

//MARK: Work with image picker
extension NotesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
          print("This")
          profileImage.image = info[.editedImage] as? UIImage
          
        guard let imageData = (info[.editedImage] as? UIImage)?.pngData() else {  return }
         try! realm.write {
            account.first?.image = imageData
        }

//        placeImage.image = info[.editedImage] as? UIImage
//        placeImage.contentMode = .scaleAspectFill
//        placeImage.clipsToBounds = true
//
//        imageIsChanged = true
        
        dismiss(animated: true)
    }
}
