//
//  UIKit+Changeset.swift
//

#if os(iOS)

import UIKit

extension UITableView {
	
	/// Performs batch updates on the table view, given the edits of a `Changeset`, and animates the transition.
	open func update<C>(with edits: Array<Changeset<C>.Edit>, in section: Int = 0, animation: UITableView.RowAnimation = .automatic) {
		
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
	
	/** Performs batch updates on the collection view, given the edits of a `Changeset`, and animates the transition.
	
	- note: As per the [Collection View Programming Guide for iOS](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/CollectionViewPGforIOS/), we should update the model before doing any incremental collection view updates. However, if the collection view is in a certain state and needs layout, the `UICollectionViewDataSource` methods are called immediately when the `performBatchUpdates` call is invoked. This updates the internal state, causing the incremental updates to be applied on an already up-to-date model. To prevent this issue from happening, ensure your view is in a consistent state and the model is updated before calling this method. This issue should go away when Apple fixes the issue.
	
	- seealso: Discussion on [Pull Request #26](https://github.com/osteslag/Changeset/pull/46).
	- seealso: [Open Radar 28167779](https://github.com/PSPDFKit-labs/radar.apple.com/tree/master/28167779%20-%20CollectionViewBatchingIssue).
	*/
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
