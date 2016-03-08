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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Test", style: .Plain, target: self, action: "test:")
	}
	
	dynamic private func test(sender: UIBarButtonItem) {
		self.dataSource.runTests() {
			(edits: [Edit<Character>], isComplete: Bool) in
			self.collectionView?.updateWithEdits(edits, inSection: 0)
			self.navigationItem.rightBarButtonItem?.enabled = isComplete
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
