//
//  ResultsTableViewController.swift
//  ATLunchStoryboard
//
//  Created by Hector Castillo on 11/4/21.
//

import Foundation
import UIKit

class ResultsTableViewController: UITableViewController {

    private let restaurants: [Restaurant]

    init(restaurants: [Restaurant]) {
        self.restaurants = restaurants
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        print("in tableview view did load")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UITableViewCell

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }

        cell?.textLabel?.text = restaurants[indexPath.row].title

        return cell!
    }


}
