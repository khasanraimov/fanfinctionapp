//import UIKit
//import Firebase
//import FirebaseStorage
//
//class CreatingViewController: UIViewController {
//    @IBOutlet weak var fanficTitleTextField: UITextField!
//    @IBOutlet weak var descriptionFanfic: UITextField!
//
//    @IBOutlet weak var chatAI: UIButton!
//    @IBOutlet weak var saveAndPublish: UIButton!
//    @IBOutlet weak var contentFanfic: UITextView!
//    @IBOutlet weak var imageFanfic: UIImageView!
//    var fanficImage: UIImage?
//    var fanficImageURL: String?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        fanficTitleTextField.delegate = self
//        descriptionFanfic.delegate = self
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectFanficImage))
//        imageFanfic.isUserInteractionEnabled = true
//        imageFanfic.addGestureRecognizer(tapGesture)
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
//        guard let fanficDescription = descriptionFanfic.text, !fanficDescription.isEmpty else {
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
//        guard contentFanfic.text != nil else {
//            showAlert(withTitle: "Ошибка", message: "Напишите фанфик")
//            return
//        }
//
//        let fanficRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics").childByAutoId()
//
//        fanficRef.child("title").setValue(fanficTitle)
//        fanficRef.child("description").setValue(fanficDescription)
//        fanficRef.child("author").setValue(Auth.auth().currentUser?.uid ?? "")
//        fanficRef.child("content").setValue(contentFanfic.text)
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
//                    self.fanficImageURL = imageURLString
//                    print(self.fanficImageURL)
//                    fanficRef.child("imageURL").setValue(self.fanficImageURL)
//                    self.showAlert(withTitle: "Успешно", message: "Фанфик успешно создан!")
//                    let navController = self.navigationController
//                    navController?.popViewController(animated: true)
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
//
//
//}
//extension CreatingViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}
//extension CreatingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            fanficImage = editedImage
//        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            fanficImage = originalImage
//        }
//        imageFanfic.image = fanficImage
//        dismiss(animated: true, completion: nil)
//    }
//}
//
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
        fanficTitleTextField.delegate = self
        descriptionFanfic.delegate = self
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

        let fanficRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics").childByAutoId()
        
        fanficRef.child("key").childByAutoId()

        fanficRef.child("title").setValue(fanficTitle)
        fanficRef.child("description").setValue(fanficDescription)
        fanficRef.child("author").setValue(Auth.auth().currentUser?.uid ?? "")
        fanficRef.child("content").setValue(contentFanfic.text)
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
                    self.fanficImageURL = imageURLString
                    fanficRef.child("imageURL").setValue(self.fanficImageURL)
                    self.showAlert(withTitle: "Успешно", message: "Фанфик успешно создан!")
                    let navController = self.navigationController
                    navController?.popViewController(animated: true)
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

struct Fanfic: Decodable {
    
    var key: String?
    var title: String?
    var description: String?
    var imageURL: String?
    var author: String?
    var text: String?
    var category: String?
    var likesCount: Int
    var commentsCount: Int
    var repostCount: Int
    var rating: Double
    var authorName: String?
    var likedBy: [String]
    
    init?(data: [String:Any]?) {
        guard let data = data else { return nil }
        key = data["key"] as? String
        title = data["title"] as? String
        description = data["description"] as? String
        imageURL = data["imageURL"] as? String
        author = data["author"] as? String
        text = data["text"] as? String
        category = data["category"] as? String
        likesCount = data["likes_count"] as? Int ?? 0
        commentsCount = data["comments_count"] as? Int ?? 0
        repostCount = data["repost_count"] as? Int ?? 0
        rating = data["rating"] as? Double ?? 0.0
        authorName = data["authorName"] as? String
        likedBy = data["likedBy"] as? [String] ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case description
        case imageURL = "image_url"
        case author
        case text
        case category
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case repostCount = "repost_count"
        case rating
        case authorName
        case likedBy
    }
    
    init(dict: [String: Any]) {
        key = dict["key"] as? String
        title = dict["title"] as? String
        description = dict["description"] as? String
        imageURL = dict["image_url"] as? String
        author = dict["author"] as? String
        text = dict["text"] as? String
        category = dict["category"] as? String
        likesCount = dict["likes_count"] as? Int ?? 0
        commentsCount = dict["comments_count"] as? Int ?? 0
        repostCount = dict["repost_count"] as? Int ?? 0
        rating = dict["rating"] as? Double ?? 0.0
        authorName = dict["author_name"] as? String
        likedBy = dict["liked_by"] as? [String] ?? []
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        commentsCount = try container.decode(Int.self, forKey: .commentsCount)
        repostCount = try container.decode(Int.self, forKey: .repostCount)
        rating = try container.decode(Double.self, forKey: .rating)
        authorName = try container.decode(String.self, forKey: .authorName)
        likedBy = try container.decodeIfPresent([String].self, forKey: .likedBy) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(key, forKey: .key)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(author, forKey: .author)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(likesCount, forKey: .likesCount)
        try container.encode(commentsCount, forKey: .commentsCount)
        try container.encode(repostCount, forKey: .repostCount)
        try container.encode(rating, forKey: .rating)
        try container.encodeIfPresent(key, forKey: .authorName)
        try container.encode(likedBy, forKey: .likedBy)
    }
    
    init?(snapshot: DataSnapshot) {
        guard let fanficDict = snapshot.value as? [String: Any] else {
            return nil
        }
        key = fanficDict["key"] as? String
        title = fanficDict["title"] as? String
        description = fanficDict["description"] as? String
        imageURL = fanficDict["imageURL"] as? String
        author = fanficDict["author"] as? String
        text = fanficDict["text"] as? String
        category = fanficDict["category"] as? String
        likesCount = fanficDict["likes_count"] as? Int ?? 0
        commentsCount = fanficDict["comments_count"] as? Int ?? 0
        repostCount = fanficDict["repost_count"] as? Int ?? 0
        rating = fanficDict["rating"] as? Double ?? 0.0
        authorName = fanficDict["authorName"] as? String
        likedBy = fanficDict["likedBy"] as? [String] ?? []
    
    }
    
    mutating func like(byUser userID: String) {
        if !likedBy.contains(userID) {
            likedBy.append(userID)
            likesCount += 1
        }
    }
    
    mutating func unlike(byUser userID: String) {
        if let index = likedBy.firstIndex(of: userID) {
            likedBy.remove(at: index)
            likesCount -= 1
        }
    }
}

extension Fanfic: Equatable {
    
    static func == (lhs: Fanfic, rhs: Fanfic) -> Bool {
        return lhs.title == rhs.title && lhs.description == rhs.description && lhs.imageURL == rhs.imageURL && lhs.author == rhs.author && lhs.text == rhs.text && lhs.category == rhs.category && lhs.likesCount == rhs.likesCount && lhs.commentsCount == rhs.commentsCount && lhs.repostCount == rhs.repostCount && lhs.rating == rhs.rating && lhs.authorName == rhs.authorName
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
