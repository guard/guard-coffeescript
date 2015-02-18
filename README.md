# Guard::CoffeeScript [![Build Status](https://secure.travis-ci.org/netzpirat/guard-coffeescript.png)](http://travis-ci.org/netzpirat/guard-coffeescript)

Guard::CoffeeScript compiles or validates your CoffeeScripts automatically when files are modified.
If you're looking for a CoffeeScript merge tool, please checkout [Guard::CoffeeDripper](https://github.com/guard/guard-coffeedripper).

Tested on MRI Ruby 1.9.3, 2.0.0, 2.1.0 and the latest versions of JRuby & Rubinius.

If you have any questions please join us on our [Google group](http://groups.google.com/group/guard-dev) or on `#guard`
(irc.freenode.net).

## Install

The simplest way to install Guard is to use [Bundler](http://gembundler.com/).
Please make sure to have [Guard](https://github.com/guard/guard) installed.

Add Guard::Coffeescript to your `Gemfile`:

```ruby
group :development do
  gem 'guard-coffeescript'
end
```
Add the default Guard::Coffeescript template to your `Guardfile` by running:

```bash
$ guard init coffeescript
```

## JSON

The JSON library is also required but is not explicitly stated as a gem dependency. If you're on Ruby 1.8 you'll need
to install the `json` or `json_pure` gem. On Ruby 1.9, JSON is included in the standard library.

## CoffeeScript

Guard::CoffeeScript uses [Ruby CoffeeScript](https://github.com/josh/ruby-coffee-script/) to compile the CoffeeScripts,
that in turn uses [ExecJS](https://github.com/sstephenson/execjs) to pick the best runtime to evaluate the JavaScript.

* With CRuby you want to use a V8 JavaScript Engine or Mozilla SpiderMonkey.
* With JRuby you want to use the Mozilla Rhino.
* On Mac OS X you want to use Apple JavaScriptCore.
* On Linux or as a node.js developer you want to use Node.js (V8).
* On Windows you want to use Microsoft Windows Script Host.

## JavaScript runtimes

The following sections gives you a short overview of the available JavaScript runtimes and how to install it.

### Node.js (V8)

You can install [node.js](http://nodejs.org/) and use its V8 engine. On OS X you may want to install it with
[Homebrew](http://mxcl.github.com/homebrew/), on Linux with your package manager and on Windows you have to download and
install the [executable](http://www.nodejs.org/#download).

### V8 JavaScript Engine

To use the [V8 JavaScript Engine](http://code.google.com/p/v8/), simple add `therubyracer` to your `Gemfile`.
The Ruby Racer acts as a bridge between Ruby and the V8 engine, that will be automatically installed by the Ruby Racer.

```ruby
group :development do
  gem 'therubyracer'
end
```

Another alternative is [Mustang](https://github.com/nu7hatch/mustang), a Ruby proxy library for the awesome Google V8
JavaScript engine. Just add `mustang` to your `Gemfile`:

```ruby
group :development do
  gem 'mustang'
end
```

### Mozilla SpiderMonkey

To use [Mozilla SpiderMonkey](https://developer.mozilla.org/en/SpiderMonkey), simple add `johnson` to your `Gemfile`.
Johnson embeds the Mozilla SpiderMonkey JavaScript runtime as a C extension.

```ruby
group :development do
  gem 'johnson'
end
```

### Mozilla Rhino

If you're using JRuby, you can embed the [Mozilla Rhino](http://www.mozilla.org/rhino/) runtime by adding `therubyrhino`
to your `Gemfile`:

```ruby
group :development do
  gem 'therubyrhino'
end
```

### Apple JavaScriptCore

[JavaScriptCore](http://developer.apple.com/library/mac/#documentation/Carbon/Reference/WebKit_JavaScriptCore_Ref/index.html)
is Safari's Nitro JavaScript Engine and only usable on Mac OS X. You don't have to install anything, because
JavaScriptCore is already packaged with Mac OS X.

### Microsoft Windows Script Host

[Microsoft Windows Script Host](http://msdn.microsoft.com/en-us/library/9bbdkx3k.aspx) is available on any Microsoft
Windows operating systems.

## Usage

Please read the [Guard usage documentation](https://github.com/guard/guard#readme).

## Guardfile

Guard::CoffeeScript can be adapted to all kind of projects. Please read the
[Guard documentation](https://github.com/guard/guard#readme) for more information about the Guardfile DSL.

### Ruby project

In a Ruby project you want to configure your input and output directories.

```ruby
guard 'coffeescript', :input => 'coffeescripts', :output => 'javascripts'
```

If your output directory is the same as the input directory, you can simply skip it:

```ruby
guard 'coffeescript', :input => 'javascripts'
```

### Rails app with the asset pipeline

With the introduction of the [asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html) in Rails 3.1 there is
no need to compile your CoffeeScripts with this Guard.

However, if you would still like to have feedback on the validation of your CoffeeScripts
(preferably with a Growl notification) directly after you save a change, then you can still
use this Guard and simply skip generation of the output file:

```ruby
guard 'coffeescript', :input => 'app/assets/javascripts', :noop => true
```

This give you a faster compilation feedback compared to making a subsequent request to your Rails application. If you
just want to be notified when an error occurs you can hide the success compilation message:

```ruby
guard 'coffeescript', :input => 'app/assets/javascripts', :noop => true, :hide_success => true
```

### Rails app without the asset pipeline

Without the asset pipeline you just define an input and output directory like within a normal Ruby project:

```ruby
guard 'coffeescript', :input => 'app/coffeescripts', :output => 'public/javascripts'
```

## Options

There following options can be passed to Guard::CoffeeScript:

```ruby
:input => 'coffeescripts'           # Relative path to the input directory.
                                    # Files will be added that match a suffix
                                    # of /(.+\.(coffee|coffee\.md|litcoffee))
                                    # default: nil

:output => 'javascripts'            # Relative path to the output directory.
                                    # default: the path given with the :input option

:noop => true                       # No operation: do not write an output file.
                                    # default: false

:bare => true                       # Compile without the top-level function wrapper.
                                    # Provide either a boolean value or an Array of
                                    # filenames.
                                    # default: false

:shallow => true                    # Do not create nested output directories.
                                    # default: false

:source_map => true                 # Do create the source map file.
                                    # default: false

:source_root => 'coffeescripts'     # Root path for coffeescript sources.
                                    # Used in source map to determine root URL for
                                    # all sources
                                    # default: nil (using the `:input` directory)

:pre_process => Proc.new {|f|...}   # Proc or lambda to pre process the script content before compilation.
                                    # Accept one argument which is the file content.
                                    # default: nil

:hide_success => true               # Disable successful compilation messages.
                                    # default: false

:all_on_start => true               # Regenerate all files on startup
                                    # default: false

:error_to_js => true                # Print the Coffeescript error message directly in
                                    # the JavaScript file
                                    # default: false
```

The `:source_map` option needs at least CoffeeScript version 1.6.1.

### Output short notation

In addition to the standard configuration, this Guard has a short notation for configure projects with a single input
and output directory. This notation creates a watcher from the `:input` parameter that matches all CoffeeScript files
under the given directory and you don't have to specify a watch regular expression.

```ruby
guard 'coffeescript', :input => 'javascripts'
```

### Selective bare option

The `:bare` option can take a boolean value that indicates if all scripts should be compiled without the top-level
function wrapper.

```ruby
:bare => true
```

But you can also pass an Array of filenames that should be compiled without the top-level function wrapper. The path of
the file to compile is ignored, so the list of filenames should not contain any path information:

```ruby
:bare => %w{ a.coffee b.coffee }
```

In the above example, all `a.coffee` and `b.coffee` files will be compiled with option `:bare => true` and all other
files with option `:bare => false`.

### Nested directories

The Guard detects by default nested directories and creates these within the output directory. The detection is based on
the match of the watch regular expression:

A file

```ruby
/app/coffeescripts/ui/buttons/toggle_button.coffee
```

that has been detected by the watch

```ruby
watch(%r{^app/coffeescripts/(.+\.coffee)$})
```

with an output directory of

```ruby
:output => 'public/javascripts/compiled'
```

will be compiled to

```ruby
public/javascripts/compiled/ui/buttons/toggle_button.js
```

Note the parenthesis around the `.+\.coffee`. This enables Guard::CoffeeScript to place the full path that was matched
inside the parenthesis into the proper output directory.

This behavior can be switched off by passing the option `:shallow => true` to the Guard, so that all JavaScripts will be
compiled directly to the output directory.

### Multiple source directories

The Guard short notation

```ruby
guard 'coffeescript', :input => 'app/coffeescripts', :output => 'public/javascripts/compiled'
```

will be internally converted into the standard notation by adding `/(.+\.coffee)` to the `input` option string and
create a Watcher that is equivalent to:

```ruby
guard 'coffeescript', :output => 'public/javascripts/compiled' do
  watch(%r{^app/coffeescripts/(.+\.coffee)$})
end
```

To add a second source directory that will be compiled to the same output directory, just add another watcher:

```ruby
guard 'coffeescript', :input => 'app/coffeescripts', :output => 'public/javascripts/compiled' do
  watch(%r{lib/coffeescripts/(.+\.coffee)})
end
```

which is equivalent to:

```ruby
guard 'coffeescript', :output => 'public/javascripts/compiled' do
  watch(%r{app/coffeescripts/(.+\.coffee)})
  watch(%r{lib/coffeescripts/(.+\.coffee)})
end
```

## Issues

You can report issues and feature requests to [GitHub Issues](https://github.com/netzpirat/guard-coffeescript/issues). Try to figure out
where the issue belongs to: Is it an issue with Guard itself or with a Guard::Cucumber? Please don't
ask question in the issue tracker, instead join us in our [Google group](http://groups.google.com/group/guard-dev) or on
`#guard` (irc.freenode.net).

When you file an issue, please try to follow to these simple rules if applicable:

* Make sure you run Guard with `bundle exec` first.
* Add debug information to the issue by running Guard with the `--debug` option.
* Add your `Guardfile` and `Gemfile` to the issue.
* Make sure that the issue is reproducible with your description.

## Development

- Documentation hosted at [RubyDoc](http://rubydoc.info/github/guard/guard-coffeescript/master/frames).
- Source hosted at [GitHub](https://github.com/netzpirat/guard-coffeescript).

Pull requests are very welcome! Please try to follow these simple rules if applicable:

* Please create a topic branch for every separate change you make.
* Make sure your patches are well tested.
* Update the [Yard](http://yardoc.org/) documentation.
* Update the README.
* Update the CHANGELOG for noteworthy changes.
* Please **do not change** the version number.

For questions please join us in our [Google group](http://groups.google.com/group/guard-dev) or on
`#guard` (irc.freenode.net).

## Author

Developed by Michael Kessler, sponsored by [FlinkFinger](http://www.flinkfinger.com).

If you like Guard::CoffeeScript, you can watch the repository at [GitHub](https://github.com/netzpirat/guard-coffeescript) and
follow [@netzpirat](https://twitter.com/#!/netzpirat) on Twitter for project updates.

## Contributors

See the GitHub list of [contributors](https://github.com/netzpirat/guard-coffeescript/contributors).

## Acknowledgment

* [Jeremy Ashkenas](http://twitter.com/#!/jashkenas) for [CoffeeScript](http://jashkenas.github.com/coffee-script/),
that little language that compiles into JavaScript and makes me enjoy the frontend.
* The [Guard Team](https://github.com/guard/guard/contributors) for giving us such a nice piece of software
that is so easy to extend, one *has* to make a plugin for it!
* All the authors of the numerous [Guards](https://github.com/guard) available for making the Guard ecosystem
so much growing and comprehensive.

## License

(The MIT License)

Copyright (c) 2010-2013 Michael Kessler

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
