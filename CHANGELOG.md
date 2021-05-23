# Change log

## [v0.5.0] - 2021-05-23

### Added
* Add :create option to the #write method to control creating any missing directories
* Add :path option to the #write method to specify a custom file path to write to
* Add ability to specify a default value for a missing key in the #delete method
* Add #env_separator for setting a string to separate parts in environment variable name

### Changed
* Change #delete to allow removing any subkey of a deeply nested key
* Change #remove to require from keyword
* Change #set_if_empty to use nested key fetching to check for value presence

### Fixed
* Fix Marshaller interface to copy extension names to a subclass

## [v0.4.0] - 2020-01-25

### Added
* Add DependencyLoader for a generic interface for loading marshalling dependencies
* Add Marshaller as a generic interface for building marshalling plugins
* Add MarshallerRegistry for storing all marshallers
* Add Marshallers to allow configuration of marshallers via #register_marshaller
  & #unregister_marshaller

### Changed
* Change #initialize to accept hash as settings
* Change #marshal & #unmarshal to use marshalling plugins
* Change gemspec to add metadata and remove test artefacts

## [v0.3.2] - 2019-06-18

### Changed
* Change to relax development dependency versions

### Fixed
* Fix #read to allow reading empty files

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

[v0.5.0]: https://github.com/piotrmurach/tty-config/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/piotrmurach/tty-config/compare/v0.3.2...v0.4.0
[v0.3.2]: https://github.com/piotrmurach/tty-config/compare/v0.3.1...v0.3.2
[v0.3.1]: https://github.com/piotrmurach/tty-config/compare/v0.3.0...v0.3.1
[v0.3.0]: https://github.com/piotrmurach/tty-config/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/piotrmurach/tty-config/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-config/compare/19cd277...v0.1.0
