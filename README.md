# Changeset

> _[Changeset – pretty awesome little project](https://twitter.com/joeldev/status/685253183992500225)_  
> — [Joel Levin](https://github.com/joeldev)

This is an attempt at implementing the solution outlined in [Dave DeLong](https://github.com/davedelong)’s article, [Edit distance and edit steps](http://davedelong.tumblr.com/post/134367865668/edit-distance-and-edit-steps).

A `Changeset` describes the minimal edits required to go from one `Collection` of `Equatable` elements to another.

It has been written specifically to be used in conjunction with `UITableView` and `UICollectionView` data sources by detecting additions, deletions, substitutions, and moves between the two sets of data.

## Usage

The following code computes the minimal edits of the canonical example, going from the `Character` collections “kitten” to “sitting”:

```swift
let changeset = Changeset(source: "kitten".characters, target: "sitting".characters)

print(changeset)
// 'kitten' -> 'sitting':
//     replace with s at index 0
//     replace with i at index 4
//     insert g at index 6
```

The following assertion would then succeed:

```swift
let edits = [
    Edit(.Substitution, value: "s", destination: 0),
    Edit(.Substitution, value: "i", destination: 4),
    Edit(.Insertion, value: "g", destination: 6),
]
assert(changeset.edits == edits)
```

If you don’t want the overhead of `Changeset` itself, which also stores the source and target collections, you can call `edits` directly (here with [example data](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW16) from Apple’s [Table View Programming Guide for iOS](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/AboutTableViewsiPhone/AboutTableViewsiPhone.html)):

```swift
let source = ["Arizona", "California", "Delaware", "New Jersey", "Washington"]
let target = ["Alaska", "Arizona", "California", "Georgia", "New Jersey", "Virginia"]
let edits = Changeset.edits(from: source, to: target)

print(edits)
// [insert Alaska at index 0, replace with Georgia at index 2, replace with Virginia at index 4]
```

## UIKit Integration

The index values can be used directly in the animation blocks of `beginUpdates`/`endUpdates` on `UITableView` and `performBatchUpdates` on `UICollectionView` in that `Changeset` follows the principles explained under [_Batch Insertion, Deletion, and Reloading of Rows and Sections_](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW9) in Apple’s guide.

In short; first all deletions and substitutions are made, relative to the source collection, then, relative to the resulting collection, insertions. A move is just a deletion followed by an insertion.

In the iOS framework, two convenience extensions (one on `UITableView` and one on `UICollectionView`) have been included to make animated table/collection view updates a breeze. Just call `update`, like this:

```swift
tableView.update(with: changeset.edits)
```
  
## Test App

The Xcode project also contains a target to illustrate the usage in an app:

![Test App](Test\ App/Screen.gif "Test App")

This uses the extensions mentioned above to animate transitions based on the edits of a `Changeset`.

## License

This project is available under [The MIT License](http://opensource.org/licenses/MIT).  
Copyright © 2015-16, [Joachim Bondo](mailto:joachim@bondo.net). See [LICENSE](LICENSE.md) file.
