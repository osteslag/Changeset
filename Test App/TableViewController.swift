//
//  TableViewController.swift
//  Changeset
//
//  Created by Bart Whiteley on 2/29/16.
//  Copyright © 2016 Joachim Bondo. All rights reserved.
//

import UIKit
import Changeset

class TableViewController: UITableViewController {
	
	private var dataSource = DataSource()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Test", style: .Plain, target: self, action: "test:")
    }
	
	dynamic private func test(sender: UIBarButtonItem) {
		self.dataSource.runTests() {
			(edits: [Edit<Character>], isComplete: Bool) in
			self.tableView.updateWithEdits(edits, inSection: 0)
			self.navigationItem.rightBarButtonItem?.enabled = isComplete
		}
	}
	
	// MARK: - UITableViewDataSource
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.numberOfElementsInSection(section)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		cell.textLabel?.text = self.dataSource.textForElementAtIndexPath(indexPath)
		return cell
	}
}
