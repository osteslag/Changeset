//
//  DataSource.swift
//  Changeset
//
//  Created by Joachim Bondo on 04/03/16.
//  Copyright © 2016 Joachim Bondo. All rights reserved.
//

import UIKit
import Changeset

private let kDefaultData = "changeset"
private let kTestData = [
	"64927513",
	"917546832",
	"8C9A2574361B",
	"897A34B215C6",
	"5198427",
	"768952413",
	kDefaultData,
]
private let kTestInterval: NSTimeInterval = 0.5

/// The type of the test.
enum TestType: Int {
	case Changeset = 1
	case Naive = 2
}

class DataSource {
	
	private var data = kDefaultData
	
	/// The callback is called after each test to let the caller update its view, or whatever.
	func runTests(type: TestType, var testData: [String] = kTestData, callback: ((edits: [Edit<Character>], isComplete: Bool) -> Void)) {
		
		let next = testData.removeAtIndex(0)
		let edits: [Edit<Character>]
		
		switch type {
		case .Changeset:
			edits = Changeset.editDistance(source: self.data.characters, target: next.characters)
		case .Naive:
			edits = Changeset.naiveEditDistance(source: self.data.characters, target: next.characters)
		}
		
		self.data = next
		callback(edits: edits, isComplete: testData.isEmpty)
		
		guard !testData.isEmpty else { return }
		
		// Schedule next test.
		let when = dispatch_time(DISPATCH_TIME_NOW, Int64(kTestInterval * Double(NSEC_PER_SEC)))
		dispatch_after(when, dispatch_get_main_queue()) {
			self.runTests(type, testData: testData, callback: callback)
		}
	}
	
	// MARK: -
	
	func numberOfElementsInSection(section: Int) -> Int {
		return self.data.characters.count
	}
	
	func textForElementAtIndexPath(indexPath: NSIndexPath) -> String {
		return String(self.data.characters[data.characters.startIndex.advancedBy(indexPath.row)])
	}
}
