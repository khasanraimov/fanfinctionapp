//
//  WrittingViewController.swift
//  fanfinctionapp
//
//  Created by mac on 28.05.2023.
//  Copyright © 2023 mac. All rights reserved.
//
//
//import UIKit
//import Firebase
//import FirebaseStorage
//import FirebaseDatabase
//
//class WrittingViewController: UIViewController {
//
//    @IBOutlet weak var fanficTextView: UITextView!
//    @IBOutlet weak var saveButton: UIButton!
//
//    var fanficID: String?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        fanficTextView.delegate = self
//
//        if let fanficID = fanficID {
//            // Загрузка информации о фанфике из базы данных
//            let fanficRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics").child(fanficID)
//            fanficRef.observe(.value) { (snapshot) in
//                if let fanficData = snapshot.value as? [String:Any], let fanficText = fanficData["text"] as? String {
//                    self.fanficTextView.text = fanficText
//                }
//            }
//        }
//    }
//
//    @IBAction func saveButtonTapped(_ sender: Any) {
//        guard let fanficText = fanficTextView.text, !fanficText.isEmpty else {
//            showAlert(withTitle: "Ошибка", message: "Введите текст фанфика")
//            return
//        }
//        if let fanficID = fanficID {
//            // Обновление информации о фанфике в базе данных
//            let fanficRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics").child(fanficID)
//            fanficRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
//                if var fanficData = currentData.value as? [String:Any] {
//                    // Добавление нового текста к существующему описанию фанфика
//                    var fanficDescription = ""
//                    if let oldDescription = fanficData["description"] as? String {
//                        fanficDescription = oldDescription
//                    }
//                    if fanficDescription.isEmpty {
//                        fanficDescription = fanficText
//                    } else {
//                        fanficDescription += "\n\n\(fanficText)"
//                    }
//                    fanficData["description"] = fanficDescription
//
//                    // Сохранение изменений в базе данных Firebase
//                    currentData.value = fanficData
//                    return TransactionResult.success(withValue: currentData)
//                } else {
//                    return TransactionResult.success(withValue: currentData)
//                }
//            }) { (error, committed, snapshot) in
//                if let error = error {
//                    self.showAlert(withTitle: "Ошибка", message: error.localizedDescription)
//                } else {
//                    self.showAlert(withTitle: "Успешно", message: "Изменения сохранены")
//                }
//            }
//        } else {
//            showAlert(withTitle: "Ошибка", message: "Ошибка загрузки информации о фанфике")
//        }
//    }
//
//    func showAlert(withTitle title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "ОК", style: .default)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
//    }
//}
//
//extension WrittingViewController: UITextViewDelegate {
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        return true
//    }
//}


import UIKit
import Firebase

class WrittingViewController: UIViewController {
    
    
    @IBOutlet weak var fanficTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    var fanficTitle: String?
    var fanficDescription: String?
    var fanficImageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fanficTextView.delegate = self
        
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    
    guard let fanficText = fanficTextView.text, !fanficText.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите текст фанфика")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(withTitle: "Ошибка", message: "Не удалось определить пользователя")
            return
        }
        
        let fanficRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics").childByAutoId()
        
        fanficRef.child("title").setValue(fanficTitle)
        fanficRef.child("description").setValue(fanficDescription)
        fanficRef.child("imageURL").setValue(fanficImageURL)
        fanficRef.child("text").setValue(fanficText)
        fanficRef.child("author").setValue(uid)
        
        showAlert(withTitle: "Успешно", message: "Фанфик успешно сохранен") { _ in
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "MainVC")
            UIApplication.shared.windows.first?.rootViewController = mainVC
        }
    }
    
    func showAlert(withTitle title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .default, handler: completion)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
extension WrittingViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = !textView.text.isEmpty
        saveButton.alpha = textView.text.isEmpty ? 0.5 : 1.0
    }
}
