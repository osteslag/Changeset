//
//  Changeset.swift
//  Copyright (c) 2015-16 Joachim Bondo. All rights reserved.
//

/// Defines an atomic edit on a `Collection` of `Equatable` where we can do basic arithmetic on the `IndexDistance`.
public struct Edit<C: Collection> where C.Iterator.Element: Equatable {
	
	/** The type used to refer to elements in the collections.
	
	Because not all collection indices are zero-based, let alone `Int`-based, an `Edit` uses *offsets* to elements in the collection.
	
	  - seealso: Discussions on GitHub: [#37](https://github.com/osteslag/Changeset/issues/37), [#39](https://github.com/osteslag/Changeset/pull/39#discussion_r129030599).
	*/
	public typealias Offset = C.IndexDistance
	
	public typealias Element = C.Iterator.Element
	
	/// Defines the type of an `Edit`.
	public enum Operation {
		case insertion
		case deletion
		case substitution
		case move(origin: Offset)
	}
	
	public let operation: Operation
	public let value: Element
	public let destination: Offset
	
	// Define initializer so that we don't have to add the `operation` label.
	public init(_ operation: Operation, value: Element, destination: Offset) {
		self.operation = operation
		self.value = value
		self.destination = destination
	}
}

/** A `Changeset` is a way to describe the edits required to go from one set of data to another.

It detects additions, deletions, substitutions, and moves. Data is a `Collection` of `Equatable` elements.

  - note: This implementation was inspired by [Dave DeLong](https://twitter.com/davedelong)'s article, [Edit distance and edit steps](http://davedelong.tumblr.com/post/134367865668/edit-distance-and-edit-steps).

  - seealso: `Changeset.editDistance`.
*/
public struct Changeset<T: Collection> where T.Iterator.Element: Equatable {
	
	/// The starting-point collection.
	public let origin: T
	
	/// The ending-point collection.
	public let destination: T
	
	/** The edit steps required to go from `self.origin` to `self.destination`.
		
	  - note: I would have liked to make this `lazy`, but that would prohibit users from using constant `Changeset` values.
	
	  - seealso: [Lazy Properties in Structs](http://oleb.net/blog/2015/12/lazy-properties-in-structs-swift/) by [Ole Begemann](https://twitter.com/olebegemann).
	*/
	public let edits: [Edit<T>]
	
	public init(source origin: T, target destination: T) {
		self.origin = origin
		self.destination = destination
		self.edits = Changeset.edits(from: self.origin, to: self.destination)
	}
	
	/** Returns the edit steps required to go from one collection to another.
	
	The number of steps is the `count` of `Edit` elements.
	
	  - note: Offsets in the returned `Edit` elements are into the `from` source collection (just like how `UITableView` expects changes in the `beginUpdates`/`endUpdates` block.)
	
	  - seealso:
	    - [Edit distance and edit steps](http://davedelong.tumblr.com/post/134367865668/edit-distance-and-edit-steps) by [Dave DeLong](https://twitter.com/davedelong).
	    - [Explanation of and Pseudo-code for the Wagner-Fischer algorithm](https://en.wikipedia.org/wiki/Wagner–Fischer_algorithm).
	
	  - parameters:
	    - from: The starting-point collection.
	    - to: The ending-point collection.
	
	  - returns: An array of `Edit` elements.
	*/
	public static func edits(from source: T, to target: T) -> [Edit<T>] {
		
		let rows = Int(source.count.toIntMax())
		let columns = Int(target.count.toIntMax())
		
		// Only the previous and current row of the matrix are required.
		var previousRow: [[Edit<T>]] = Array(repeating: [], count: columns + 1)
		var currentRow = [[Edit<T>]]()
		
		// Offsets into the two collections.
		var sourceOffset = source.startIndex
		var targetOffset: T.Index
		
		// Fill first row of insertions.
		var edits = [Edit<T>]()
		for (column, element) in target.enumerated() { // Note that enumerated() gives us zero-based offsets which is exactly what we want
			let edit = Edit<T>(.insertion, value: element, destination: Edit<T>.Offset(column.toIntMax()))
			edits.append(edit)
			previousRow[column + 1] = edits
		}
		
		if rows > 0 {
			for row in 1...rows {
				targetOffset = target.startIndex
				
				currentRow = Array(repeating: [], count: columns + 1)
				
				// Fill first cell with deletion.
				var edits = previousRow[0]
				let edit = Edit<T>(.deletion, value: source[sourceOffset], destination: Edit<T>.Offset(row.toIntMax()) - 1)
				edits.append(edit)
				currentRow[0] = edits
				
				if columns > 0 {
					for column in 1...columns {
						if source[sourceOffset] == target[targetOffset] {
							currentRow[column] = previousRow[column - 1] // no operation
						} else {
							var deletion = previousRow[column] // a deletion
							var insertion = currentRow[column - 1] // an insertion
							var substitution = previousRow[column - 1] // a substitution
							
							// Record operation.
							let minimumCount = min(deletion.count, insertion.count, substitution.count)
							if deletion.count == minimumCount {
								let edit = Edit<T>(.deletion, value: source[sourceOffset], destination: Edit<T>.Offset(row.toIntMax()) - 1)
								deletion.append(edit)
								currentRow[column] = deletion
							} else if insertion.count == minimumCount {
								let edit = Edit<T>(.insertion, value: target[targetOffset], destination: Edit<T>.Offset(column.toIntMax()) - 1)
								insertion.append(edit)
								currentRow[column] = insertion
							} else {
								let edit = Edit<T>(.substitution, value: target[targetOffset], destination: Edit<T>.Offset(row.toIntMax()) - 1)
								substitution.append(edit)
								currentRow[column] = substitution
							}
						}
						
						targetOffset = target.index(targetOffset, offsetBy: 1)
					}
				}
				
				previousRow = currentRow
				sourceOffset = source.index(sourceOffset, offsetBy: 1)
			}
		}
		
		// Convert deletion/insertion pairs of same element into moves.
		return reducedEdits(previousRow[columns])
	}
}

/** Returns an array where deletion/insertion pairs of the same element are replaced by `.move` edits.

  - parameter edits: An array of `Edit` elements to be reduced.
  - returns: An array of `Edit` elements.
*/
private func reducedEdits<T: Collection>(_ edits: [Edit<T>]) -> [Edit<T>] {
	return edits.reduce([Edit<T>]()) { (edits, edit) in
		var reducedEdits = edits
		if let (move, offset) = move(from: edit, in: reducedEdits), case .move = move.operation {
			reducedEdits.remove(at: Int(offset.toIntMax()))
			reducedEdits.append(move)
		} else {
			reducedEdits.append(edit)
		}
		
		return reducedEdits
	}
}

/** Returns a potential `.move` edit based on an array of `Edit` elements and an edit to match up against.

If `edit` is a deletion or an insertion, and there is a matching opposite insertion/deletion with the same value in the array, a corresponding `.move` edit is returned.

  - parameters:
    - deletionOrInsertion: A `.deletion` or `.insertion` edit there will be searched an opposite match for.
    - edits: The array of `Edit` elements to search for a match in.

  - returns: An optional tuple consisting of the `.move` `Edit` that corresponds to the given deletion or insertion and an opposite match in `edits`, and the offset of the match – if one was found.
*/
private func move<T: Collection>(from deletionOrInsertion: Edit<T>, `in` edits: [Edit<T>]) -> (move: Edit<T>, offset: Edit<T>.Offset)? {
	
	switch deletionOrInsertion.operation {
		
	case .deletion:
		if let insertionOffset = edits.index(where: { (earlierEdit) -> Bool in
			if case .insertion = earlierEdit.operation, earlierEdit.value == deletionOrInsertion.value { return true } else { return false }
		}) {
			return (Edit(.move(origin: deletionOrInsertion.destination), value: deletionOrInsertion.value, destination: edits[insertionOffset].destination), Edit<T>.Offset(insertionOffset.toIntMax()))
		}
		
	case .insertion:
		if let deletionOffset = edits.index(where: { (earlierEdit) -> Bool in
			if case .deletion = earlierEdit.operation, earlierEdit.value == deletionOrInsertion.value { return true } else { return false }
		}) {
			return (Edit(.move(origin: edits[deletionOffset].destination), value: deletionOrInsertion.value, destination: deletionOrInsertion.destination), Edit<T>.Offset(deletionOffset.toIntMax()))
		}
		
	default:
		break
	}
	
	return nil
}

extension Edit: Equatable {}
public func ==<T: Collection>(lhs: Edit<T>, rhs: Edit<T>) -> Bool {
	guard lhs.destination == rhs.destination && lhs.value == rhs.value else { return false }
	switch (lhs.operation, rhs.operation) {
	case (.insertion, .insertion), (.deletion, .deletion), (.substitution, .substitution):
		return true
	case (.move(let lhsOrigin), .move(let rhsOrigin)):
		return lhsOrigin == rhsOrigin
	default:
		return false
	}
}
