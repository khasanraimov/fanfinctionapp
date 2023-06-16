//
//  FanficListViewController.swift
//  fanfinctionapp
//
//  Created by mac on 01.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class FanficViewCell: UITableViewCell {
    
    @IBOutlet weak var titleFanfic: UILabel!
    @IBOutlet weak var imageFanfic: UIImageView!

    var editHandler: (() -> Void)?
    
//    func setEditHandler(_ handler: @escaping () -> Void) {
//        editHandler = handler
//        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
//    }
    
    @objc private func editButtonTapped() {
        editHandler?()
    }
}

class FanficListViewController: UIViewController {
    
    @IBOutlet weak var toCreateButton: UIButton!
    @IBOutlet weak var fanficList: UITableView!
    
    var fanfics: [Fanfic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fanficList.dataSource = self
        fanficList.delegate = self
        
        // Получаем фанфики авторизованного пользователя из Firebase
        let fanficsRef = Database.database(url: "https://fanfiction-4f149-default-rtdb.firebaseio.com/").reference(withPath: "fanfics")
        let currentUserID = Auth.auth().currentUser?.uid
        let query = fanficsRef.queryOrdered(byChild: "author").queryEqual(toValue: currentUserID)
        query.observe(.value, with: { snapshot in
            var newFanfics: [Fanfic] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let fanfic = Fanfic(snapshot: snapshot) {
                    newFanfics.append(fanfic)
                }
            }
            self.fanfics = newFanfics
            self.fanficList.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditViewController" {
            if let editVC = segue.destination as? EditViewController,
                let indexPath = fanficList.indexPathForSelectedRow {
                editVC.fanfic = [fanfics[indexPath.row]]
                editVC.onSave = {
                    self.fanficList.reloadData()
                }
            }
        }
    }
}

extension FanficListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fanfics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FanficViewCell", for: indexPath) as! FanficViewCell
        let fanfic = fanfics[indexPath.row]
        cell.titleFanfic.text = fanfic.title
        
//        cell.setEditHandler {
//            self.editFanfic(fanfic)
//        }
        
        // Load fanfic image
        cell.imageFanfic.layer.cornerRadius = 15
        cell.imageFanfic.clipsToBounds = true
        if let imageURLString = fanfic.imageURL {
            let imageURL = URL(string: imageURLString)!
            let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imageFanfic.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        }
        
        return cell
    }
    
    func editFanfic(_ fanfic: Fanfic) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let creatingVC = storyboard.instantiateViewController(withIdentifier: "CreatingViewController") as! CreatingViewController
        creatingVC.fanfic = fanfic
        navigationController?.pushViewController(creatingVC, animated: true)
    }
}

extension FanficListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Implement fanfic detail view
        let fanfic = fanfics[indexPath.row]
//        editFanfic(fanfic)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.fanfic = [fanfic]
        navigationController?.pushViewController(editVC, animated: true)
        performSegue(withIdentifier: "EditViewController", sender: nil)
    }
}
