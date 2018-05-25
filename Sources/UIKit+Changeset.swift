//
//  UIKit+Changeset.swift
//

#if os(iOS)

import UIKit

extension UITableView {
	
	/// Performs batch updates on the table view, given the edits of a `Changeset`, and animates the transition.
	open func update<C>(with edits: Array<Changeset<C>.Edit>, in section: Int = 0, animation: UITableViewRowAnimation = .automatic) {
		
		guard !edits.isEmpty else { return }
		
		let indexPaths = batchIndexPaths(from: edits, in: section)
		
		self.beginUpdates()
		if !indexPaths.deletions.isEmpty { self.deleteRows(at: indexPaths.deletions, with: animation) }
		if !indexPaths.insertions.isEmpty { self.insertRows(at: indexPaths.insertions, with: animation) }
		if !indexPaths.updates.isEmpty { self.reloadRows(at: indexPaths.updates, with: animation) }
		self.endUpdates()
	}
}

extension UICollectionView {
	
	/// Performs batch updates on the table view, given the edits of a `Changeset`, and animates the transition.
	/// Because this method performs batch updates, it may cause a reload if your collection's layout is not up to date.
	/// To prevent issues, update your data model in the optional `batchUpdatesDidBegin` closure, or ensure your layout is
	/// updated before invoking this method.
	open func update<C>(with edits: Array<Changeset<C>.Edit>, in section: Int = 0, batchUpdatesDidBegin: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
		
		guard !edits.isEmpty else { return }
		
		let indexPaths = batchIndexPaths(from: edits, in: section)
		
		self.performBatchUpdates({
			batchUpdatesDidBegin?()
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
