//
//  UIKit+Changeset.swift
//

#if os(iOS)

import UIKit

extension UITableView {
	
	/// Performs batch updates on the table view, given the edits of a `Changeset`, and animates the transition.
	open func update<C>(with edits: Array<Changeset<C>.Edit>, in section: Int = 0) {
		
		guard !edits.isEmpty else { return }
		
		let indexPaths = batchIndexPaths(from: edits, in: section)
		
		self.beginUpdates()
		if !indexPaths.deletions.isEmpty { self.deleteRows(at: indexPaths.deletions, with: .automatic) }
		if !indexPaths.insertions.isEmpty { self.insertRows(at: indexPaths.insertions, with: .automatic) }
		if !indexPaths.updates.isEmpty { self.reloadRows(at: indexPaths.updates, with: .automatic) }
		self.endUpdates()
	}
}

extension UICollectionView {
	
	/// Performs batch updates on the table view, given the edits of a `Changeset`, and animates the transition.
	open func update<C>(with edits: Array<Changeset<C>.Edit>, in section: Int = 0, completion: ((Bool) -> Void)? = nil) {
		
		guard !edits.isEmpty else { return }
		
		let indexPaths = batchIndexPaths(from: edits, in: section)
		
		self.performBatchUpdates({
			if !indexPaths.deletions.isEmpty { self.deleteItems(at: indexPaths.deletions) }
			if !indexPaths.insertions.isEmpty { self.insertItems(at: indexPaths.insertions) }
			if !indexPaths.updates.isEmpty { self.reloadItems(at: indexPaths.updates) }
		}, completion: completion)
	}
}

private func batchIndexPaths<C> (from edits: Array<Changeset<C>.Edit>, in section: Int) -> (insertions: Array<IndexPath>, deletions: Array<IndexPath>, updates: Array<IndexPath>) {
	
	var insertions: Array<IndexPath> = []
	var deletions: Array<IndexPath> = []
	var updates: Array<IndexPath> = []
	
	for edit in edits {
		let destinationIndexPath = IndexPath(row: edit.destination, section: section)
		switch edit.operation {
		case .deletion:
			deletions.append(destinationIndexPath)
		case .insertion:
			insertions.append(destinationIndexPath)
		case .move(let origin):
			let originIndexPath = IndexPath(row: origin, section: section)
			deletions.append(originIndexPath)
			insertions.append(destinationIndexPath)
		case .substitution:
			updates.append(destinationIndexPath)
		}
	}
	
	return (insertions: insertions, deletions: deletions, updates: updates)
}

#endif
