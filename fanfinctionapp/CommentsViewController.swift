//
//  CommentsViewController.swift
//  fanfinctionapp
//
//  Created by mac on 11.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var fanfic: Fanfic!
    var commentsRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    

}
class CommentsViewCell: UITableViewCell {
    
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var datECommented: UILabel!
    @IBOutlet weak var textComment: UILabel!
    
    
}
