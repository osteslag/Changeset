//
//  UIKit+Changeset.swift
//  Changeset
//

import UIKit
import Changeset

extension UITableView {

	/// Performs batch updates on the table view, given the edits of a Changeset, and animates the transition.
	public func updateWithEdits<T: Equatable> (_ edits: [Edit<T>], inSection section: Int) {

		guard !edits.isEmpty else { return }

		let indexPaths = batchIndexPathsFromEdits(edits, inSection: section)

		self.beginUpdates()
		if !indexPaths.deletions.isEmpty { self.deleteRows(at: indexPaths.deletions, with: .automatic) }
		if !indexPaths.insertions.isEmpty { self.insertRows(at: indexPaths.insertions, with: .automatic) }
		if !indexPaths.updates.isEmpty { self.reloadRows(at: indexPaths.updates, with: .automatic) }
		self.endUpdates()
	}
}

extension UICollectionView {

	/// Performs batch updates on the table view, given the edits of a Changeset, and animates the transition.
	public func updateWithEdits<T: Equatable> (_ edits: [Edit<T>], inSection section: Int, completion: ((Bool) -> Void)? = nil) {

		guard !edits.isEmpty else { return }

		let indexPaths = batchIndexPathsFromEdits(edits, inSection: section)

		self.performBatchUpdates({
			if !indexPaths.deletions.isEmpty { self.deleteItems(at: indexPaths.deletions) }
			if !indexPaths.insertions.isEmpty { self.insertItems(at: indexPaths.insertions) }
			if !indexPaths.updates.isEmpty { self.reloadItems(at: indexPaths.updates) }
			}, completion: completion)
	}
}

private func batchIndexPathsFromEdits<T: Equatable> (_ edits: [Edit<T>], inSection section: Int) -> (insertions: [IndexPath], deletions: [IndexPath], updates: [IndexPath]) {

	var insertions = [IndexPath]()
	var deletions = [IndexPath]()
	var updates = [IndexPath]()

	for edit in edits {
		let destinationIndexPath = NSIndexPath(row: edit.destination, section: section)
		switch edit.operation {
		case .deletion:
			deletions.append(destinationIndexPath as IndexPath)
		case .insertion:
			insertions.append(destinationIndexPath as IndexPath)
		case .move(let origin):
			let originIndexPath = NSIndexPath(row: origin, section: section)
			deletions.append(originIndexPath as IndexPath)
			insertions.append(destinationIndexPath as IndexPath)
		case .substitution:
			updates.append(destinationIndexPath as IndexPath)
		}
	}

	return (insertions: insertions, deletions: deletions, updates: updates)
}
