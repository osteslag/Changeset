//
//  TableViewController.swift
//  Changeset
//

import UIKit
import Changeset

class TableViewController: UITableViewController {
	
	private var dataSource = DataSource()
	
	@IBAction func test(sender: UIBarButtonItem) {
		self.dataSource.runTests() {
			(edits: [Edit<Character>], isComplete: Bool) in
			self.tableView.updateWithEdits(edits, inSection: 0)
			sender.enabled = isComplete
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
