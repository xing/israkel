# ISRakel

This gem is a collection of rake tasks for maintaining common tasks
for the iPhone Simulator on Mac OS like ...

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

## Feedback

Please raise issues if you find problems or have a feature request.
