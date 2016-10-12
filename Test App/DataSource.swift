//
//  DataSource.swift
//  Changeset
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
private let kTestInterval: TimeInterval = 0.5

class DataSource {
	
	fileprivate var data = kDefaultData
	
	/// The callback is called after each test to let the caller update its view, or whatever.
	func runTests(_ testData: [String] = kTestData, callback: @escaping ((_ edits: [Edit<Character>], _ isComplete: Bool) -> Void)) {
		var nextTestData = testData
		let next = nextTestData.remove(at: 0)
		let edits = Changeset.editDistance(source: self.data.characters, target: next.characters) // Call naiveEditDistance for a different approach
		
		self.data = next
		callback(edits, nextTestData.isEmpty)
		
		guard !nextTestData.isEmpty else { return }
		
		// Schedule next test.
		let when = DispatchTime.now() + kTestInterval
		DispatchQueue.main.asyncAfter(deadline: when) {
			self.runTests(nextTestData, callback: callback)
		}
	}
	
	// MARK: -
	
	func numberOfElementsInSection(_ section: Int) -> Int {
		return self.data.characters.count
	}
	
	func textForElementAtIndexPath(_ indexPath: IndexPath) -> String {
		return String(self.data.characters[data.characters.index(data.characters.startIndex, offsetBy: (indexPath as NSIndexPath).row)])
	}
}
