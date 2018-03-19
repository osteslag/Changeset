# Changeset

> _[Changeset – pretty awesome little project](https://twitter.com/joeldev/status/685253183992500225)_  
> — [Joel Levin](https://github.com/joeldev)

This is an attempt at implementing the solution outlined in [Dave DeLong](https://github.com/davedelong)’s article, [Edit distance and edit steps](http://davedelong.tumblr.com/post/134367865668/edit-distance-and-edit-steps).

A `Changeset` describes the minimal edits required to go from one `Collection` of `Equatable` elements to another.

It has been written primarily to be used in conjunction with `UITableView` and `UICollectionView` data sources by detecting additions, deletions, substitutions, and moves between the two sets of data. But it can also be used to compute more general changes between two data sets.

## Usage

The following code computes the minimal edits of the canonical example, going from the `String` collections “kitten” to “sitting”:

```swift
let changeset = Changeset(source: "kitten", target: "sitting")

print(changeset)
// 'kitten' -> 'sitting':
//     replace with s at offset 0
//     replace with i at offset 4
//     insert g at offset 6
```

The following assertion would then succeed:

```swift
let edits = [
    Changeset<String>.Edit(operation: .substitution, value: "s", destination: 0),
    Changeset<String>.Edit(operation: .substitution, value: "i", destination: 4),
    Changeset<String>.Edit(operation: .insertion, value: "g", destination: 6),
]
assert(changeset.edits == edits)
```

If you don’t want the overhead of `Changeset` itself, which also stores the source and target collections, you can call `edits` directly (here with [example data](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW16) from Apple’s [Table View Programming Guide for iOS](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/AboutTableViewsiPhone/AboutTableViewsiPhone.html)):

```swift
let source = ["Arizona", "California", "Delaware", "New Jersey", "Washington"]
let target = ["Alaska", "Arizona", "California", "Georgia", "New Jersey", "Virginia"]
let edits = Changeset.edits(from: source, to: target)

print(edits)
// [insert Alaska at offset 0, replace with Georgia at offset 2, replace with Virginia at offset 4]
```

Note that Changeset uses offsets, not indices, to refer to elements in the collections. This is mainly because Swift collections aren’t guaranteed to use zero-based integer indices. See discussion in [issue #37](https://github.com/osteslag/Changeset/issues/37) for more details.

## UIKit Integration

The offset values can be used directly in the animation blocks of `beginUpdates`/`endUpdates` on `UITableView` and `performBatchUpdates` on `UICollectionView` in that `Changeset` follows the principles explained under [_Batch Insertion, Deletion, and Reloading of Rows and Sections_](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW9) in Apple’s guide.

In short; first all deletions and substitutions are made, relative to the source collection, then, relative to the resulting collection, insertions. A move is just a deletion followed by an insertion.

In the iOS framework, two convenience extensions (one on `UITableView` and one on `UICollectionView`) have been included to make animated table/collection view updates a breeze. Just call `update`, like this:

```swift
tableView.update(with: edits, in: 0)
```

## Custom Comparator

By default a `Changeset` uses `==` to compare elements, but you can write your own comparator, illustrated below, where the occurence of an “a” always triggers a change:

```swift
let alwaysChangeA: (Character, Character) -> Bool = {
    if $0 == "a" || $1 == "a" {
        return false
    } else {
        return $0 == $1
    }
}
let changeset = Changeset(source: "ab", target: "ab", comparator: alwaysChangeA)
```

As a result, the changeset will consist of a substitution of the “a” (to another “a”):

```swift
let expectedEdits: [Changeset<String>.Edit] = [Changeset.Edit(operation: .substitution, value: "a", destination: 0)]
assert(changeset.edits == expectedEdits)
```

One possible use of this is when a cell in a `UITableView` or `UICollectionView` shouldn’t animate when they change.

## Test App

The Xcode project also contains a target to illustrate the usage in an app:

![Test App](Test%20App/Screen.gif "Test App")

This uses the extensions mentioned above to animate transitions based on the edits of a `Changeset`.

## License

This project is available under [The MIT License](http://opensource.org/licenses/MIT).  
Copyright © 2015-18, [Joachim Bondo](mailto:joachim@bondo.net). See [LICENSE](LICENSE.md) file.
