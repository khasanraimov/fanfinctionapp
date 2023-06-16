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
    @IBOutlet weak var datePublish: UILabel!
    
    var fanfic: Fanfic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fanficImageView.layer.cornerRadius = 50
        fanficImageView.clipsToBounds = true
        
        fanficTitleLabel.text = fanfic.title
        fanficDescriptionTextView.text = fanfic.description
        if fanfic.authorName != nil {
            authorButton.setTitle(fanfic.authorName,  for: .normal)
        }
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
    
    @IBAction func authorButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ShowAuthorDetails", sender: fanfic.author)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAuthor", let authorVC = segue.destination as? AuthorViewController, let authorID = sender as? String {
            authorVC.authorID = authorID
        } else if segue.identifier == "ShowComments", let commentsVC = segue.destination as? CommentsViewController, let fanfic = sender as? Fanfic {
            commentsVC.fanfic = fanfic
        }
    }
    
}
