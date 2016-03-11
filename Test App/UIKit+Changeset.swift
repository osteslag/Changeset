//
//  UIKit+Changeset.swift
//  Changeset
//

import UIKit
import Changeset

extension UITableView {
	
	/// Performs batch updates on the table view, given the edits of a Changeset, and animates the transition.
	public func updateWithEdits<T: Equatable> (edits: [Edit<T>], inSection section: Int) {
		
		guard !edits.isEmpty else { return }
		
		let indexPaths = batchIndexPathsFromEdits(edits, inSection: section)
		
		self.beginUpdates()
		if !indexPaths.deletions.isEmpty { self.deleteRowsAtIndexPaths(indexPaths.deletions, withRowAnimation: .Automatic) }
		if !indexPaths.insertions.isEmpty { self.insertRowsAtIndexPaths(indexPaths.insertions, withRowAnimation: .Automatic) }
		if !indexPaths.updates.isEmpty { self.reloadRowsAtIndexPaths(indexPaths.updates, withRowAnimation: .Automatic) }
		self.endUpdates()
	}
}

extension UICollectionView {
	
	/// Performs batch updates on the table view, given the edits of a Changeset, and animates the transition.
	public func updateWithEdits<T: Equatable> (edits: [Edit<T>], inSection section: Int, completion: ((Bool) -> Void)? = nil) {
		
		guard !edits.isEmpty else { return }
		
		let indexPaths = batchIndexPathsFromEdits(edits, inSection: section)
		
		self.performBatchUpdates({
			if !indexPaths.deletions.isEmpty { self.deleteItemsAtIndexPaths(indexPaths.deletions) }
			if !indexPaths.insertions.isEmpty { self.insertItemsAtIndexPaths(indexPaths.insertions) }
			if !indexPaths.updates.isEmpty { self.reloadItemsAtIndexPaths(indexPaths.updates) }
		}, completion: completion)
	}
}

private func batchIndexPathsFromEdits<T: Equatable> (edits: [Edit<T>], inSection section: Int) -> (insertions: [NSIndexPath], deletions: [NSIndexPath], updates: [NSIndexPath]) {
	
	var insertions = [NSIndexPath]()
	var deletions = [NSIndexPath]()
	var updates = [NSIndexPath]()
	
	for edit in edits {
		let destinationIndexPath = NSIndexPath(forRow: edit.destination, inSection: section)
		switch edit.operation {
		case .Deletion:
			deletions.append(destinationIndexPath)
		case .Insertion:
			insertions.append(destinationIndexPath)
		case .Move(let origin):
			let originIndexPath = NSIndexPath(forRow: origin, inSection: section)
			deletions.append(originIndexPath)
			insertions.append(destinationIndexPath)
		case .Substitution:
			updates.append(destinationIndexPath)
		}
	}
	
	return (insertions: insertions, deletions: deletions, updates: updates)
}
