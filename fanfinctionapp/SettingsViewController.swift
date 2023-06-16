//
//  SettingsViewController.swift
//  fanfinctionapp
//
//  Created by mac on 15.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var changeNickname: UILabel!
    @IBOutlet weak var changeNicknameText: UITextField!
    @IBOutlet weak var changeEmail: UILabel!
    @IBOutlet weak var changeEmailText: UITextField!
    @IBOutlet weak var dateBirthday: UILabel!
    @IBOutlet weak var dateOfBirthText: UITextField!

    @IBOutlet weak var aboutMe: UILabel!
    @IBOutlet weak var aboutMeText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeNicknameText.delegate = self as? UITextFieldDelegate
        changeEmailText.delegate = self as? UITextFieldDelegate
        dateOfBirthText.delegate = self as? UITextFieldDelegate
        aboutMeText.delegate = self as? UITextFieldDelegate

        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let databaseRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference()
        let userRef = databaseRef.child("users/\(currentUser.uid)")
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let userData = snapshot.value as? [String: Any] {
                self.changeNicknameText.text = userData["nickname"] as? String
                self.changeEmailText.text = userData["email"] as? String
                self.aboutMeText.text = userData["about_me"] as? String
                self.dateOfBirthText.text = userData["date_of_birthday"] as? String
            }
        }
        
    }
    @IBAction func logOutButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Выход", message: "Вы уверены, что хотите выйти из аккаунта?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .destructive) { (_) in
            do {
                try Auth.auth().signOut()
                let alertController = UIAlertController(title: "Успешный выход", message: "Вы успешно вышли из аккаунта", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "ToLogin", sender: nil)
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } catch let error as NSError {
                print("Ошибка при выходе из аккаунта: \(error.localizedDescription)")
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let confirmDeleteAlert = UIAlertController(title: "Удаление аккаунта", message: "Вы действительно хотите удалить свой аккаунт? Это действие нельзя будет отменить.", preferredStyle: .alert)
        confirmDeleteAlert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { (_) in
            let databaseRef = Database.database(url: "https://fanhasan-16c49-default-rtdb.firebaseio.com/").reference()
            let fanficRef = databaseRef.child("fanfics")
            
            // Удаление фанфиков пользователя из Firebase Realtime Database
            fanficRef.queryOrdered(byChild: "author/user_id/nickname").queryEqual(toValue: user.displayName ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                    guard let snap = child as? DataSnapshot else {
                        continue
                    }
                    let fanficID = snap.key
                    
                    // удаление фанфика
                    databaseRef.child("fanfics/\(fanficID)").removeValue()
                }
            })
            
            // Удаление данных пользователя из Firebase Realtime Database
            let userRef = databaseRef.child("users/\(user.uid)")
            userRef.removeValue()
            
            // Удаление аккаунта пользователя из Firebase Authentication
            user.delete { error in
                if let error = error {
                    let alertController = UIAlertController(title: "Ошибка", message: "Не удалось удалить аккаунт. Попробуйте ещё раз позже.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    print("Ошибка при удалении аккаунта: \(error.localizedDescription)")
                } else {
                    let alertController = UIAlertController(title: "Аккаунт удалён", message: "Все данные удалены, аккаунт успешно удалён", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "ToLogin", sender: nil)
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }))
        confirmDeleteAlert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
        present(confirmDeleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            // Преобразуем дату в формат TimeInterval
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            guard let date = dateFormatter.date(from: text) else {
                showAlert(withTitle: "Ошибка", message: "Некорректный формат даты")
                return
            }
            let timestamp = date.timeIntervalSince1970
            
            // Обновляем значение в базе данных Firebase
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            let databaseRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference()
            let userRef = databaseRef.child("users/\(currentUser.uid)")
            userRef.updateChildValues(["date_of_birth": timestamp]) { (error, _) in
                if let error = error {
                    let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Успешно", message: "Дата рождения успешно изменена", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let databaseRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference()
        let userRef = databaseRef.child("users/\(currentUser.uid)")
        
        if let newNickname = changeNicknameText.text, !newNickname.isEmpty {
            // Update nickname in Firebase Realtime Database
            userRef.updateChildValues(["nickname": newNickname]) { (error, _) in
                if let error = error {
                    let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // Update nickname in Firebase Authentication
                    let changeRequest = currentUser.createProfileChangeRequest()
                    changeRequest.displayName = newNickname
                    changeRequest.commitChanges(completion: nil)
                    
                    let alertController = UIAlertController(title: "Успешно", message: "Никнейм успешно изменен", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        if let newEmail = changeEmailText.text, !newEmail.isEmpty, isValidEmail(newEmail) {
            // Update email in Firebase Realtime Database
            userRef.updateChildValues(["email": newEmail]) { (error, _) in
                if let error = error {
                    let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // Update email in Firebase Authentication
                    currentUser.updateEmail(to: newEmail) { (error) in
                        if let error = error {
                            let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: "Успешно", message: "Электронная почта успешно изменена", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        if !aboutMeText.text!.isEmpty {
            // Update "about me" information in Firebase Realtime Database
            userRef.updateChildValues(["about_me": aboutMeText.text!]) { (error, _) in
                if let error = error {
                    let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Успешно", message: "Информация 'О себе' успешно изменена", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        guard let text = dateOfBirthText.text, !text.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите дату рождения")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        guard let date = dateFormatter.date(from: text) else {
            showAlert(withTitle: "Ошибка", message: "Некорректный формат даты")
            return
        }
        let timestamp = date.timeIntervalSince1970        // Update date of birth in Firebase Realtime Database
        userRef.updateChildValues(["date_of_birth": timestamp]) { (error, _) in
            if let error = error {
                let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Успешно", message: "Дата рождения успешно изменена", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    // Function to show alert with title and message
    func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
    // Function to check if an email is valid
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
