//
//  CollectionViewController.swift
//  Changeset
//
//  Created by Bart Whiteley on 2/12/16.
//  Copyright © 2016 Joachim Bondo. All rights reserved.
//

// Test collection view to experiment with using Changeset 
// to perform collection view updates.
// See https://github.com/osteslag/Changeset/issues/12

import UIKit
import Changeset

private let reuseIdentifier = "cell"

class CollectionViewController: UICollectionViewController {
	
	private var data = "changeset"
	
	private let tests = [
		"64927513",
		"917546832",
		"8C9A2574361B",
		"897A34B215C6",
		"5198427",
		"768952413",
		"changeset"
		]
	
	private var buttonsEnabled:Bool = true {
		didSet {
			navigationItem.rightBarButtonItem?.enabled = buttonsEnabled
			navigationItem.leftBarButtonItem?.enabled = buttonsEnabled
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Naive", style: .Plain, target: self, action: "testNaive")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Changeset", style: .Plain, target: self, action: "testChangeset")
    }
	
	dynamic private func testChangeset() {
		buttonsEnabled = false
		runTests(tests, naive: false)
	}
	
	dynamic private func testNaive() {
		buttonsEnabled = false
		runTests(tests, naive: true)
	}
	
	private func runTests(tests:[String], naive:Bool) {
		guard tests.count > 0 else {
			buttonsEnabled = true
			return
		}
		var tail = tests
		let next = tail.removeFirst()
		
		let edits = naive ? Changeset.naiveEditDistance(source: data.characters, target: next.characters) : Changeset.editDistance(source: data.characters, target: next.characters)
		
		data = next
		collectionView?.updateWithEdits(edits, inSection: 0) { completed in
			if completed {
				//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
					self.runTests(tail, naive: naive)
				//}
			}
		}
	}
}

extension CollectionViewController {
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.characters.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
		
		let char = data.characters[data.characters.startIndex.advancedBy(indexPath.item)]
		cell.label.text = "\(char)"
    
        return cell
    }
}

