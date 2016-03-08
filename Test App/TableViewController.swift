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
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Naive", style: .Plain, target: self, action: "test:")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Changeset", style: .Plain, target: self, action: "test:")
		
		self.navigationItem.leftBarButtonItem?.tag = TestType.Naive.rawValue
		self.navigationItem.rightBarButtonItem?.tag = TestType.Changeset.rawValue
    }
	
	dynamic private func test(sender: UIBarButtonItem) {
		guard let testType = TestType(rawValue: sender.tag) else { return }
		
		self.dataSource.runTests(testType) {
			(edits: [Edit<Character>], isComplete: Bool) in
			self.tableView.updateWithEdits(edits, inSection: 0)
			self.navigationItem.rightBarButtonItem?.enabled = isComplete
			self.navigationItem.leftBarButtonItem?.enabled = isComplete
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
