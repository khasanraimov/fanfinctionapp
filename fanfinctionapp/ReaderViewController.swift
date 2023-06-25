//
//  ReaderViewController.swift
//  fanfinctionapp
//
//  Created by mac on 06.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase

class ReaderViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var fanfic: Fanfic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let text = fanfic?.content {
            textView.text = text
        } else {
            print("nil")
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
