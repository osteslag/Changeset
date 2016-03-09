//
//  Changeset+Naive.swift
//  Changeset
//
//  Created by Bart Whiteley on 2/12/16.

import Changeset

extension Changeset {
	
	public static func naiveEditDistance(source s: T, target t: T) -> [Edit<T.Generator.Element>] {
		
		var rv:[Edit<T.Generator.Element>] = []
		
		for (oldIndex, item) in s.enumerate() {
			guard let newIndex = t.indexOf(item) else {
				rv.append(Edit(.Deletion, value:item, destination:oldIndex))
				continue
			}
			let newIndexI = t.startIndex.distanceTo(newIndex)
			if newIndexI != oldIndex {
				rv.append(Edit(.Move(origin: oldIndex), value:item, destination:newIndexI))
			}
		}
		
		for (newIndex, item) in t.enumerate() {
			if !s.contains(item) {
				rv.append(Edit(.Insertion, value:item, destination:newIndex))
			}
		}
		
		return rv
	}
}
