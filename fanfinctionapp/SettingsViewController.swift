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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
}
