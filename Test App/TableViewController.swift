//
//  TableViewController.swift
//  Changeset
//

import UIKit
import Changeset

class TableViewController: UITableViewController {
	
	fileprivate var dataSource = DataSource()
	
	@IBAction func test(_ sender: UIBarButtonItem) {
		self.dataSource.runTests() { (edits: Array<Changeset<String.CharacterView>.Edit>, isComplete: Bool) in
			self.tableView.update(with: edits)
			sender.isEnabled = isComplete
		}
	}
	
	// MARK: - UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.numberOfElementsInSection(section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = self.dataSource.textForElementAtIndexPath(indexPath)
		return cell
	}
}
