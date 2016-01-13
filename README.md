# Changeset

> _[Changeset – pretty awesome little project](https://twitter.com/joeldev/status/685253183992500225)_
> — [Joel Levin](https://github.com/joeldev)

A `Changeset` describes the minimal edits required to go from one `CollectionType` of `Equatable` elements to another. It detects additions, deletions, substitutions, and moves.

This is an attempt at implementing the solution outlined in [Dave DeLong](https://github.com/davedelong)’s article, [Edit distance and edit steps](http://davedelong.tumblr.com/post/134367865668/edit-distance-and-edit-steps).

## Usage

The following code computes the minimal edits going from the `Character` collections “kitten” to “sitting”:

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

Because `Changeset` works on any `CollectionType` of `Equatable`, it has many applications. For example, it could be used to identify the changes needed to go from one array of elements to another, where the elements are instances of a custom `Equatable` class. This is particularly useful if these elements are displayed in a `UITableView`, and you want to animate a transition between two sets of data.

Note, indices are those exactly to be used within a `beginUpdates`/`endUpdates` block on `UITableView`.

In short; first all deletions are made relative to the source collection, then, relative to the resulting collection, insertions and substitutions. A move is just a deletion followed by an insertion on the resulting collection. This is explained in much more detail under [_Batch Insertion, Deletion, and Reloading of Rows and Sections_](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW9) in Apple’s [Table View Programming Guide for iOS](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/AboutTableViewsiPhone/AboutTableViewsiPhone.html).

If you don’t want the overhead of `Changeset` itself, which also stores the source and target collections, you can call `editDistance` directly (here with [example data](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW16)) from Apple’s guide:

```swift
let source = ["Arizona", "California", "Delaware", "New Jersey", "Washington"]
let target = ["Alaska", "Arizona", "California", "Georgia", "New Jersey", "Virginia"]
let edits = Changeset.editDistance(source: source, target: target)

print(edits)
// [insert Alaska at index 0, replace with Georgia at index 3, replace with Virginia at index 5]
```

## License

This project is available under [The MIT License](http://opensource.org/licenses/MIT).  
Copyright © 2015-16, [Joachim Bondo](mailto:joachim@bondo.net). See LICENSE file.
