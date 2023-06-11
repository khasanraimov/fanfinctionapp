//
//  RegViewController.swift
//  fanfinctionapp
//
//  Created by mac on 26.05.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RegViewController: UIViewController {
    
    @IBOutlet weak var nickNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var regButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self as? UITextFieldDelegate
        passwordField.delegate = self as? UITextFieldDelegate
        nickNameField.delegate = self as? UITextFieldDelegate
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func regButtonTapped(_ sender: Any) {
        
        // Проверяем, чтобы все поля были заполнены
        guard let nickname = nickNameField.text, !nickname.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите nickname")
            return
        }
        
        guard let email = emailField.text, !email.isEmpty, isValidEmail(email) else {
            showAlert(withTitle: "Ошибка", message: "Введите корректный адрес электронной почты")
            return
        }
        
        guard let password = passwordField.text, !password.isEmpty, password.count >= 8 else {
            showAlert(withTitle: "Ошибка", message: "Пароль должен содержать минимум 8 символов")
            return
        }
        
        // Проверяем, чтобы email был уникальным
        Auth.auth().fetchSignInMethods(forEmail: email) { (method, error) in
            if let error = error {
                self.showAlert(withTitle: "Ошибка", message: error.localizedDescription)
            } else if let methods = method, methods.count > 0 {
                self.showAlert(withTitle: "Ошибка", message: "Пользователь с таким email уже зарегистрирован")
            } else {
                // email уникальный, продолжаем регистрацию
                let usersRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "users")
                usersRef.queryOrdered(byChild: "nickname").queryEqual(toValue: nickname).observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        self.showAlert(withTitle: "Ошибка", message: "Пользователь с таким nickname уже существует")
                    } else {
                        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                            guard error == nil, let result = authResult else {
                                self.showAlert(withTitle: "Ошибка", message: error?.localizedDescription ?? "Неизвестная ошибка")
                                return
                            }
                            
                            // User registration successful, save user information
                            let userData = [
                                "email": email,
                                "nickname": nickname
                            ]
                            
                            // Save user to Firebase Realtime Database
                            let databaseRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "users").child(result.user.uid)
                            databaseRef.setValue(userData) { (error, ref) in
                                if error != nil {
                                    self.showAlert(withTitle: "Ошибка", message: error?.localizedDescription ?? "Неизвестная ошибка")
                                } else {
                                    self.showAlert(withTitle: "Успешно", message: "Вы успешно зарегистрировались")
                                    self.performSegue(withIdentifier: "showTabBarSegue", sender: nil)
                                }
                            }
                            
                            // Send verification email
                            result.user.sendEmailVerification { (error) in
                                if let error = error {
                                    self.showAlert(withTitle: "Ошибка", message: error.localizedDescription)
                                }
                            }
                        }
                    }
                })
            }
        }
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
    
    // Функция для проверки корректности адреса электронной почты
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

