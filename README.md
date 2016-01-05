# Changeset

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

This project is available under the [BSD 2-Clause “Simplified” License](http://www.opensource.org/licenses/BSD-2-Clause):

Copyright (c) 2015, Joachim Bondo  
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.