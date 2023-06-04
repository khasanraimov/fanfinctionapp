//
//  FanficDetailViewController.swift
//  fanfinctionapp
//
//  Created by mac on 31.05.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit

class FanficDetailViewController: UIViewController {
    
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var goToRead: UIButton!
    
    @IBOutlet weak var goToProfile: UIButton!
    @IBOutlet weak var descriptionOfFanfic: UITextView!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var repostCount: UILabel!
    
    var fanfic: Fanfic?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
