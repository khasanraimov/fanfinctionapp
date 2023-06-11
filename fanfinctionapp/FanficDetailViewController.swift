//
//  FanficDetailViewController.swift
//  fanfinctionapp
//
//  Created by mac on 31.05.2023.
//  Copyright © 2023 mac. All rights reserved.
//
import UIKit
import Firebase

class FanficDetailViewController: UIViewController {
    
    @IBOutlet weak var fanficImageView: UIImageView!
    @IBOutlet weak var fanficTitleLabel: UILabel!
    @IBOutlet weak var fanficDescriptionTextView: UILabel!
    
    @IBOutlet weak var authorButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var repostButton: UIButton!
    @IBOutlet weak var repostCountLabel: UILabel!
    
    var fanfic: Fanfic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fanficTitleLabel.text = fanfic.title
        fanficDescriptionTextView.text = fanfic.description
        
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
        
        authorButton.setTitle(fanfic.authorName, for: .normal)
        likeCountLabel.text = "\(fanfic.likesCount)"
        commentCountLabel.text = "\(fanfic.commentsCount)"
//        repostCountLabel.text = "\(fanfic.repostsCount)"
    }
    
    @IBAction func authorButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ShowAuthorDetails", sender: fanfic.author)
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        increaseLikeCount()
    }
    
    func increaseLikeCount() {
        let ref = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics/\(String(describing: fanfic?.key))/likesCount")
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            if var likesCount = currentData.value as? Int {
                likesCount += 1
                currentData.value = likesCount
                self.fanfic.likesCount = likesCount
                return .success(withValue: currentData)
            } else {
                return .abort()
            }
        }) { (error, _, _) in
            if let error = error {
                print("Error increasing like count: \(error.localizedDescription)")
            } else {
                self.likeCountLabel.text = "\(self.fanfic.likesCount)"
            }
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ShowComments", sender: fanfic)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAuthorDetails", let authorVC = segue.destination as? AuthorProfileViewController, let authorID = sender as? String {
            authorVC.authorID = authorID
        } else if segue.identifier == "ShowComments", let commentsVC = segue.destination as? CommentsViewController, let fanfic = sender as? Fanfic {
            commentsVC.fanfic = fanfic
        }
    }
    
    @IBAction func repostButtonTapped(_ sender: Any) {
        increaseRepostCount()
    }
    
    func increaseRepostCount() {
        let ref = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics/\(String(describing: fanfic?.key))/repostsCount")
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            if var repostsCount = currentData.value as? Int {
                repostsCount += 1
                currentData.value = repostsCount
                self.fanfic?.repostCount = repostsCount // Обновлено, добавили вопросительный знак после fanfic
                return .success(withValue: currentData)
            } else {
                return .abort()
            }
        }) { (error, _, _) in
            if let error = error {
                print("Error increasing repost count: \(error.localizedDescription)")
            } else {
                if let fanfic = self.fanfic {
                    self.repostCountLabel.text = "\(fanfic.repostCount)"
                }
            }
        }
    }
    
}
