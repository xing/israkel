# ISRakel

[![Build Status](http://img.shields.io/travis/xing/israkel/master.svg?style=flat-square)](https://travis-ci.org/xing/israkel)
[![Code Coverage](http://img.shields.io/coveralls/xing/israkel.svg?style=flat-square)](https://coveralls.io/r/xing/israkel)
[![Dependency Status](https://www.versioneye.com/user/projects/5444b70c53acfa4b0f0000cf/badge.svg?style=flat-square)](https://www.versioneye.com/user/projects/5444b70c53acfa4b0f0000cf)
[![Code climate](http://img.shields.io/codeclimate/github/xing/israkel.svg?style=flat-square)](https://codeclimate.com/github/xing/israkel)
[![Gem Version](http://img.shields.io/gem/v/israkel.svg?style=flat-square)](https://rubygems.org/gems/israkel)


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
[npm](https://www.npmjs.org/package/ios-sim):

    npm install ios-sim

## Example Usage

You will need to install the gem:

	gem install israkel

and then your `Rakefile` in your project might look like:

	require 'israkel'
    ISRakel::Tasks.instance

That's it. After that you can just run `rake -T` to list the available tasks.

You can also change the default prefix `simulator`:

    ISRakel::Tasks.instance do |i|
      i.name = 'ios'
    end

## Edit (global) Preferences

There are binary plist files that you can edit with your custom rake
tasks to change some settings:

    i = ISRakel::Tasks.instance
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

## Authorize access to addressbook, gps and photos

Allowing access upfront can be required because it's not possible
to use KIF to tap on the OK button of the access alert views.

    i = ISRakel::Tasks.instance

    desc 'Allow AddressBook access'
    task :allow_addressbook_access do
      i.current_device.allow_addressbook_access('com.xing.App')
    end

    desc 'Allow GPS access'
    task :allow_gps_access do
      i.current_device.allow_gps_access('com.xing.App')
    end

    desc 'Allow Photo Library access'
    task :allow_photos_access do
      i.current_device.allow_photos_access('com.xing.App')
    end

Even easier, you don't have to define the rake tasks in your Rakefile.
There are generic tasks that take the environment variable `BUNDLE_ID`
into account:

    DEVICE_TYPE=iPhone-5s IOS_SDK_VERSION=7.1 BUNDLE_ID=com.example.apple-samplecode.PhotoPicker rake simulator:allow_photos_access

## Feedback

Please raise issues if you find problems or have a feature request.
