//
//  ProfileViewController.swift
//  fanfinctionapp
//
//  Created by mac on 28.05.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fanficCollectionView: UICollectionView!
    
    var fanfics: [Fanfic] = []
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.clipsToBounds = true
        
        fanficCollectionView.dataSource = self
        fanficCollectionView.delegate = self
        fetchFanfics()
        fetchAvatar()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeAvatarImage))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func changeAvatarImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func fetchFanfics() {
        guard let uid = user?.uid else { return }
        
        let fanficsRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics")
        
        fanficsRef.queryOrdered(byChild: "author").queryEqual(toValue: uid).observeSingleEvent(of: .value) { (snapshot) in
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let fanfic = Fanfic(snapshot: snapshot) {
                    self.fanfics.append(fanfic)
                }
            }
            self.fanficCollectionView.reloadData()
        }
    }
    
    func fetchAvatar() {
        guard let uid = user?.uid else { return }
        let storageRef = Storage.storage(url: "gs://fanfiction-4f149.appspot.com").reference().child("avatars/\(uid)")
        
        storageRef.downloadURL { (url, error) in
            guard let url = url else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    self.avatarImageView.image = UIImage(data: data)
                }
                }.resume()
        }
    }
    
    @IBAction func selectAvatarImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func toSettings(_ sender: Any) {
        performSegue(withIdentifier: "ToSettings", sender: nil)
    }
    
    
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fanfics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as? ProfileCollectionViewCell else { return UICollectionViewCell() }
        
        let fanfic = fanfics[indexPath.row]
        cell.configure(with: fanfic)
        
        cell.fanficImageView.layer.cornerRadius = 15
        cell.fanficImageView.clipsToBounds = true
        
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fanficVC = storyboard.instantiateViewController(withIdentifier: "FanficDetailViewController") as! FanficDetailViewController
        fanficVC.fanfic = fanfics[indexPath.row]
        navigationController?.pushViewController(fanficVC, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    @IBAction func selectAvatarImage(_ sender: Any) {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.sourceType = .photoLibrary
//        imagePickerController.allowsEditing = true
//        
//        present(imagePickerController, animated: true, completion: nil)
//    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            avatarImageView.image = pickedImage
            
            // Save the image to Firebase Storage and update the user's avatarURL in Firebase Database
            guard let uid = user?.uid, let imageData = pickedImage.jpegData(compressionQuality: 0.5) else { return }
            let storageRef = Storage.storage(url: "gs://fanfiction-4f149.appspot.com").reference().child("avatars/\(uid)")
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading Avatar Image: \(error.localizedDescription)")
                } else {
                    print("Avatar Image uploaded successfully")
                    storageRef.downloadURL { (url, error) in
                        guard let url = url else { return }
                        let imageURLString = url.absoluteString
                        let userRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "users/\(uid)")
                        userRef.child("avatarURL").setValue(imageURLString)
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

class ProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fanficImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with fanfic: Fanfic) {
        titleLabel.text = fanfic.title
        
        if let imageURLString = fanfic.imageURL,
            let imageURL = URL(string: imageURLString) {
            URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.fanficImageView.image = UIImage(data: data)
                    }
                }
                }.resume()
        }
    }
}
