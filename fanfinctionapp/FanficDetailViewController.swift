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
    @IBOutlet weak var toReading: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeButtonCount: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentCount: UILabel!
    
    var fanfic: Fanfic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fanficImageView.layer.cornerRadius = 50
        fanficImageView.clipsToBounds = true
        toReading.layer.cornerRadius = 15
        toReading.clipsToBounds = true
        
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
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        datePublish.text = "Опубликовано: \(dateFormatter.string(from: fanfic.publicationDate))"
        likeButtonCount.text = "\(fanfic.likeCount)"
}
    
    @IBAction func authorButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ShowAuthorDetails", sender: fanfic.author)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toReadingButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ToRead", sender: fanfic)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAuthor", let authorVC = segue.destination as? AuthorViewController, let authorID = sender as? String {
            authorVC.authorID = fanfic.author
        } else if segue.identifier == "ToRead", let storyVC = segue.destination as? ReaderViewController, let fanfic = sender as? Fanfic {
            storyVC.fanfic = fanfic
        }
    }
    
    
    @IBAction func likeButtonTapped(_ sender: Any) {
       
    }
    
    func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}
