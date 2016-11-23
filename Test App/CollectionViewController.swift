//
//  CollectionViewController.swift
//  Changeset
//

import UIKit
import Changeset

class CollectionViewController: UICollectionViewController {
	
	fileprivate var dataSource = DataSource()
	
	@IBAction func test(_ sender: UIBarButtonItem) {
		self.dataSource.runTests() {
			(edits: [Edit<Character>], isComplete: Bool) in
			self.collectionView?.update(with: edits)
			sender.isEnabled = isComplete
		}
	}
	
	// MARK: - UICollectionViewDataSource
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataSource.numberOfElementsInSection(section)
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
		cell.label.text = self.dataSource.textForElementAtIndexPath(indexPath)
		return cell
	}
}
