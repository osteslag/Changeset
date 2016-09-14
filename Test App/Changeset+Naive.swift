//
//  Changeset+Naive.swift
//  Changeset
//
//  Created by Bart Whiteley on 2/12/16.

import Changeset

extension Changeset {

	public static func naiveEditDistance(source s: T, target t: T) -> [Edit<T.Iterator.Element>] {

		var rv:[Edit<T.Generator.Element>] = []

		for (oldIndex, item) in s.enumerated() {
			guard let newIndex = t.index(of: item) else {
				rv.append(Edit(.deletion, value:item, destination:oldIndex))
				continue
			}
			let newIndexI = t.distance(from: t.startIndex, to: newIndex)
			if newIndexI != oldIndex {
				rv.append(Edit(.move(origin: oldIndex), value:item, destination:newIndexI))
			}
		}

		for (newIndex, item) in t.enumerated() {
			if !s.contains(item) {
				rv.append(Edit(.insertion, value:item, destination:newIndex))
			}
		}

		return rv
	}
}
