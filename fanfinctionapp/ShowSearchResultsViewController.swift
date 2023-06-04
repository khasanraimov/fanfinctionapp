//
//  ShowSearchResultsViewController.swift
//  fanfinctionapp
//
//  Created by mac on 03.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase

class ShowSearchResultsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fanficCategory: String!
    var fanfics: [Fanfic]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadFanfics()
    }
    
    func loadFanfics() {
        let ref = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics")
        ref.queryOrdered(byChild: "category").queryEqual(toValue: fanficCategory).observeSingleEvent(of: .value) { (snapshot) in
            var fanficList = [Fanfic]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let fanfic = Fanfic(snapshot: snapshot) {
                    fanficList.append(fanfic)
                }
            }
            self.fanfics = fanficList
            // Add print statement to verify fanfics are not nil
            print(self.fanfics)
            self.collectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFanficDetails", let fanficVC = segue.destination as? FanficDetailViewController,
            let fanfic = sender as? Fanfic {
            fanficVC.fanfic = fanfic
        }
    }
    
}

extension ShowSearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fanfics = fanfics {
            return fanfics.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FanficCell", for: indexPath) as! FanficCell
        
        let fanfic = fanfics[indexPath.row]
        
        cell.configure(with: fanfic)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fanfic = fanfics[indexPath.row]
        performSegue(withIdentifier: "ShowFanficDetails", sender: fanfic)
    }
    
}

extension ShowSearchResultsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 2
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
    
}

class FanficCell: UICollectionViewCell {
    
    @IBOutlet weak var fanficImageView: UIImageView!
    @IBOutlet weak var fanficTitleLabel: UILabel!
    
    func configure(with fanfic: Fanfic) {
        fanficTitleLabel.text = fanfic.title
        if let imageURLString = fanfic.imageURL {
            let imageURL = URL(string: imageURLString)!
            let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.fanficImageView.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        }
    }
    
}
