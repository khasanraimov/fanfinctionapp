//
//  AuthorViewController.swift
//  fanfinctionapp
//
//  Created by mac on 17.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit

class AuthorViewController: UIViewController {
    
    
    @IBOutlet weak var imageAuthor: UIImageView!
    @IBOutlet weak var nameAuthor: UILabel!
    @IBOutlet weak var aboutAuthor: UILabel!
    @IBOutlet weak var authorFanfics: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func followButtonTaped(_ sender: Any) {
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
