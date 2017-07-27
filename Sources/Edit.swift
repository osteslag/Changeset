//
//  Changeset.swift
//  Copyright (c) 2017 Joachim Bondo. All rights reserved.
//

/// Defines an atomic edit on a `Collection` of `Equatable` where we can do basic arithmetic on the `IndexDistance`.
public struct Edit<C: Collection> where C.Iterator.Element: Equatable, C.IndexDistance == Int {
	
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

/** Returns an array where deletion/insertion pairs of the same element are replaced by `.move` edits.

- parameter edits: An array of `Edit` elements to be reduced.
- returns: An array of `Edit` elements.
*/
internal func reducedEdits<C>(_ edits: Array<Edit<C>>) -> Array<Edit<C>> {
	return edits.reduce(Array<Edit<C>>()) { (edits, edit) in
		var reducedEdits = edits
		if let (move, offset) = move(from: edit, in: reducedEdits), case .move = move.operation {
			reducedEdits.remove(at: offset)
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
private func move<C>(from deletionOrInsertion: Edit<C>, `in` edits: Array<Edit<C>>) -> (move: Edit<C>, offset: Edit<C>.Offset)? {
	
	switch deletionOrInsertion.operation {
		
	case .deletion:
		if let insertionOffset = edits.index(where: { (earlierEdit) -> Bool in
			if case .insertion = earlierEdit.operation, earlierEdit.value == deletionOrInsertion.value { return true } else { return false }
		}) {
			return (Edit(.move(origin: deletionOrInsertion.destination), value: deletionOrInsertion.value, destination: edits[insertionOffset].destination), insertionOffset)
		}
		
	case .insertion:
		if let deletionOffset = edits.index(where: { (earlierEdit) -> Bool in
			if case .deletion = earlierEdit.operation, earlierEdit.value == deletionOrInsertion.value { return true } else { return false }
		}) {
			return (Edit(.move(origin: edits[deletionOffset].destination), value: deletionOrInsertion.value, destination: deletionOrInsertion.destination), deletionOffset)
		}
		
	default:
		break
	}
	
	return nil
}

extension Edit: Equatable {}
public func ==<C>(lhs: Edit<C>, rhs: Edit<C>) -> Bool {
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
