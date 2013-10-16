# Changelog

## Version 3.1.2 - 2013-10-16
* Fix usage of Mime::Types [#12]

## Version 3.1.1 - 2013-09-29
* Fix request logging [#10]

## Version 3.1.0 - 2013-07-07
* Update dependencies
* Switch to template contributed by brianflanagan [#8]
* Add support for multiple independent heel servers [#9]

## Version 3.0.2 - 2013-03-13

* Fix generated pages to say they are utf-8 [#4]
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

