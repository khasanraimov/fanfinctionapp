import UIKit
import Firebase
import FirebaseStorage
class CreatingViewController: UIViewController {
    @IBOutlet weak var fanficTitleTextField: UITextField!
    @IBOutlet weak var descriptionFanfic: UITextField!
    @IBOutlet weak var contentFanfic: UITextView!
    @IBOutlet weak var imageFanfic: UIImageView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var saveAndPublish: UIButton!
    var fanficImage: UIImage?
    var fanficImageURL: String?
    var categories = ["Фантастика", "Фэнтези", "Романтика", "Драма"]
    var fanficCategory: String?
    var fanfic: Fanfic?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageFanfic.layer.cornerRadius = 20
        imageFanfic.clipsToBounds = true
        fanficTitleTextField.delegate = self
        descriptionFanfic.delegate = self
        contentFanfic.delegate = self as? UITextViewDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectFanficImage))
        imageFanfic.isUserInteractionEnabled = true
        imageFanfic.addGestureRecognizer(tapGesture)
        
        if let fanfic = fanfic {
            fanficTitleTextField.text = fanfic.title
            descriptionFanfic.text = fanfic.description
            contentFanfic.text = fanfic.text
            fanficCategory = fanfic.category
            updateCategoryButton()
            fanficImageURL = fanfic.imageURL
            if let imageURLString = fanficImageURL {
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
        categoryButton.setTitle(fanficCategory, for: .normal)
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let fanficTitle = fanficTitleTextField.text, !fanficTitle.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите название фанфика")
            return
        }
        
        guard let fanficDescription = descriptionFanfic.text, !fanficDescription.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите описание фанфика")
            return
        }
        
        guard let fanficImage = fanficImage else {
            showAlert(withTitle: "Ошибка", message: "Выберите обложку фанфика")
            return
        }
        
        guard let fanficImageData = fanficImage.jpegData(compressionQuality: 0.5) else {
            showAlert(withTitle: "Ошибка", message: "Ошибка при обработке изображения")
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
        guard let user = Auth.auth().currentUser else {
            showAlert(withTitle: "Ошибка", message: "Пользователь не авторизован")
            return
        }
        // Получаем nickname пользователя из базы данных Firebase
        let userID = user.uid
        let usersRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "users")
        usersRef.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let userData = snapshot.value as? [String:Any], let nickname = userData["nickname"] as? String {
                // Найдено nickname пользователя, сохраняем его вместе с фанфиком
                let fanficRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics").childByAutoId()
                
                fanficRef.child("key").childByAutoId()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let publicationDate = dateFormatter.string(from: Date())
                fanficRef.child("publicationDate").setValue(publicationDate) 
                fanficRef.child("title").setValue(fanficTitle)
                fanficRef.child("description").setValue(fanficDescription)
                fanficRef.child("author").setValue(user.uid)
                fanficRef.child("authorName").setValue(nickname) // Сохраняем nickname пользователя
                fanficRef.child("content").setValue(self.contentFanfic.text)
                fanficRef.child("category").setValue(fanficCategory)
                fanficRef.child("likeCount").setValue(0)
                
                let storageRef = Storage.storage(url: "gs://fanfiction-4f149.appspot.com").reference().child("fanfic_images/\(fanficRef.key!)")
                
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
                            fanficRef.child("imageURL").setValue(imageURLString)
                            self.showAlert(withTitle: "Успешно", message: "Фанфик успешно создан!")
                            let navController = self.navigationController
                            navController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                // Не найден nickname пользователя, выводим сообщение об ошибке
                self.showAlert(withTitle: "Ошибка", message: "Nickname пользователя не найден")
            }
        }
    }
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension CreatingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension CreatingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            fanficImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            fanficImage = originalImage
        }
        imageFanfic.image = fanficImage
        dismiss(animated: true, completion: nil)
    }
}
