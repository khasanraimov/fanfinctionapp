//
//  EditViewController.swift
//  fanfinctionapp
//
//  Created by mac on 02.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class EditViewController: UIViewController {
    
    @IBOutlet weak var imageFanfic: UIImageView!
    @IBOutlet weak var titleFanfic: UITextField!
    @IBOutlet weak var descriptionFanfic: UITextField!
    @IBOutlet weak var categoryFanfic: UIButton!
    @IBOutlet weak var contentFanfic: UITextView!
    @IBOutlet weak var saveChanges: UIButton!
    
    var fanfic: [Fanfic] = []
    var onSave: (() -> Void)?
    
    
    var fanficImageURL: String?
    var fanficImage: UIImage?
    var categories = ["Фантастика", "Фэнтези", "Романтика", "Драма"]
    var fanficCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleFanfic.delegate = self
        descriptionFanfic.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectFanficImage))
        imageFanfic.isUserInteractionEnabled = true
        imageFanfic.addGestureRecognizer(tapGesture)
        print(fanfic)

        
        // Заполнение полей данными фанфика
        if let fanfic = fanfic.first {
            titleFanfic.text = fanfic.title
            descriptionFanfic.text = fanfic.description
            contentFanfic.text = fanfic.text
            fanficCategory = fanfic.category
            updateCategoryButton()
            
            // Загрузка изображения фанфика
            if let imageURLString = fanfic.imageURL {
                let imageURL = URL(string: imageURLString)!
                let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.imageFanfic.image = UIImage(data: data)
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    @objc func selectFanficImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func showCategorySelection() {
        let alert = UIAlertController(title: "Выберите категорию", message: nil, preferredStyle: .actionSheet)
        
        categories.forEach { category in
            let action = UIAlertAction(title: category, style: .default) { _ in
                self.fanficCategory = category
                self.updateCategoryButton()
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectCategory(_ sender: Any) {
        showCategorySelection()
    }
    
    func updateCategoryButton() {
        categoryFanfic.setTitle(fanficCategory, for: .normal)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let fanficTitle = titleFanfic.text, !fanficTitle.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите название фанфика")
            return
        }
        guard let fanficDescription = descriptionFanfic.text, !fanficDescription.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите описание фанфика")
            return
        }
        guard contentFanfic.text != nil else {
            showAlert(withTitle: "Ошибка", message: "Напишите фанфик")
            return
        }
        guard fanficImageURL != nil else {
            showAlert(withTitle: "Ошибка", message: "Выберите обложку фанфика")
            return
        }
        guard fanficCategory != nil else {
            showAlert(withTitle: "Ошибка", message: "Выберите категорию фанфика")
            return
        }
        
        guard let fanfic = self.fanfic.first else {
            showAlert(withTitle: "Ошибка", message: "Фанфик не найден")
            return
        }
        
        guard let fanficImage = fanficImage, let fanficImageData = fanficImage.jpegData(compressionQuality: 0.5) else {
            showAlert(withTitle: "Ошибка", message: "Ошибка при обработке изображения")
            return
        }
        
        print("Selected image in saveButtonTapped: \(fanficImage)")
        
        let fanficRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics/\(fanfic.key ?? "")")
        fanficRef.child("imageURL").setValue(self.fanficImageURL)
        let storageRef = Storage.storage().reference().child("fanfic_images/\(fanficRef.key!)")
        storageRef.putData(fanficImageData, metadata: nil) { (metadata, error) in
            if let error = error {
                self.showAlert(withTitle: "Ошибка", message: error.localizedDescription)
            } else {
                storageRef.downloadURL { (url, error) in
                    guard let url = url else {
                        self.showAlert(withTitle: "Ошибка", message: "Ошибка при загрузке изображения")
                        return
                    }
                    
                    let imageURLString = url.absoluteString
                    self.fanficImageURL = imageURLString
                    fanficRef.child("imageURL").setValue(self.fanficImageURL)
                    
                    self.showAlert(withTitle: "Успешно", message: "Фанфик успешно обновлен!")
                    self.dismiss(animated: true, completion: {
                        self.onSave?()
                    })
                }
            }
        }
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension EditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            fanficImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            fanficImage = originalImage
        }
        
        fanficImageURL = nil
        fanficImageURL = UUID().uuidString
        
        picker.dismiss(animated: true) {
            self.imageFanfic.image = self.fanficImage
        }
    }
}
