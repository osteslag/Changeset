//
//  Changeset.swift
//  Copyright (c) 2015 Joachim Bondo. All rights reserved.
//

/// Defines an atomic edit.
/// - seealso: Note on `EditOperation`.
public struct Edit<T: Equatable> {
	public let operation: EditOperation
	public let value: T
	public let destination: Int
	
	// Define initializer so that we don't have to add the `operation` label.
	public init(_ operation: EditOperation, value: T, destination: Int) {
		self.operation = operation
		self.value = value
		self.destination = destination
	}
}

/// Defines the type of an `Edit`.
/// - note: I would have liked to make it an `Edit.Operation` subtype, but that's currently not allowed inside a generic type.
public enum EditOperation {
	case Insertion
	case Deletion
	case Substitution
	case Move(origin: Int)
}

/// A `Changeset` is a way to describe the edits required to go from one set of data to another.
///
/// It detects additions, deletions, substitutions, and moves. Data is a `CollectionType` of `Equatable` elements.
///
/// - note: This implementation was inspired by [Dave DeLong](https://twitter.com/davedelong)'s article, [Edit distance and edit steps](http://davedelong.tumblr.com/post/134367865668/edit-distance-and-edit-steps).
///
/// - seealso: `Changeset.editDistance`.
public struct Changeset<T: CollectionType where T.Generator.Element: Equatable, T.Index.Distance == Int> {
	
	/// The starting-point collection.
	public let origin: T
	
	/// The ending-point collection.
	public let destination: T
	
	/// The edit steps required to go from `self.origin` to `self.destination`.
	/// - note: I would have liked to make this `lazy`, but that would prohibit users from using constant `Changeset` values.
	/// - seealso: [Lazy Properties in Structs](http://oleb.net/blog/2015/12/lazy-properties-in-structs-swift/) by [Ole Begemann](https://twitter.com/olebegemann).
	public let edits: [Edit<T.Generator.Element>]
	
	public init(source origin: T, target destination: T) {
		self.origin = origin
		self.destination = destination
		self.edits = Changeset.editDistance(source: self.origin, target: self.destination)
	}
	
	/// Returns the edit steps required to go from `source` to `target`.
	///
	/// - note: Indexes in the returned `Edit` elements are into the `source` collection (just like how `UITableView` expects changes in the `beginUpdates`/`endUpdates` block.)
	///
	/// - seealso:
	///   - [Edit distance and edit steps](http://davedelong.tumblr.com/post/134367865668/edit-distance-and-edit-steps) by [Dave DeLong](https://twitter.com/davedelong).
	///   - [Explanation of and Pseudo-code for the Wagner-Fischer algorithm](https://en.wikipedia.org/wiki/Wagner–Fischer_algorithm).
	///
	/// - parameters:
	///   - source: The starting-point collection.
	///   - target: The ending-point collection.
	///
	/// - returns: An array of `Edit` elements.
	/// The number of steps is then the `count` of elements.
	public static func editDistance(source s: T, target t: T) -> [Edit<T.Generator.Element>] {
		
		let m = s.count
		let n = t.count
		
		// Fill first row and column of insertions and deletions.
		
		var d: [[[Edit<T.Generator.Element>]]] = Array(count: m + 1, repeatedValue: Array(count: n + 1, repeatedValue: []))
		
		var edits = [Edit<T.Generator.Element>]()
		for (row, element) in s.enumerate() {
			let deletion = Edit(.Deletion, value: element, destination: row)
			edits.append(deletion)
			d[row + 1][0] = edits
		}
		
		edits.removeAll()
		for (col, element) in t.enumerate() {
			let insertion = Edit(.Insertion, value: element, destination: col)
			edits.append(insertion)
			d[0][col + 1] = edits
		}
		
		guard m > 0 && n > 0 else { return d[m][n] }
		
		// Indexes into the two collections.
		var sx: T.Index
		var tx = t.startIndex
		
		// Fill body of matrix.
		
		for j in 1...n {
			sx = s.startIndex
			
			for i in 1...m {
				if s[sx] == t[tx] {
					d[i][j] = d[i - 1][j - 1] // no operation
				} else {
					
					var del = d[i - 1][j] // a deletion
					var ins = d[i][j - 1] // an insertion
					var sub = d[i - 1][j - 1] // a substitution
					
					// Record operation.
					
					let minimumCount = min(del.count, ins.count, sub.count)
					if del.count == minimumCount {
						let deletion = Edit(.Deletion, value: s[sx], destination: i - 1)
						del.append(deletion)
						d[i][j] = del
					} else if ins.count == minimumCount {
						let insertion = Edit(.Insertion, value: t[tx], destination: j - 1)
						ins.append(insertion)
						d[i][j] = ins
					} else {
						let substitution = Edit(.Substitution, value: t[tx], destination: j - 1)
						sub.append(substitution)
						d[i][j] = sub
					}
				}
				
				sx = sx.advancedBy(1)
			}
			
			tx = tx.advancedBy(1)
		}
		
		// Convert deletion/insertion pairs of same element into moves.
		return reducedEdits(d[m][n])
	}
}

/// Returns an array where deletion/insertion pairs of the same element are replaced by `.Move` edits.
private func reducedEdits<T: Equatable>(edits: [Edit<T>]) -> [Edit<T>] {
	return edits.reduce([Edit<T>]()) {
		(var reducedEdits, edit) in
		
		if let (move, index) = moveFromEdits(reducedEdits, deletionOrInsertion: edit), case .Move = move.operation {
			reducedEdits.removeAtIndex(index)
			reducedEdits.append(move)
		} else {
			reducedEdits.append(edit)
		}
		
		return reducedEdits
	}
}

/// Returns a potential move `Edit` based on an array of `Edit` elements and an `edit` to match up against.
///
/// If `edit` is a deletion or an insertion, and there is a matching inverse insertion/deletion with the same value in the array, a corresponding `.Move` edit is returned. 
///
/// As a convenience, the index of the matched edit into `edits` is returned as well.
private func moveFromEdits<T: Equatable>(edits: [Edit<T>], deletionOrInsertion edit: Edit<T>) -> (move: Edit<T>, index: Int)? {
	
	switch edit.operation {
	
	case .Deletion:
		if let insertionIndex = edits.indexOf({ (earlierEdit) -> Bool in
			if case .Insertion = earlierEdit.operation where earlierEdit.value == edit.value { return true } else { return false }
		}) {
			return (Edit(.Move(origin: edit.destination), value: edit.value, destination: edits[insertionIndex].destination), insertionIndex)
		}
	
	case .Insertion:
		if let deletionIndex = edits.indexOf({ (earlierEdit) -> Bool in
			if case .Deletion = earlierEdit.operation where earlierEdit.value == edit.value { return true } else { return false }
		}) {
			return (Edit(.Move(origin: edits[deletionIndex].destination), value: edit.value, destination: edit.destination), deletionIndex)
		}
		
	default:
		break
	}
	
	return nil
}

extension Edit: Equatable {}
public func ==<T: Equatable>(lhs: Edit<T>, rhs: Edit<T>) -> Bool {
	guard lhs.destination == rhs.destination && lhs.value == rhs.value else { return false }
	switch (lhs.operation, rhs.operation) {
	case (.Insertion, .Insertion), (.Deletion, .Deletion), (.Substitution, .Substitution):
		return true
	case (.Move(let lhsOrigin), .Move(let rhsOrigin)):
		return lhsOrigin == rhsOrigin
	default:
		return false
	}
}
