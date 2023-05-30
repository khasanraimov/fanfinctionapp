import UIKit
import Firebase
import FirebaseStorage
class CreatingViewController: UIViewController {
    @IBOutlet weak var fanficTitleTextField: UITextField!
    @IBOutlet weak var fanficDescriptionTextView: UITextView!
    @IBOutlet weak var fanficImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var fanficImage: UIImage?
    var fanficImageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fanficTitleTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectFanficImage))
        fanficImageView.isUserInteractionEnabled = true
        fanficImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func selectFanficImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let fanficTitle = fanficTitleTextField.text, !fanficTitle.isEmpty else {
            showAlert(withTitle: "Ошибка", message: "Введите название фанфика")
            return
        }
        
        guard let fanficDescription = fanficDescriptionTextView.text, !fanficDescription.isEmpty else {
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
        
        let fanficRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics").childByAutoId()
        
        fanficRef.child("title").setValue(fanficTitle)
        fanficRef.child("description").setValue(fanficDescription)
        fanficRef.child("author").setValue(Auth.auth().currentUser?.uid ?? "")
        
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
                    self.fanficImageURL = imageURLString
                    fanficRef.child("imageURL").setValue(imageURLString)
                    self.performSegue(withIdentifier: "goToWritingVC", sender: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writingVC = segue.destination as? WrittingViewController {
            writingVC.fanficTitle = fanficTitleTextField.text
            writingVC.fanficDescription = fanficDescriptionTextView.text
            writingVC.fanficImageURL = fanficImageURL
        }
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
        fanficImageView.image = fanficImage
        dismiss(animated: true, completion: nil)
    }
}



//import UIKit
//import Firebase
//import FirebaseStorage
//
//class CreatingViewController: UIViewController {
//
//    @IBOutlet weak var fanficTitleTextField: UITextField!
//    @IBOutlet weak var fanficDescriptionTextView: UITextView!
//    @IBOutlet weak var fanficImageView: UIImageView!
//    @IBOutlet weak var saveButton: UIButton!
//
//    var fanficImage: UIImage?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        fanficTitleTextField.delegate = self
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectFanficImage))
//        fanficImageView.isUserInteractionEnabled = true
//        fanficImageView.addGestureRecognizer(tapGesture)
//    }
//
//    @objc func selectFanficImage() {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.allowsEditing = true
//        imagePickerController.sourceType = .photoLibrary
//        present(imagePickerController, animated: true, completion: nil)
//    }
//
//    @IBAction func saveButtonTapped(_ sender: Any) {
//        guard let fanficTitle = fanficTitleTextField.text, !fanficTitle.isEmpty else {
//            showAlert(withTitle: "Ошибка", message: "Введите название фанфика")
//            return
//        }
//
//        guard let fanficDescription = fanficDescriptionTextView.text, !fanficDescription.isEmpty else {
//            showAlert(withTitle: "Ошибка", message: "Введите описание фанфика")
//            return
//        }
//
//        guard let fanficImage = fanficImage else {
//            showAlert(withTitle: "Ошибка", message: "Выберите обложку фанфика")
//            return
//        }
//
//        guard let fanficImageData = fanficImage.jpegData(compressionQuality: 0.5) else {
//            showAlert(withTitle: "Ошибка", message: "Ошибка при обработке изображения")
//            return
//        }
//
//        let fanficRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics").childByAutoId()
//
//        fanficRef.child("title").setValue(fanficTitle)
//        fanficRef.child("description").setValue(fanficDescription)
//        fanficRef.child("author").setValue(Auth.auth().currentUser?.uid ?? "")
//
//        let storageRef = Storage.storage(url: "gs://fanfiction-4f149.appspot.com").reference().child("fanfic_images/\(fanficRef.key!)")
//
//        storageRef.putData(fanficImageData, metadata: nil) { (metadata, error) in
//            if let error = error {
//                self.showAlert(withTitle: "Ошибка", message: error.localizedDescription)
//            } else {
//                storageRef.downloadURL { (url, error) in
//                    guard let url = url else {
//                        self.showAlert(withTitle: "Ошибка", message: "Ошибка при загрузке изображения")
//                        return
//                    }
//                    let imageURLString = url.absoluteString
//                    fanficRef.child("imageURL").setValue(imageURLString)
//                    self.showAlert(withTitle: "Успешно", message: "Фанфик успешно добавлен")
//                }
//            }
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
//extension CreatingViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}
//
//extension CreatingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            fanficImage = editedImage
//        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            fanficImage = originalImage
//        }
//        fanficImageView.image = fanficImage
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//struct Fanfic {
//    var title: String?
//    var description: String?
//    var imageURL: String?
//    var author: String?
//    var text: String?
//
//    init?(snapshot: DataSnapshot) {
//        guard let fanficDict = snapshot.value as? [String: Any] else {
//            return nil
//        }
//        title = fanficDict["title"] as? String
//        description = fanficDict["description"] as? String
//        imageURL = fanficDict["imageURL"] as? String
//        author = fanficDict["author"] as? String
//        text = fanficDict["text"] as? String
//    }
//}
//extension Fanfic: Equatable {
//    static func == (lhs: Fanfic, rhs: Fanfic) -> Bool {
//        return lhs.title == rhs.title && lhs.description == rhs.description && lhs.imageURL == rhs.imageURL && lhs.author == rhs.author && lhs.text == rhs.text
//    }
//}


//
//import UIKit
//import Firebase
//import FirebaseDatabase
//import FirebaseStorage
//
//class CreatingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    @IBOutlet weak var titleOfFanficField: UITextField!
//    @IBOutlet weak var imageOfFanfic: UIImageView!
//    @IBOutlet weak var addImageOfFacficButton: UIButton!
//    @IBOutlet weak var goToCreateFanfic: UIButton!
//
//    let imagePicker = UIImagePickerController()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//    }
//
//    @IBAction func addImageOfFacficButtonTapped(_ sender: Any) {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        let actionSheet = UIAlertController(title: "Выберите картинку", message: nil, preferredStyle: .actionSheet)
//
//        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
//        actionSheet.addAction(UIAlertAction(title: "Сделать фотографию", style: .default, handler: { (action: UIAlertAction) in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                imagePickerController.sourceType = .camera
//                self.present(imagePickerController, animated: true, completion: nil)
//            }
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Выбрать из библиотеки", style: .default, handler: { (action: UIAlertAction) in
//            imagePickerController.sourceType = .photoLibrary
//            self.present(imagePickerController, animated: true, completion: nil)
//        }))
//        present(actionSheet, animated: true, completion: nil)
//    }
//
//    @IBAction func goToCreateFanficTapped(_ sender: Any) {
//        guard let currentUser = Auth.auth().currentUser
//            else {
//                showAlert(withTitle: "Ошибка", message: "Ошибка авторизации")
//                return
//
//        }
//
//        let userId = currentUser.uid
//        let databaseRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference()
//
//        var fanficData = [
//            "title": titleOfFanficField.text!,
//            "authorId": userId
//            ] as [String : Any]
//
//        if let imageData = imageOfFanfic.image?.jpegData(compressionQuality: 0.5) {
//            let storageRef = Storage.storage(url: "gs://fanfiction-4f149.appspot.com").reference().child("user_images").child(userId).child("\(UUID().uuidString).jpg")
//
//            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
//                if let error = error {
//                    print(error)
//                    return
//                }
//
//                storageRef.downloadURL { (url, error) in
//                    if let error = error {
//                        print(error)
//                        return
//                    }
//
//                    if let imageUrl = url?.absoluteString {
//                        fanficData["imageUrl"] = imageUrl // Сохраняем URL изображения в данных о фанфике
//
//                        let fanficRef = databaseRef.child("drafts").child(userId).childByAutoId() // Сохраняем черновик в "drafts"
//                        fanficRef.setValue(fanficData) { (error, ref) in
//                            if let error = error {
//                                self.showAlert(withTitle: "Ошибка", message: error.localizedDescription)
//                            } else {
//                                self.performSegue(withIdentifier: "toCreateFanfic", sender: nil)
//                            }
//                        }
//                    }
//                }
//            }
//        } else {
//            let fanficRef = databaseRef.child("drafts").child(userId).childByAutoId() // Сохраняем черновик в "drafts"
//            fanficRef.setValue(fanficData) { (error, ref) in
//                if let error = error {
//                    self.showAlert(withTitle: "Ошибка", message: error.localizedDescription)
//                } else {
//                    self.performSegue(withIdentifier: "toCreateFanfic", sender: nil)
//                }
//            }
//        }
//    }
//
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            imageOfFanfic.image = image
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    func showAlert(withTitle title: String, message: String) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "ОК", style: .default)
//            alert.addAction(okAction)
//            self.present(alert, animated: true)
//        }
//    }
//}


//import UIKit
//
//class CreatingViewController: UIViewController {
//
//    @IBOutlet weak var fanficTextName: UITextField!
//    @IBOutlet weak var fanficImage: UIImageView!
//    var selectedImage: UIImage?
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toCreateFanfic" {
//            let destinationVC = segue.destination as! WrittingViewController
//            destinationVC.fanficName = fanficTextName.text ?? ""
//            destinationVC.fanficImage = selectedImage
//        }
//    }
//
//    @IBAction func selectTapped(_ sender: Any) {
//    let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.sourceType = .photoLibrary
//        present(imagePickerController, animated: true, completion: nil)
//    }
//
//    @IBAction func proceedTapped(_ sender: Any) {
//        guard let fanficName = fanficTextName.text, !fanficName.isEmpty else {
//            showAlert(withTitle: "Ошибка", message: "Введите название фанфика")
//            return
//        }
//
//        guard selectedImage != nil else {
//            showAlert(withTitle: "Ошибка", message: "Выберите изображение фанфика")
//            return
//        }
//
//        performSegue(withIdentifier: "createFanficStep2Segue", sender: nil)
//    }
//
//}
//
//extension CreatingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let selectedImageFromPicker = info[.originalImage] as? UIImage {
//            selectedImage = selectedImageFromPicker
//            fanficImage.image = selectedImageFromPicker
//        }
//
//        dismiss(animated: true, completion: nil)
//    }
//
//}
//
//extension CreatingViewController {
//
//    // Функция для отображения сообщения с помощью UIAlertController
//    func showAlert(withTitle title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "ОК", style: .default)
//        alert.addAction(okAction)
//        present(alert, animated: true)
//    }
//
//}
