# ISRakel

This gem is a collection of rake tasks for maintaining common tasks
for the iPhone Simulator on Mac OS like ...

* Change preferences of the iPhone Simulator
* Change the language of the iPhone Simulator
* Reset the iPhone Simulator
* Start the iPhone Simulator
* Stop the iPhone Simulator

Some of them are stolen from [RestKit](https://github.com/RestKit/RestKit).

## Dependencies

Besides the gem dependencies, that are automatically resolved and
installed via bundler, there's only one external dependency to the
[ios-sim](https://github.com/phonegap/ios-sim) binary. The most
convenient way to install it is via
[homebrew](http://mxcl.github.com/homebrew/):

    brew install ios-sim

## Example Usage

You will need to install the gem:

	gem install israkel

and then your `Rakefile` in your project might look like:

	require 'israkel'
    ISRakel::Tasks.new

That's it. After that you can just run `rake -T` to list the available tasks.

You can also change the default prefix `simulator`:

    ISRakel::Tasks.new do |i|
      i.name = 'ios'
    end

## Edit (global) Preferences

There are binary plist files that you can edit with your custom rake
tasks to change some settings:

    i = ISRakel::Tasks.new
    desc "Change keyboard preferences"
    task :set_keyboard_preferences do
      i.edit_preferences do |p|
        p.merge!({
          :KeyboardAutocapitalization => false,
          :KeyboardAutocorrection     => false,
          :KeyboardCapsLock           => false,
          :KeyboardCheckSpelling      => false,
          :KeyboardPeriodShortcut     => false,
        })
      end
    end

There's a second method called `edit_global_preferences` which works
the same, just edits a different file.

## Feedback

Please raise issues if you find problems or have a feature request.
