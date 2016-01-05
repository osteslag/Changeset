//
//  ChangesetTests.swift
//  Copyright (c) 2015 Joachim Bondo. All rights reserved.
//

import XCTest

class ChangesetTests: XCTestCase {
	
	func testChangesetProperties() {
		
		let origin = "kitten"
		let destination = "sitting"
		
		let changeset = Changeset(source: origin.characters, target: destination.characters)
		
		XCTAssertEqual(String(changeset.origin), origin)
		XCTAssertEqual(String(changeset.destination), destination)
		
		XCTAssertEqual(changeset.edits.count, 3)
	}
	
	func testSampleChanges() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView.Generator.Element>>
		
		changeset = Changeset(source: "kitten".characters, target: "sitting".characters)
		edits = [
			Edit(.Substitution, value: "s", destination: 0),
			Edit(.Substitution, value: "i", destination: 4),
			Edit(.Insertion, value: "g", destination: 6),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "sitting".characters, target: "kitten".characters)
		edits = [
			Edit(.Substitution, value: "k", destination: 0),
			Edit(.Substitution, value: "e", destination: 4),
			Edit(.Deletion, value: "g", destination: 6),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "Saturday".characters, target: "Sunday".characters)
		edits = [
			Edit(.Deletion, value: "a", destination: 1),
			Edit(.Deletion, value: "t", destination: 2),
			Edit(.Substitution, value: "n", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "Sunday".characters, target: "Saturday".characters)
		edits = [
			Edit(.Insertion, value: "a", destination: 1),
			Edit(.Insertion, value: "t", destination: 2),
			Edit(.Substitution, value: "r", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "sword".characters, target: "words".characters)
		edits = [
			Edit(.Move(origin: 0), value: "s", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "words".characters, target: "sword".characters)
		edits = [
			Edit(.Move(origin: 4), value: "s", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcd".characters, target: "ABCD".characters)
		edits = [
			Edit(.Substitution, value: "A", destination: 0),
			Edit(.Substitution, value: "B", destination: 1),
			Edit(.Substitution, value: "C", destination: 2),
			Edit(.Substitution, value: "D", destination: 3),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		// GARVEY -> AVERY (http://stackoverflow.com/a/30795531)
		changeset = Changeset(source: "GARVEY".characters, target: "AVERY".characters)
		edits = [
			Edit(.Deletion, value: "G", destination: 0),
			Edit(.Move(origin: 2), value: "R", destination: 3),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "AVERY".characters, target: "GARVEY".characters)
		edits = [
			Edit(.Insertion, value: "G", destination: 0),
			Edit(.Move(origin: 3), value: "R", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testInsertionsAfterDeletions() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView.Generator.Element>>
		
		changeset = Changeset(source: "abcdefgh".characters, target: "bdefijgh".characters)
		edits = [
			Edit(.Deletion, value: "a", destination: 0),
			Edit(.Deletion, value: "c", destination: 2),
			Edit(.Insertion, value: "i", destination: 4),
			Edit(.Insertion, value: "j", destination: 5),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "bdefijgh".characters, target: "abcdefgh".characters)
		edits = [
			Edit(.Insertion, value: "a", destination: 0),
			Edit(.Insertion, value: "c", destination: 2),
			Edit(.Deletion, value: "i", destination: 4),
			Edit(.Deletion, value: "j", destination: 5),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcdefgh".characters, target: "bdefagch".characters)
		edits = [
			Edit(.Move(origin: 0), value: "a", destination: 4),
			Edit(.Move(origin: 2), value: "c", destination: 6),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "bdefagch".characters, target: "abcdefgh".characters)
		edits = [
			Edit(.Move(origin: 4), value: "a", destination: 0),
			Edit(.Move(origin: 6), value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testEmptyStrings() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView.Generator.Element>>
		
		changeset = Changeset(source: "abc".characters, target: "".characters)
		edits = [
			Edit(.Deletion, value: "a", destination: 0),
			Edit(.Deletion, value: "b", destination: 1),
			Edit(.Deletion, value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "".characters, target: "abc".characters)
		edits = [
			Edit(.Insertion, value: "a", destination: 0),
			Edit(.Insertion, value: "b", destination: 1),
			Edit(.Insertion, value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testOneElementChanges() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView.Generator.Element>>
		
		changeset = Changeset(source: " ".characters, target: "a".characters)
		edits = [
			Edit(.Substitution, value: "a", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "a".characters, target: "".characters)
		edits = [
			Edit(.Deletion, value: "a", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testInsertions() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView.Generator.Element>>
		
		changeset = Changeset(source: "".characters, target: "a".characters)
		edits = [
			Edit(.Insertion, value: "a", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "".characters, target: "ab".characters)
		edits = [
			Edit(.Insertion, value: "a", destination: 0),
			Edit(.Insertion, value: "b", destination: 1),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "a".characters, target: "bac".characters)
		edits = [
			Edit(.Insertion, value: "b", destination: 0),
			Edit(.Insertion, value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcdef".characters, target: "aAbBcCdDeEfF".characters)
		edits = [
			Edit(.Insertion, value: "A", destination: 1),
			Edit(.Insertion, value: "B", destination: 3),
			Edit(.Insertion, value: "C", destination: 5),
			Edit(.Insertion, value: "D", destination: 7),
			Edit(.Insertion, value: "E", destination: 9),
			Edit(.Insertion, value: "F", destination: 11),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testMoves() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView.Generator.Element>>
		
		changeset = Changeset(source: "AAAAaaaa".characters, target: "aaaaAAAA".characters)
		edits = [
			Edit(.Move(origin: 4), value: "a", destination: 0),
			Edit(.Move(origin: 5), value: "a", destination: 1),
			Edit(.Move(origin: 6), value: "a", destination: 2),
			Edit(.Move(origin: 7), value: "a", destination: 3),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abbcdefgh".characters, target: "acdefgbbh".characters)
		edits = [
			Edit(.Move(origin: 1), value: "b", destination: 6),
			Edit(.Move(origin: 2), value: "b", destination: 7),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "acdefgbbh".characters, target: "abbcdefgh".characters)
		edits = [
			Edit(.Move(origin: 6), value: "b", destination: 1),
			Edit(.Move(origin: 7), value: "b", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testNoChanges() {
		
		var edits = Changeset.editDistance(source: "".characters, target: "".characters)
		XCTAssertEqual(edits.count, 0)
		
		edits = Changeset.editDistance(source: "abcd".characters, target: "abcd".characters)
		XCTAssertEqual(edits.count, 0)
	}
	
	func testArrayChanges() {
		
		let old = [
			NSURL(string: "http://a.b.c")!,
			NSURL(string: "http://d.e.f")!,
			NSURL(string: "http://k.l.m")!,
			NSURL(string: "http://x.y.z")!,
		]
		let new = [
			NSURL(string: "http://d.e.f")!,
			NSURL(string: "http://x.y.z")!,
			NSURL(string: "http://h.i.j")!,
		]
		
		let changeset = Changeset(source: old, target: new)
		let changes = [
			Edit(.Deletion, value: NSURL(string: "http://a.b.c")!, destination: 0),
			Edit(.Deletion, value: NSURL(string: "http://k.l.m")!, destination: 2),
			Edit(.Insertion, value: NSURL(string: "http://h.i.j")!, destination: 2),
		]
		XCTAssertEqual(changeset.edits, changes)
	}
}

// MARK: -

extension Edit: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self.operation {
		case .Insertion:
			return "insert \(self.value) at index \(self.destination)"
		case .Deletion:
			return "delete \(self.value) at index \(self.destination)"
		case .Substitution:
			return "replace with \(self.value) at index \(self.destination)"
		case .Move(let origin):
			return "move \(self.value) from index \(origin) to \(self.destination)"
		}
	}
}

extension Changeset: CustomDebugStringConvertible {
	public var debugDescription: String {
		
		let origin = self.origin.reduce("") { $0 + String($1) }
		let destination = self.destination.reduce("") { $0 + String($1) }
		
		var text = "'\(origin)' -> '\(destination)':"
		for change in self.edits {
			text += "\n\t\(change)"
		}
		return text
	}
}
