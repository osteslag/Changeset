# Change Log

This project uses [semantic versioning](http://semver.org/). Change log is also reflected under [Releases](https://github.com/osteslag/Changeset/releases) on GitHub, inspired by [Keep a CHANGELOG](http://keepachangelog.com).

## [3.1]: 2018-03-14(π) Custom Comparator
### Added
- Support custom comparator function for comparing collection elements (defaults to `==`)

## [3.0]: 2017-11-03 Swift 4.0
### Changed
- Update to Swift 4; most noticeably, `String` is now a `Collection`
- Make `Edit` a subtype of `Changeset` so that it inherits the same generic constraints
- Make `Operation` a subtype of `Edit`
- Use offsets on changeset collections, as opposed to indices
- Use labels on all initializer parameters (per Swift convention)
- 100% code coverage on unit tests

## [2.1.2]: 2017-03-27 Reduce Memory Footprint
### Fixed
- Reduce space complexity to O(m)
- Expand variable names for readability

## [2.1.1]: 2017-03-21 Suppress Warning
### Fixed 
- Allow Changeset to be used from within a framework, and outside of an application target.

## [2.1]: 2016-11-23 UIKit Extensions
### Added
- UIKit extensions for `UITableView` and `UICollectionView` for easy updating (were previously only included in the test app)

## [2.0.1]: 2016-10-20 Automatic Provisioning
### Changed
- Framework target set to automatically manage code signing.

## [2.0]: 2016-10-12 Swift 3
### Changed
- Project defaults to Swift 3 (use the [`swift-2`](https://github.com/osteslag/Changeset/tree/swift-2) tag to stay on Swift 2).
- Renamed `editDistance(source:target:)` on `Changeset` to the Swift 3-friendly `edits(from:to:)`.
- Updated Quick Help documentation slightly.

## [1.0.6]: 2016-10-12 tvOS
### Added
- Support tvOS.

## [1.0.5]: 2016-05-22 Swift 3.0, SPM Compatibility
### Fixed
- Remove use of deprecated `var` parameters.
### Changed
- Rearrange repository layout to support the upcoming [Swift Package Manager](https://swift.org/package-manager/) (experimental).

## [1.0.4]: 2016-03-11 Table/Collection View Compatibility
### Fixed
- Express `.Substitution` indices relative to the source collection (again).
### Changed
- Update tests to reflect changed indices.
### Added
- Add iOS target to illustrate `Changeset` usage in an app.
- Add extension to `UITableView` and `UICollectionView` for animating `Changeset` edits.

## [1.0.3]: 2016-01-22 MIT License
### Changed
- Move license from BSD to MIT.

## [1.0.2]: 2016-01-05 Insertion Indices
### Fixed
- Fix `Changeset.editDistance` to have `.Insertion` indices point into the target collection.
- Update tests to reflect changed indices.

## [1.0.1]: 2015-12-29 Swift 3.0 Compliance
### Changed
- Remove `++` increment, will go away in Swift 3.0.

## [1.0]: 2015-12-29 Initial Release

[3.1]: https://github.com/osteslag/Changeset/compare/v3.0...v3.1
[3.0]: https://github.com/osteslag/Changeset/compare/v2.1.2...v3.0
[2.1.2]: https://github.com/osteslag/Changeset/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/osteslag/Changeset/compare/v2.1...v2.1.1
[2.1]: https://github.com/osteslag/Changeset/compare/v2.0.1...v2.1
[2.0.1]: https://github.com/osteslag/Changeset/compare/v2.0...v2.0.1
[2.0]: https://github.com/osteslag/Changeset/compare/v1.0.6...v2.0
[1.0.6]: https://github.com/osteslag/Changeset/compare/v1.0.5...v1.0.6
[1.0.5]: https://github.com/osteslag/Changeset/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/osteslag/Changeset/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/osteslag/Changeset/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/osteslag/Changeset/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/osteslag/Changeset/compare/v1.0...v1.0.1
[1.0]: https://github.com/osteslag/Changeset/tree/v1.0
