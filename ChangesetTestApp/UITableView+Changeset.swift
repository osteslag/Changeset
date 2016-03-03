//
//  UITableView+Changeset.swift
//  Changeset
//
//  Created by Bart Whiteley on 2/29/16.
//  Copyright © 2016 Joachim Bondo. All rights reserved.
//

import UIKit
import Changeset

public extension UITableView {
	
	/// Performs batch updates on the table view, given the edits of a Changeset, and animates the transition.
	public func updateWithEdits<T: Equatable> (edits: [Edit<T>], inSection section: Int) {
		
		guard !edits.isEmpty else { return }
		
		let indexPaths = batchIndexPathsFromEdits(edits, inSection: section)
		
		self.beginUpdates()
		if !indexPaths.deletions.isEmpty { self.deleteRowsAtIndexPaths(indexPaths.deletions, withRowAnimation: .Automatic) }
		if !indexPaths.insertions.isEmpty { self.insertRowsAtIndexPaths(indexPaths.insertions, withRowAnimation: .Automatic) }
		if !indexPaths.updates.isEmpty { self.reloadRowsAtIndexPaths(indexPaths.updates, withRowAnimation: .Automatic) }
		indexPaths.moves.forEach { self.moveRowAtIndexPath($0.from, toIndexPath: $0.to) }
		self.endUpdates()
	}
}
