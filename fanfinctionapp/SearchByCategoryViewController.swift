//
//  SearchByCategoryViewController.swift
//  fanfinctionapp
//
//  Created by mac on 03.06.2023.
//  Copyright © 2023 mac. All rights reserved.
//

import UIKit

class SearchByCategoryViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let categories = ["Фантастика", "Фэнтези", "Романтика", "Драма"]
    var filteredCategories = [String]()
    var currentSearchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        filteredCategories = categories
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFanfics",
            let fanficVC = segue.destination as? ShowSearchResultsViewController,
            let category = sender as? String {
            fanficVC.fanficCategory = category
        }
    }
    
    func filterCategories(with searchText: String) {
        if searchText.isEmpty {
            filteredCategories = categories
        } else {
            filteredCategories = categories.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
        tableView.reloadData()
    }
}

extension SearchByCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = filteredCategories[indexPath.row]
        cell.textLabel?.textColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = filteredCategories[indexPath.row]
        performSegue(withIdentifier: "ShowFanfics", sender: category)
    }
}

extension SearchByCategoryViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        filterCategories(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        currentSearchText = ""
        searchBar.resignFirstResponder()
        filterCategories(with: "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
