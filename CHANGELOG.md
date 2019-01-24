# Change log

## [v0.3.1] - 2019-01-24

### Fixed
* Fix references to File class constant by Taylor Thurlow (@taylorthurlow)

## [v0.3.0] - 2018-10-20

### Added
* Add #set_from_env for binding keys to environment variables
* Add #env_prefix for setting environment variables prefix
* Add #autoload_env for loading all environment variables
* Add #generate for generating file content from the settings
* Add #alias_setting for aliasing settings
* Add ability to read & write INI file types

### Changed
* Change #fetch to read environment variables before defaults
* Change #fetch to handle aliased settings
* Change to remove stdout output when dependency cannot be loaded
* Change to allow for config files without any extension

## [v0.2.0] - 2018-05-07

### Added
* Add ability to validate values for arbitrarily nested keys

### Changed
* Change to ensure that either value or block is provided when setting a value

## [v0.1.0] - 2018-04-14

* Initial implementation and release

[v0.3.0]: https://github.com/piotrmurach/tty-config/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/piotrmurach/tty-config/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-config/compare/v0.1.0
