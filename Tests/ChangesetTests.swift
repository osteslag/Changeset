
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
		
		let changeset = Changeset(source: origin, target: destination)
		
		XCTAssertEqual(String(changeset.origin), origin)
		XCTAssertEqual(String(changeset.destination), destination)
		
		XCTAssertEqual(changeset.edits.count, 3)
	}
	
	func testEquatableEdit() {
		
		let edit1 = Changeset<String>.Edit(operation: .substitution, value: "s", destination: 0)
		let edit2 = Changeset<String>.Edit(operation: .substitution, value: "s", destination: 0)
		let edit3 = Changeset<String>.Edit(operation: .substitution, value: "s", destination: 1)
		let edit4 = Changeset<String>.Edit(operation: .insertion, value: "s", destination: 0)
		let edit5 = Changeset<String>.Edit(operation: .deletion, value: "s", destination: 0)
		let edit6 = Changeset<String>.Edit(operation: .move(origin: 3), value: "s", destination: 0)
		
		XCTAssertEqual(edit1, edit2)
		XCTAssertNotEqual(edit2, edit3)
		XCTAssertNotEqual(edit2, edit4)
		XCTAssertNotEqual(edit2, edit5)
		XCTAssertNotEqual(edit2, edit6)
		XCTAssertNotEqual(edit3, edit4)
		XCTAssertNotEqual(edit3, edit5)
		XCTAssertNotEqual(edit3, edit6)
		XCTAssertNotEqual(edit4, edit5)
		XCTAssertNotEqual(edit4, edit6)
		XCTAssertNotEqual(edit5, edit6)
	}
	
	func testSampleChanges() {
		
		var changeset: Changeset<String>
		var edits: Array<Changeset<String>.Edit>
		
		changeset = Changeset(source: "kitten", target: "sitting")
		edits = [
			Changeset.Edit(operation: .substitution, value: "s", destination: 0),
			Changeset.Edit(operation: .substitution, value: "i", destination: 4),
			Changeset.Edit(operation: .insertion, value: "g", destination: 6),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "sitting", target: "kitten")
		edits = [
			Changeset.Edit(operation: .substitution, value: "k", destination: 0),
			Changeset.Edit(operation: .substitution, value: "e", destination: 4),
			Changeset.Edit(operation: .deletion, value: "g", destination: 6),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "Saturday", target: "Sunday")
		edits = [
			Changeset.Edit(operation: .deletion, value: "a", destination: 1),
			Changeset.Edit(operation: .deletion, value: "t", destination: 2),
			Changeset.Edit(operation: .substitution, value: "n", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "Sunday", target: "Saturday")
		edits = [
			Changeset.Edit(operation: .insertion, value: "a", destination: 1),
			Changeset.Edit(operation: .insertion, value: "t", destination: 2),
			Changeset.Edit(operation: .substitution, value: "r", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "sword", target: "words")
		edits = [
			Changeset.Edit(operation: .move(origin: 0), value: "s", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "words", target: "sword")
		edits = [
			Changeset.Edit(operation: .move(origin: 4), value: "s", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcd", target: "ABCD")
		edits = [
			Changeset.Edit(operation: .substitution, value: "A", destination: 0),
			Changeset.Edit(operation: .substitution, value: "B", destination: 1),
			Changeset.Edit(operation: .substitution, value: "C", destination: 2),
			Changeset.Edit(operation: .substitution, value: "D", destination: 3),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		// GARVEY -> AVERY (http://stackoverflow.com/a/30795531)
		changeset = Changeset(source: "GARVEY", target: "AVERY")
		edits = [
			Changeset.Edit(operation: .deletion, value: "G", destination: 0),
			Changeset.Edit(operation: .move(origin: 2), value: "R", destination: 3),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "AVERY", target: "GARVEY")
		edits = [
			Changeset.Edit(operation: .insertion, value: "G", destination: 0),
			Changeset.Edit(operation: .move(origin: 3), value: "R", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testInsertionsAfterDeletions() {
		
		var changeset: Changeset<String>
		var edits: Array<Changeset<String>.Edit>
		
		changeset = Changeset(source: "abcdefgh", target: "bdefijgh")
		edits = [
			Changeset.Edit(operation: .deletion, value: "a", destination: 0),
			Changeset.Edit(operation: .deletion, value: "c", destination: 2),
			Changeset.Edit(operation: .insertion, value: "i", destination: 4),
			Changeset.Edit(operation: .insertion, value: "j", destination: 5),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "bdefijgh", target: "abcdefgh")
		edits = [
			Changeset.Edit(operation: .insertion, value: "a", destination: 0),
			Changeset.Edit(operation: .insertion, value: "c", destination: 2),
			Changeset.Edit(operation: .deletion, value: "i", destination: 4),
			Changeset.Edit(operation: .deletion, value: "j", destination: 5),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcdefgh", target: "bdefagch")
		edits = [
			Changeset.Edit(operation: .move(origin: 0), value: "a", destination: 4),
			Changeset.Edit(operation: .move(origin: 2), value: "c", destination: 6),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "bdefagch", target: "abcdefgh")
		edits = [
			Changeset.Edit(operation: .move(origin: 4), value: "a", destination: 0),
			Changeset.Edit(operation: .move(origin: 6), value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testComplexChange() {
		
		var changeset: Changeset<String>
		var edits: Array<Changeset<String>.Edit>
		
		changeset = Changeset(source: "abcdefgh", target: "bacefxhi")
		edits = [
			Changeset.Edit(operation: .move(origin: 1), value: "b", destination: 0),
			Changeset.Edit(operation: .deletion, value: "d", destination: 3),
			Changeset.Edit(operation: .substitution, value: "x", destination: 6),
			Changeset.Edit(operation: .insertion, value: "i", destination: 7),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "bacefxhi", target: "abcdefgh")
		edits = [
			Changeset.Edit(operation: .move(origin: 1), value: "a", destination: 0),
			Changeset.Edit(operation: .insertion, value: "d", destination: 3),
			Changeset.Edit(operation: .substitution, value: "g", destination: 5),
			Changeset.Edit(operation: .deletion, value: "i", destination: 7),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testListing7_8() {
		
		// https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW16
		
		let changeset: Changeset<Array<String>>
		let edits: Array<Changeset<Array<String>>.Edit>
		
		let source = ["Arizona", "California", "Delaware", "New Jersey", "Washington"]
		let target = ["Alaska", "Arizona", "California", "Georgia", "New Jersey", "Virginia"]
		
		/* In Apple's example the changeset consists of these five changes:
		       Changeset.Edit(operation: .insertion, value: "Alaska", destination: 0),
		       Changeset.Edit(operation: .deletion, value: "Delaware", destination: 2),
		       Changeset.Edit(operation: .insertion, value: "Georgia", destination: 3),
		       Changeset.Edit(operation: .deletion, value: "Washington", destination: 4),
		       Changeset.Edit(operation: .insertion, value: "Virginia", destination: 5),
		   Changeset reduces this to the following three:*/
		
		changeset = Changeset(source: source, target: target)
		edits = [
			Changeset.Edit(operation: .insertion, value: "Alaska", destination: 0),
			Changeset.Edit(operation: .substitution, value: "Georgia", destination: 2),
			Changeset.Edit(operation: .substitution, value: "Virginia", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testDeLongTweet() {
		
		// https://twitter.com/davedelong/status/671051521371406336
		
		var changeset: Changeset<String>
		var edits: Array<Changeset<String>.Edit>
		
		changeset = Changeset(source: "words", target: "tsword")
		edits = [
			Changeset.Edit(operation: .insertion, value: "t", destination: 0),
			Changeset.Edit(operation: .move(origin: 4), value: "s", destination: 1),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcdefgh", target: "agbcdefh")
		edits = [
			Changeset.Edit(operation: .move(origin: 6), value: "g", destination: 1),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "stick", target: "tact")
		edits = [
			Changeset.Edit(operation: .deletion, value: "s", destination: 0),
			Changeset.Edit(operation: .substitution, value: "a", destination: 2),
			Changeset.Edit(operation: .substitution, value: "t", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "12345", target: "2a3")
		edits = [
			Changeset.Edit(operation: .deletion, value: "1", destination: 0),
			Changeset.Edit(operation: .insertion, value: "a", destination: 1),
			Changeset.Edit(operation: .deletion, value: "4", destination: 3),
			Changeset.Edit(operation: .deletion, value: "5", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "dave", target: "david")
		edits = [
			Changeset.Edit(operation: .substitution, value: "i", destination: 3),
			Changeset.Edit(operation: .insertion, value: "d", destination: 4),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testEmptyStrings() {
		
		var changeset: Changeset<String>
		var edits: Array<Changeset<String>.Edit>
		
		changeset = Changeset(source: "abc", target: "")
		edits = [
			Changeset.Edit(operation: .deletion, value: "a", destination: 0),
			Changeset.Edit(operation: .deletion, value: "b", destination: 1),
			Changeset.Edit(operation: .deletion, value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "", target: "abc")
		edits = [
			Changeset.Edit(operation: .insertion, value: "a", destination: 0),
			Changeset.Edit(operation: .insertion, value: "b", destination: 1),
			Changeset.Edit(operation: .insertion, value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testOneElementChanges() {
		
		var changeset: Changeset<String>
		var edits: Array<Changeset<String>.Edit>
		
		changeset = Changeset(source: " ", target: "a")
		edits = [
			Changeset.Edit(operation: .substitution, value: "a", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "a", target: "")
		edits = [
			Changeset.Edit(operation: .deletion, value: "a", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testInsertions() {
		
		var changeset: Changeset<String>
		var edits: Array<Changeset<String>.Edit>
		
		changeset = Changeset(source: "", target: "a")
		edits = [
			Changeset.Edit(operation: .insertion, value: "a", destination: 0),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "", target: "ab")
		edits = [
			Changeset.Edit(operation: .insertion, value: "a", destination: 0),
			Changeset.Edit(operation: .insertion, value: "b", destination: 1),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "a", target: "bac")
		edits = [
			Changeset.Edit(operation: .insertion, value: "b", destination: 0),
			Changeset.Edit(operation: .insertion, value: "c", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abcdef", target: "aAbBcCdDeEfF")
		edits = [
			Changeset.Edit(operation: .insertion, value: "A", destination: 1),
			Changeset.Edit(operation: .insertion, value: "B", destination: 3),
			Changeset.Edit(operation: .insertion, value: "C", destination: 5),
			Changeset.Edit(operation: .insertion, value: "D", destination: 7),
			Changeset.Edit(operation: .insertion, value: "E", destination: 9),
			Changeset.Edit(operation: .insertion, value: "F", destination: 11),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testMoves() {
		
		var changeset: Changeset<String>
		var edits: Array<Changeset<String>.Edit>
		
		changeset = Changeset(source: "AAAAaaaa", target: "aaaaAAAA")
		edits = [
			Changeset.Edit(operation: .move(origin: 4), value: "a", destination: 0),
			Changeset.Edit(operation: .move(origin: 5), value: "a", destination: 1),
			Changeset.Edit(operation: .move(origin: 6), value: "a", destination: 2),
			Changeset.Edit(operation: .move(origin: 7), value: "a", destination: 3),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "abbcdefgh", target: "acdefgbbh")
		edits = [
			Changeset.Edit(operation: .move(origin: 1), value: "b", destination: 6),
			Changeset.Edit(operation: .move(origin: 2), value: "b", destination: 7),
		]
		XCTAssertEqual(changeset.edits, edits)
		
		changeset = Changeset(source: "acdefgbbh", target: "abbcdefgh")
		edits = [
			Changeset.Edit(operation: .move(origin: 6), value: "b", destination: 1),
			Changeset.Edit(operation: .move(origin: 7), value: "b", destination: 2),
		]
		XCTAssertEqual(changeset.edits, edits)
	}
	
	func testNoChanges() {
		
		var edits = Changeset.edits(from: "", to: "")
		XCTAssertEqual(edits.count, 0)
		
		edits = Changeset.edits(from: "abcd", to: "abcd")
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
			Changeset<Array<URL>>.Edit(operation: .deletion, value: old[0], destination: 0),
			Changeset.Edit(operation: .deletion, value: old[2], destination: 2),
			Changeset.Edit(operation: .insertion, value: new[2], destination: 2),
		]
		XCTAssertEqual(changeset.edits, changes)
	}

	func testCustomComparator() {
		let dontCareAbouA: (Character, Character) -> Bool = {
			if $0 == "a" || $1 == "a" {
				return true
			} else {
				return $0 == $1
			}
		}
		XCTAssertEqual([], Changeset(source: "ab", target: "bb", comparator: dontCareAbouA).edits)

		let alwaysChangeA: (Character, Character) -> Bool = {
			if $0 == "a" || $1 == "a" {
				return false
			} else {
				return $0 == $1
			}
		}
		let edits: [Changeset<String>.Edit] = [Changeset.Edit(operation: .substitution, value: "a", destination: 0)]
		XCTAssertEqual(edits, Changeset(source: "ab", target: "ab", comparator: alwaysChangeA).edits)
	}
}

// MARK: -

extension Changeset.Edit: CustomDebugStringConvertible {
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
