import UIKit
import Firebase
import FirebaseStorage
class EditViewController: UIViewController {
    @IBOutlet weak var fanficTitleTextField: UITextField!
    @IBOutlet weak var descriptionFanfic: UITextField!
    @IBOutlet weak var contentFanfic: UITextView!
    @IBOutlet weak var imageFanfic: UIImageView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    var fanficImage: UIImage?
    var fanfic: [Fanfic]?
    var fanficCategory: String?
    var onSave: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectFanficImage(_:)))
        imageFanfic.addGestureRecognizer(tapGesture)
        imageFanfic.isUserInteractionEnabled = true
        
        let database = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics")
        guard let fanfic = fanfic?.first else {
            showAlert(withTitle: "Ошибка", message: "Фанфик не найден")
            return
        }
        let fanficRef = database.child(fanfic.key!)

        
        fanficTitleTextField.text = fanfic.title
        descriptionFanfic.text = fanfic.description
        fanficRef.observe(.value, with: { snapshot in
            guard let fanficData = snapshot.value as? [String: Any],
                let fanficText = fanficData["content"] as? String
                else {
                    self.showAlert(withTitle: "Ошибка", message: "Не удалось загрузить текст фанфика")
                    return
            }
            
            // Устанавливаем значение текста фанфика в свойство contentFanfic.text
            self.contentFanfic.text = fanficText
        })
        fanficCategory = fanfic.category
        updateCategoryButton()
        
        // Load fanfic image
        imageFanfic.layer.cornerRadius = 20
        imageFanfic.clipsToBounds = true
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
    
    @IBAction func selectCategory(_ sender: Any) {
        showCategorySelection()
    }
    
    func showCategorySelection() {
        let alert = UIAlertController(title: "Выберите категорию", message: nil, preferredStyle: .actionSheet)
        
        let categories = ["Фантастика", "Фэнтези", "Романтика", "Драма"]
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
    
    func updateCategoryButton() {
        categoryButton.setTitle(fanficCategory, for: .normal)
    }
    
    @objc func selectFanficImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func saveChangesTapped(_ sender: Any) {
        guard let fanfic = fanfic?.first else {
            showAlert(withTitle: "Ошибка", message: "Фанфик не найден")
            return
        }
        
        guard let fanficTitle = fanficTitleTextField.text, !fanficTitle.isEmpty else {
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
        
        guard let fanficCategory = fanficCategory else {
            showAlert(withTitle: "Ошибка", message: "Выберите категорию фанфика")
            return
        }
        
        let fanficsRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics").child(fanfic.key!)
        
        fanficsRef.child("title").setValue(fanficTitle)
        fanficsRef.child("description").setValue(fanficDescription)
        fanficsRef.child("category").setValue(fanficCategory)
        fanficsRef.child("content").setValue(contentFanfic.text)
        
        if let fanficImage = fanficImage, let fanficImageData = fanficImage.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage(url: "gs://fanfiction-4f149.appspot.com").reference().child("fanfic_images/\(String(describing: fanfic.key))")
            storageRef.putData(fanficImageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    self.showAlert(withTitle: "Ошибка", message: "Не удалось загрузить изображение: \(error.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        self.showAlert(withTitle: "Ошибка", message: "Не удалось получить ссылку на изображение: \(error.localizedDescription)")
                        return
                    }
                    
                    fanficsRef.child("imageURL").setValue(url?.absoluteString)
                    self.onSave?()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            fanficsRef.child("imageURL").setValue(nil)
            self.onSave?()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        
//        fanficImage = nil
//        fanficImage = UUID().uuidString
        
        picker.dismiss(animated: true) {
            self.imageFanfic.image = self.fanficImage
        }
    }
}
