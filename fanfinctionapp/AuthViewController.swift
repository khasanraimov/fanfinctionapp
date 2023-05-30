//
//  AuthViewController.swift
//  fanfinctionapp
//
//  Created by mac on 27.05.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AuthViewController: UIViewController {
    
    
    
    @IBOutlet weak var emailOrNicknameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginField: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailOrNicknameField.delegate = self as? UITextFieldDelegate
        passwordField.delegate = self as? UITextFieldDelegate
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
    
    guard let email = emailOrNicknameField.text, !email.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите email адрес")
            return
        }
        
        guard let password = passwordField.text, !password.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите пароль")
            return
        }
        
        // Попытка входа с email
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                self.showAlert(withTitle: "Ошибка", message: error.localizedDescription)
            } else {
                self.showAlert(withTitle: "Успешно", message: "Вы успешно вошли в систему")
                self.performSegue(withIdentifier: "showTabBarSegue", sender: nil)
            }
        }
        
        // Попытка входа с nickname
        let usersRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "users")
        usersRef.queryOrdered(byChild: "nickname").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {
                // Нет пользователя с таким nickname
                return
            }
            
            guard let userData = snapshot.value as? [String:Any],
                let storedEmail = userData["email"] as? String else {
                    // Некорректные данные пользователя
                    return
            }
            
            Auth.auth().signIn(withEmail: storedEmail, password: password, completion: { (authResult, error) in
                if let error = error {
                    self.showAlert(withTitle: "Ошибка", message: error.localizedDescription)
                } else {
                    self.showAlert(withTitle: "Успешно", message: "Вы успешно вошли в систему")
                    self.performSegue(withIdentifier: "showTabBarSegue", sender: nil)
                }
            })
        })
    }
    
    //Функция для отображения сообщения с помощью UIAlertController
    func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}
