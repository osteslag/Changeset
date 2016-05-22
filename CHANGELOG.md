# Change Log

This project uses [semantic versioning](http://semver.org/). Change log is also reflected under [Releases](https://github.com/osteslag/Changeset/releases) on GitHub, inspired by [Keep a CHANGELOG](http://keepachangelog.com).

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

[1.0.5]: https://github.com/osteslag/Changeset/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/osteslag/Changeset/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/osteslag/Changeset/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/osteslag/Changeset/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/osteslag/Changeset/compare/v1.0...v1.0.1
[1.0]: https://github.com/osteslag/Changeset/tree/v1.0
