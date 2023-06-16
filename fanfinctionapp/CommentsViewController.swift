//
//  CommentsViewController.swift
//  fanfinctionapp
//
//  Created by mac on 11.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var fanfic: Fanfic?

    override func viewDidLoad() {
        super.viewDidLoad()
        


    }

}
class CommentsViewCell: UITableViewCell {
    
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var datECommented: UILabel!
    @IBOutlet weak var textComment: UILabel!
    
    
}
