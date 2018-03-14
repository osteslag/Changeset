//
//  Changeset.swift
//  Copyright (c) 2015-17 Joachim Bondo. All rights reserved.
//

/** A `Changeset` describes the edits required to go from one set of data to another.

It detects additions, deletions, substitutions, and moves. Data is a `Collection` of `Equatable` elements.

  - note: This implementation was inspired by [Dave DeLong](https://twitter.com/davedelong)'s article, [Edit distance and edit steps](http://davedelong.tumblr.com/post/134367865668/edit-distance-and-edit-steps).

  - seealso: `Changeset.edits`.
*/
public struct Changeset<C: Collection> where C.Iterator.Element: Equatable, C.IndexDistance == Int {
	
	/// Closure used to compare two elements.
	public typealias Comparator = (C.Iterator.Element, C.Iterator.Element) -> Bool

	/// The starting-point collection.
	public let origin: C
	
	/// The ending-point collection.
	public let destination: C
	
	/** The edit steps required to go from `self.origin` to `self.destination`.
		
	  - note: I would have liked to make this `lazy`, but that would prohibit users from using constant `Changeset` values.
	
	  - seealso: [Lazy Properties in Structs](http://oleb.net/blog/2015/12/lazy-properties-in-structs-swift/) by [Ole Begemann](https://twitter.com/olebegemann).
	*/
	public let edits: Array<Edit>
	
	public init(source origin: C, target destination: C, comparator: Comparator = (==)) {
		self.origin = origin
		self.destination = destination
		self.edits = Changeset.edits(from: self.origin, to: self.destination, comparator: comparator)
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
	    - comparator: The comparision function to use.
	
	  - returns: An array of `Edit` elements.
	*/
	public static func edits(from source: C, to target: C, comparator: Comparator = (==)) -> Array<Edit> {
		
		let rows = source.count
		let columns = target.count
		
		// Only the previous and current row of the matrix are required.
		var previousRow: Array<Array<Edit>> = Array(repeating: [], count: columns + 1)
		var currentRow = Array<Array<Edit>>()
		
		// Offsets into the two collections.
		var sourceOffset = source.startIndex
		var targetOffset: C.Index
		
		// Fill first row of insertions.
		var edits = Array<Edit>()
		for (column, element) in target.enumerated() { // Note that enumerated() gives us zero-based offsets which is exactly what we want
			let edit = Edit(operation: .insertion, value: element, destination: column)
			edits.append(edit)
			previousRow[column + 1] = edits
		}
		
		if rows > 0 {
			for row in 1...rows {
				targetOffset = target.startIndex
				
				currentRow = Array(repeating: [], count: columns + 1)
				
				// Fill first cell with deletion.
				var edits = previousRow[0]
				let edit = Edit(operation: .deletion, value: source[sourceOffset], destination: row - 1)
				edits.append(edit)
				currentRow[0] = edits
				
				if columns > 0 {
					for column in 1...columns {
						if comparator(source[sourceOffset], target[targetOffset]) {
							currentRow[column] = previousRow[column - 1] // no operation
						} else {
							var deletion = previousRow[column] // a deletion
							var insertion = currentRow[column - 1] // an insertion
							var substitution = previousRow[column - 1] // a substitution
							
							// Record operation.
							let minimumCount = min(deletion.count, insertion.count, substitution.count)
							if deletion.count == minimumCount {
								let edit = Edit(operation: .deletion, value: source[sourceOffset], destination: row - 1)
								deletion.append(edit)
								currentRow[column] = deletion
							} else if insertion.count == minimumCount {
								let edit = Edit(operation: .insertion, value: target[targetOffset], destination: column - 1)
								insertion.append(edit)
								currentRow[column] = insertion
							} else {
								let edit = Edit(operation: .substitution, value: target[targetOffset], destination: row - 1)
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
		return Changeset.reducedEdits(previousRow[columns], comparator: comparator)
	}
}
