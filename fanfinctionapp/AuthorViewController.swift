//
//  AuthorViewController.swift
//  fanfinctionapp
//
//  Created by mac on 17.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase

class AuthorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var authorID: String?
    var author: User?
    var avatarURL: String?
    var fanfics = [Fanfic]()
    
    @IBOutlet weak var imageAuthor: UIImageView!
    @IBOutlet weak var nameAuthor: UILabel!
    @IBOutlet weak var aboutAuthor: UILabel!
    @IBOutlet weak var authorFanfics: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageAuthor.layer.cornerRadius = 50
        imageAuthor.clipsToBounds = true
        
        guard let authorID = self.authorID else { return }
        let fanficsRef = Database.database().reference().child("fanfics")
        fanficsRef.queryOrdered(byChild: "authorID").queryEqual(toValue: authorID).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String: Any] {
                    let fanfic = Fanfic(data: data)
                    self.fanfics.append(fanfic!)
                }
            }
            self.authorFanfics.reloadData()
        }
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fanfics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "authorFanficsCell", for: indexPath) as! AuthorFanficsCollectionCell
        let fanfic = fanfics[indexPath.row]
        cell.nameFanfic.text = fanfic.title
        // Также здесь можно установить изображение фанфика, используя ссылку на изображение, если такое есть.
        return cell
    }
    
}

class AuthorFanficsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageFanfic: UIImageView!
    @IBOutlet weak var nameFanfic: UILabel!
    
}
