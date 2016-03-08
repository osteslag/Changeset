//
//  CollectionViewController.swift
//  Changeset
//
//  Created by Bart Whiteley on 2/12/16.
//  Copyright © 2016 Joachim Bondo. All rights reserved.
//

import UIKit
import Changeset

class CollectionViewController: UICollectionViewController {
	
	private var dataSource = DataSource()
	
	@IBAction func test(sender: UIBarButtonItem) {
		self.dataSource.runTests() {
			(edits: [Edit<Character>], isComplete: Bool) in
			self.collectionView?.updateWithEdits(edits, inSection: 0)
			sender.enabled = isComplete
		}
	}
	
	// MARK: - UICollectionViewDataSource
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataSource.numberOfElementsInSection(section)
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
		cell.label.text = self.dataSource.textForElementAtIndexPath(indexPath)
		return cell
	}
}
