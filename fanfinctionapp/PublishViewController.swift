//
//  PublishViewController.swift
//  fanfinctionapp
//
//  Created by mac on 05.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class PublishViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fanfics: [Fanfic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadFanfics()
    }
    func loadFanfics() {
        let fanficsRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics")
        
        fanficsRef.observeSingleEvent(of: .value, with: { snapshot in
            var fanfics: [Fanfic] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let fanfic = Fanfic(snapshot: snapshot) {
                    fanfics.append(fanfic)
                }
            }
            
            self.fanfics = fanfics
            self.collectionView.reloadData()
        })
    }
}

extension PublishViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fanfics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FanficCell", for: indexPath) as! FanficCollectionViewCell
        let fanfic = fanfics[indexPath.item]
        cell.titleLabel.text = fanfic.title
        cell.imageView.layer.cornerRadius = 15
        cell.imageView.clipsToBounds = true
        
        if let imageURLString = fanfic.imageURL, let imageURL = URL(string: imageURLString) {
            let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
            }
            task.resume()
        } else {
            cell.imageView.image = nil
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fanfic = fanfics[indexPath.item]
        performSegue(withIdentifier: "showFanficDetail", sender: fanfic)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFanficDetail", let fanfic = sender as? Fanfic {
            let fanficDetailVC = segue.destination as! FanficDetailViewController
            fanficDetailVC.fanfic = fanfic
        }
    }
}

class FanficCollectionViewCell: UICollectionViewCell{
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with fanfic: Fanfic) {
        titleLabel.text = fanfic.title
        
        if let imageURLString = fanfic.imageURL, let imageURL = URL(string: imageURLString) {
            let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        } else {
            imageView.image = nil
        }
    }
    
}
