# Changelog
## Version NEXT
* Convert to using zeitwerk for loading
* Update all ruby dependencies
* Switch to [marcel](https://github.com/rails/marcel) for mime type detection
* Rework maintenance scripts
* Switch to [tabler icons](https://tabler.io/icons)
* Update the embedded pico-css versino
* Full rubocop sweep
* Lots of Internal refactoring

## Version 4.0.1 - 2024-03-03
* Update all dependencies
* update test versions of ruby
* fix a couple of tests

## Version 4.0.0 - 2023-04-11
* Update all dependencies
* ruby 3.0 minimum dependencies
* redesign the directory browser screen
* switch to [rouge](https://github.com/rouge-ruby/rouge) for syntax highlighting

## Version 3.2.1 - 2018-09-27
* fix pume dependency - it was too constrainted

## Version 3.2.0 - 2018-03-14
* fix missing rack dependency [#17](https://github.com/copiousfreetime/heel/pull/17)
* across the board gem dependency updates
* ruby 2.2 minimum dependency - because of transitive dependencies

## Version 3.1.3 - 2013-11-26
* URL encode the links to files [#14](https://github.com/copiousfreetime/heel/issues/14)
* Fix pid file cleanup on ruby 2.0 [#15](https://github.com/copiousfreetime/heel/issues/15)

## Version 3.1.2 - 2013-10-16
* Fix usage of Mime::Types [#12](https://github.com/copiousfreetime/heel/issues/12) [#13](https://github.com/copiousfreetime/heel/issues/13)

## Version 3.1.1 - 2013-09-29
* Fix request logging [#10](https://github.com/copiousfreetime/heel/issues/10)

## Version 3.1.0 - 2013-07-07
* Update dependencies
* Switch to template contributed by brianflanagan [#8](https://github.com/copiousfreetime/heel/issues/8)
* Add support for multiple independent heel servers [#9](https://github.com/copiousfreetime/heel/issues/9)

## Version 3.0.2 - 2013-03-13

* Fix generated pages to say they are utf-8 [#4](https://github.com/copiousfreetime/heel#4)
* Fix formatting of usage section of documentation
* Update dependencies
* Convert to RDoc 4.0

## Version 3.0.1 - 2013-02-06

* Switch to using puma for the webserver
* Switch to using simplecov for coverage testing
* Update all gem dependencies
* Update to fixme project template
* Convert to minitest

## Version 2.1.0 - 2011-03-17

* Update to Launchy 1.0.0
* Update to Thin 1.2.8

## Version 2.0.0 - 2009-06-24

* Change highlighting mode default to 'off' instead of 'on'
* Update for Thin 1.2.2

## Version 1.0.3 - 2009-03-02

* Update for MIME::Types 1.16

## Version 1.0.2 - 2008-12-03

* Fix FileType namespace issue (thanks defunkt) and new version of coderay
* various task maintenance
* updated version dependencies

## Version 1.0.1 - 2008-04-24

* Fix performance issue in serving large files
* Fix performance issue in checking for coderay file type when coderay would not be used.

## Version 1.0.0 - 2008-04-20

* Convert Heel to a Rack and Thin application

## Version 0.6.0 - 2007-11-21

* Fixed bug where an exception was thrown if a 0 byte file was served.
* Changed change 'resources' directory to 'data'
* Renamed internal constants
* Changed operating URL's to avoid conflict with directories heel may be serving

## Version 0.5.0 - 2007-11-19

* Add in code highlighting support via coderay
* extract CSS files to a resource
* increase test coverage

## Version 0.4.1 - 2007-11-15

* Fix bug [#15645] - not starting up on windows

## Version 0.4.0 - 2007-11-04

* Added common log format output to terminal or logfile as appropriate.

## Version 0.3.2 - 2007-08-30

* fix failure to find background option
* remember to double check your tests before releasing

## Version 0.3.1 - 2007-08-30

* fix failure to find pid file [Bug #13530]
* remember to stop releasing software in the wee hours of the morning

## Version 0.3.0 - 2007-08-30

* update with Launchy requirement 0.3.0
* remove unneeded famfamfam icons
* change default listening address to 127.0.0.1
* refactored handler test, now with more coverage

## Version 0.2.0 - 2007-08-11

* Initial public release
* Added daemonizing of server
* Added launching of browser to server URL

## Version 0.1.0

* rename project to 'heel'
* gem packaging

## Version 0.0.1 - 2007-05-03

* initial development release

