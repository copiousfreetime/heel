## Heel
[![Build Status](https://copiousfreetime.semaphoreci.com/badges/heel/branches/main.svg)](https://copiousfreetime.semaphoreci.com/projects/heel)

* [Homepage](https://github.com/copiousfreetime/heel/)
* [GitHub](https://github.com/copiousfreetime/heel/)

## DESCRIPTION

Heel is a small static web server for use when you need a quick web server for a
directory.  Once the server is running, heel will use
[launchy](https://rubygems.org/gems/launchy/) to open your browser at
the URL of your document root.

Run it right now! `gem exec heel`

-----

Heel is built using [Rack](https://github.com/rack/rack) and
[Puma](https://puma.io)

    % heel
    Launching your browser...
    Puma starting in single mode...
    * Puma version: 6.2.1 (ruby 3.2.2-p53) ("Speaking of Now")
    *  Min threads: 0
    *  Max threads: 5
    *  Environment: none
    *          PID: 11322
    * Listening on http://0.0.0.0:4331
    Use Ctrl-C to stop

Or run it in the background

    % heel --daemonize
    Launching your browser at http://0.0.0.0:4331/

    % heel --kill
    Sending TERM to process 3304
    Done.

## FEATURES

* Automatic launching of your browser to the URL it is serving with [launchy](https://github.com/copiousfreetime/launchy/)
* Automatic syntax highlighting of source code files with [rouge](https://github.com/ruby-rouge/rouge))
* Run in the foreground or daemonized
* Bind to any address and port (default is 0.0.0.0:4331)

## SYNOPSIS:

    Usage: heel [options]

        -a, --address ADDRESS            Address to bind to
                                           (default: 0.0.0.0)
        -d, --daemonize                  Run daemonized in the background
        -h, --help                       Display this text
        -k, --kill                       Kill an existing daemonized heel process
            --[no-]highlighting          Turn on or off syntax highlighting
                                           (default: on)
            --[no-]launch-browser        Turn on or off automatic browser launch
                                           (default: on)
        -p, --port PORT                  Port to bind to
                                           (default: 4331)
        -r, --root ROOT                  Set the document root
                                          (default: <current working directory>)
        -v, --version                    Show version

## REQUIREMENTS:

### For running:

* [rouge](https://github.com/rouge-ruby/rouge)
* [launchy](https://github.com/copiousfreetime/launchy/)
* [mime-types](https://github.com/mime-types/ruby-mime-types/)
* [puma](https://puma.io)
* [rackup](https://github.com/rack/rackup)

### For development:

* [minitest](https://rubygems.org/gems/minitest)
* [rake](https://rubygems.org/gems/rake)
* [rdoc](https://rubygems.org/gems/rdoc)

## INSTALL:

* `gem install heel`

## CREDITS:

* [puma](https://puma.io)
* [Rack](https://github.com/rack/rack)
* [lineicons](https://lineicons.com/)
* [picocss](https://picocss.com/)

## BSD LICENSE:

Copyright (c) 2007 - 2023, Jeremy Hinegardner

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the
    distribution.

  * Neither the name of Jeremy Hinegardner nor the
    names of its contributors may be used to endorse or promote
    products derived from this software without specific prior written
    permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
