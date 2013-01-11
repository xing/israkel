# ISRakel

This gem is a collection of rake tasks for maintaining common tasks
for the iPhone Simulator on Mac OS like ...

* Change preferences of the iPhone Simulator
* Change the language of the iPhone Simulator
* Reset the iPhone Simulator
* Start the iPhone Simulator
* Stop the iPhone Simulator

## Example Usage

You will need to install the gem:

	gem install israkel

and then require the gem in your projects rake file

	require 'israkel'

and finally load the rake tasks

    ISRakel::Tasks.new

You can also change the default prefix `simulator`:

    ISRakel::Tasks.new do |r|
      r.name = 'ios'
    end

## Edit (global) Preferences

There are binary plist files that you can edit with your custom rake
tasks to change some settings:

    i = ISRakel::Tasks.new
    desc "Change keyboard preferences"
    task :set_keyboard_preferences do
      i.edit_preferences do |p|
        puts p
        p.merge!({
          :KeyboardAutocapitalization => false,
          :KeyboardAutocorrection     => false,
          :KeyboardCapsLock           => false,
          :KeyboardCheckSpelling      => false,
          :KeyboardPeriodShortcut     => false,
        })
        puts p
      end
    end

There's a second method called `edit_global_preferences` which works
the same, just edits a different file.

## Feedback

Please raise issues if you find problems or have a feature request.
