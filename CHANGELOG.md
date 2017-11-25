# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- for new features.
### Changed
- for changes in existing functionality.
### Deprecated
- for once-stable features removed in upcoming releases.
### Removed
- for deprecated features removed in this release.
### Fixed
- for any bug fixes.
### Security
- to invite users to upgrade in case of vulnerabilities.

## [1.0.0] - 2017-11-25
### Added
- findById method finds an entity by UUID
- Call to super in World constructor

### Changed
- Allow data to be directly assigned to components
- index.js to import ecs module, not just World
- Name of package from node-ecs to index-ecs for npm publication
- .gitignore to GitHub supplied version for Node

### Fixed
- Dependencies in package.json; updated to CoffeeScript 2

## [0.0.4] - 2017-03-25
### Added
- index.js to allow Node.js to require() the module

## [0.0.3] - 2017-03-25
### Added
- CHANGELOG.md to record changes to the library
- README.md contains full documentation, including API

### Changed
- Internal 'uuid' index of World refactored to standard Index
- World method call parameters and event calls given a consistent order
- Test suite for World completely redone from scratch

### Removed
- hello and helloTest; they aren't needed in the library

## [0.0.2] - 2017-03-22
### Added
- Basic Entity-Component-System implementation

## 0.0.1 - 2017-03-22
### Added
- Initial project structure

[Unreleased]: https://github.com/blinkdog/node-ecs/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/blinkdog/node-ecs/compare/v0.0.4...v1.0.0
[0.0.4]: https://github.com/blinkdog/node-ecs/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/blinkdog/node-ecs/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/blinkdog/node-ecs/compare/v0.0.1...v0.0.2
