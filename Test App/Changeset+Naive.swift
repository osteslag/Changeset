//
//  Changeset+Naive.swift
//  Changeset
//
//  Created by Bart Whiteley on 2/12/16.

import Changeset

extension Changeset {
	
	public static func naiveEditDistance(source s: T, target t: T) -> [Edit<T>] {
		
		var rv: [Edit<T>] = []
		
		for (oldOffset, item) in s.enumerated() {
			guard let newOffset = t.index(of: item) else {
				rv.append(Edit(.deletion, value:item, destination:oldOffset))
				continue
			}
			let newOffsetI = t.distance(from: t.startIndex, to: newOffset)
			if newOffsetI != oldOffset {
				rv.append(Edit(.move(origin: oldOffset), value:item, destination:newOffsetI))
			}
		}
		
		for (newOffset, item) in t.enumerated() {
			if !s.contains(item) {
				rv.append(Edit(.insertion, value:item, destination:newOffset))
			}
		}
		
		return rv
	}
}
