
//
//  ChangesetTests.swift
//  Changeset
//

import XCTest
import Changeset

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
		var edits: Array<Edit<String.CharacterView>>
		
		changeset = Changeset(source: "kitten".characters, target: "sitting".characters)
		edits = [
			Edit(operation: .substitution, value: "s", destination: 0),
			Edit(operation: .substitution, value: "i", destination: 4),
			Edit(operation: .insertion, value: "g", destination: 6),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "sitting".characters, target: "kitten".characters)
		edits = [
			Edit(operation: .substitution, value: "k", destination: 0),
			Edit(operation: .substitution, value: "e", destination: 4),
			Edit(operation: .deletion, value: "g", destination: 6),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "Saturday".characters, target: "Sunday".characters)
		edits = [
			Edit(operation: .deletion, value: "a", destination: 1),
			Edit(operation: .deletion, value: "t", destination: 2),
			Edit(operation: .substitution, value: "n", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "Sunday".characters, target: "Saturday".characters)
		edits = [
			Edit(operation: .insertion, value: "a", destination: 1),
			Edit(operation: .insertion, value: "t", destination: 2),
			Edit(operation: .substitution, value: "r", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "sword".characters, target: "words".characters)
		edits = [
			Edit(operation: .move(origin: 0), value: "s", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "words".characters, target: "sword".characters)
		edits = [
			Edit(operation: .move(origin: 4), value: "s", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcd".characters, target: "ABCD".characters)
		edits = [
			Edit(operation: .substitution, value: "A", destination: 0),
			Edit(operation: .substitution, value: "B", destination: 1),
			Edit(operation: .substitution, value: "C", destination: 2),
			Edit(operation: .substitution, value: "D", destination: 3),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		// GARVEY -> AVERY (http://stackoverflow.com/a/30795531)
		changeset = Changeset(source: "GARVEY".characters, target: "AVERY".characters)
		edits = [
			Edit(operation: .deletion, value: "G", destination: 0),
			Edit(operation: .move(origin: 2), value: "R", destination: 3),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "AVERY".characters, target: "GARVEY".characters)
		edits = [
			Edit(operation: .insertion, value: "G", destination: 0),
			Edit(operation: .move(origin: 3), value: "R", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testInsertionsAfterDeletions() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView>>
		
		changeset = Changeset(source: "abcdefgh".characters, target: "bdefijgh".characters)
		edits = [
			Edit(operation: .deletion, value: "a", destination: 0),
			Edit(operation: .deletion, value: "c", destination: 2),
			Edit(operation: .insertion, value: "i", destination: 4),
			Edit(operation: .insertion, value: "j", destination: 5),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "bdefijgh".characters, target: "abcdefgh".characters)
		edits = [
			Edit(operation: .insertion, value: "a", destination: 0),
			Edit(operation: .insertion, value: "c", destination: 2),
			Edit(operation: .deletion, value: "i", destination: 4),
			Edit(operation: .deletion, value: "j", destination: 5),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcdefgh".characters, target: "bdefagch".characters)
		edits = [
			Edit(operation: .move(origin: 0), value: "a", destination: 4),
			Edit(operation: .move(origin: 2), value: "c", destination: 6),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "bdefagch".characters, target: "abcdefgh".characters)
		edits = [
			Edit(operation: .move(origin: 4), value: "a", destination: 0),
			Edit(operation: .move(origin: 6), value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testComplexChange() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView>>
		
		changeset = Changeset(source: "abcdefgh".characters, target: "bacefxhi".characters)
		edits = [
			Edit(operation: .move(origin: 1), value: "b", destination: 0),
			Edit(operation: .deletion, value: "d", destination: 3),
			Edit(operation: .substitution, value: "x", destination: 6),
			Edit(operation: .insertion, value: "i", destination: 7),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "bacefxhi".characters, target: "abcdefgh".characters)
		edits = [
			Edit(operation: .move(origin: 1), value: "a", destination: 0),
			Edit(operation: .insertion, value: "d", destination: 3),
			Edit(operation: .substitution, value: "g", destination: 5),
			Edit(operation: .deletion, value: "i", destination: 7),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testListing7_8() {
		
		// https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW16
		
		let changeset: Changeset<Array<String>>
		let edits: Array<Edit<Array<String>>>
		
		let source = ["Arizona", "California", "Delaware", "New Jersey", "Washington"]
		let target = ["Alaska", "Arizona", "California", "Georgia", "New Jersey", "Virginia"]
		
		/* In Apple's example the changeset consists of these five changes:
		       Edit(operation: .insertion, value: "Alaska", destination: 0),
		       Edit(operation: .deletion, value: "Delaware", destination: 2),
		       Edit(operation: .insertion, value: "Georgia", destination: 3),
		       Edit(operation: .deletion, value: "Washington", destination: 4),
		       Edit(operation: .insertion, value: "Virginia", destination: 5),
		   Changeset reduces this to the following three:*/
		
		changeset = Changeset(source: source, target: target)
		edits = [
			Edit(operation: .insertion, value: "Alaska", destination: 0),
			Edit(operation: .substitution, value: "Georgia", destination: 2),
			Edit(operation: .substitution, value: "Virginia", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testDeLongTweet() {
		
		// https://twitter.com/davedelong/status/671051521371406336
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView>>
		
		changeset = Changeset(source: "words".characters, target: "tsword".characters)
		edits = [
			Edit(operation: .insertion, value: "t", destination: 0),
			Edit(operation: .move(origin: 4), value: "s", destination: 1),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcdefgh".characters, target: "agbcdefh".characters)
		edits = [
			Edit(operation: .move(origin: 6), value: "g", destination: 1),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "stick".characters, target: "tact".characters)
		edits = [
			Edit(operation: .deletion, value: "s", destination: 0),
			Edit(operation: .substitution, value: "a", destination: 2),
			Edit(operation: .substitution, value: "t", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "12345".characters, target: "2a3".characters)
		edits = [
			Edit(operation: .deletion, value: "1", destination: 0),
			Edit(operation: .insertion, value: "a", destination: 1),
			Edit(operation: .deletion, value: "4", destination: 3),
			Edit(operation: .deletion, value: "5", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "dave".characters, target: "david".characters)
		edits = [
			Edit(operation: .substitution, value: "i", destination: 3),
			Edit(operation: .insertion, value: "d", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testEmptyStrings() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView>>
		
		changeset = Changeset(source: "abc".characters, target: "".characters)
		edits = [
			Edit(operation: .deletion, value: "a", destination: 0),
			Edit(operation: .deletion, value: "b", destination: 1),
			Edit(operation: .deletion, value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "".characters, target: "abc".characters)
		edits = [
			Edit(operation: .insertion, value: "a", destination: 0),
			Edit(operation: .insertion, value: "b", destination: 1),
			Edit(operation: .insertion, value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testOneElementChanges() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView>>
		
		changeset = Changeset(source: " ".characters, target: "a".characters)
		edits = [
			Edit(operation: .substitution, value: "a", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "a".characters, target: "".characters)
		edits = [
			Edit(operation: .deletion, value: "a", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testInsertions() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView>>
		
		changeset = Changeset(source: "".characters, target: "a".characters)
		edits = [
			Edit(operation: .insertion, value: "a", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "".characters, target: "ab".characters)
		edits = [
			Edit(operation: .insertion, value: "a", destination: 0),
			Edit(operation: .insertion, value: "b", destination: 1),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "a".characters, target: "bac".characters)
		edits = [
			Edit(operation: .insertion, value: "b", destination: 0),
			Edit(operation: .insertion, value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcdef".characters, target: "aAbBcCdDeEfF".characters)
		edits = [
			Edit(operation: .insertion, value: "A", destination: 1),
			Edit(operation: .insertion, value: "B", destination: 3),
			Edit(operation: .insertion, value: "C", destination: 5),
			Edit(operation: .insertion, value: "D", destination: 7),
			Edit(operation: .insertion, value: "E", destination: 9),
			Edit(operation: .insertion, value: "F", destination: 11),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testMoves() {
		
		var changeset: Changeset<String.CharacterView>
		var edits: Array<Edit<String.CharacterView>>
		
		changeset = Changeset(source: "AAAAaaaa".characters, target: "aaaaAAAA".characters)
		edits = [
			Edit(operation: .move(origin: 4), value: "a", destination: 0),
			Edit(operation: .move(origin: 5), value: "a", destination: 1),
			Edit(operation: .move(origin: 6), value: "a", destination: 2),
			Edit(operation: .move(origin: 7), value: "a", destination: 3),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abbcdefgh".characters, target: "acdefgbbh".characters)
		edits = [
			Edit(operation: .move(origin: 1), value: "b", destination: 6),
			Edit(operation: .move(origin: 2), value: "b", destination: 7),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "acdefgbbh".characters, target: "abbcdefgh".characters)
		edits = [
			Edit(operation: .move(origin: 6), value: "b", destination: 1),
			Edit(operation: .move(origin: 7), value: "b", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testNoChanges() {
		
		var edits = Changeset.edits(from: "".characters, to: "".characters)
		XCTAssertEqual(edits.count, 0)
		
		edits = Changeset.edits(from: "abcd".characters, to: "abcd".characters)
		XCTAssertEqual(edits.count, 0)
	}
	
	func testArrayChanges() {
		
		let old = [
			URL(string: "http://a.b.c")!,
			URL(string: "http://d.e.f")!,
			URL(string: "http://k.l.m")!,
			URL(string: "http://x.y.z")!,
		]
		let new = [
			URL(string: "http://d.e.f")!,
			URL(string: "http://x.y.z")!,
			URL(string: "http://h.i.j")!,
		]
		
		let changeset = Changeset(source: old, target: new)
		let changes = [
			Edit<Array<URL>>(operation: .deletion, value: old[0], destination: 0),
			Edit(operation: .deletion, value: old[2], destination: 2),
			Edit(operation: .insertion, value: new[2], destination: 2),
		]
		XCTAssertEqual(changeset.edits, changes)
	}
}

// MARK: -

extension Edit: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self.operation {
		case .insertion:
			return "insert \(self.value) at offset \(self.destination)"
		case .deletion:
			return "delete \(self.value) at offset \(self.destination)"
		case .substitution:
			return "replace with \(self.value) at offset \(self.destination)"
		case .move(let origin):
			return "move \(self.value) from offset \(origin) to \(self.destination)"
		}
	}
}

extension Changeset: CustomDebugStringConvertible {
	public var debugDescription: String {
		
		let origin = self.origin.reduce("") { $0 + String(describing: $1) }
		let destination = self.destination.reduce("") { $0 + String(describing: $1) }
		
		var text = "'\(origin)' -> '\(destination)':"
		for change in self.edits {
			text += "\n\t\(change)"
		}
		return text
	}
}
