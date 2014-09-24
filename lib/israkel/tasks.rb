require 'rake'
require 'rake/tasklib'
require 'highline/import'

module ISRakel
  class Tasks < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)
    include Singleton

    attr_accessor :name, :device_chosen

    def initialize(name = :simulator)
      @name = name

      yield self if block_given?

      define_allow_addressbook_access_task
      define_allow_gps_access_task
      define_allow_photos_access_task
      define_reset_task
      define_set_language_task
      define_start_task
      define_stop_task
    end

    private

    def bundle_id
      bundle_id = ENV['BUNDLE_ID']
      if bundle_id.nil?
        raise "You must set the BUNDLE_ID environment variable"
      end
      bundle_id
    end

    def ios_lang
      language = ENV['IOS_LANG']
      if language.nil?
        raise "You must set the IOS_LANG environment variable"
      end
      language
    end

    def define_allow_addressbook_access_task
      desc "Allow AdressBook access (via BUNDLE_ID environment variable)"
      task "#{name}:allow_addressbook_access" do
        @device_chosen.allow_addressbook_access(bundle_id)
      end
    end

    def define_allow_gps_access_task
      desc "Allow GPS access (via BUNDLE_ID environment variable)"
      task "#{name}:allow_gps_access" do
        @device_chosen.allow_gps_access(bundle_id)
      end
    end

    def define_allow_photos_access_task
      desc "Allow Photos access (via BUNDLE_ID environment variable)"
      task "#{name}:allow_photos_access" do
        @device_chosen.allow_photos_access(bundle_id)
      end
    end

    def define_reset_task
      desc "Reset content and settings of the iPhone Simulator"
      task "#{name}:reset" do
        @device_chosen.reset
      end
    end

    def define_set_language_task
      desc "Set the system language (via IOS_LANG environment variable)"
      task "#{name}:set_language" do
        @device_chosen.set_language(ios_lang)
      end
    end

    def define_start_task
      desc "Start the iPhone Simulator"
      task "#{name}:start" do
        @device_chosen.start
      end
    end

    def define_stop_task
      desc "Stop the iPhone Simulator"
      task "#{name}:stop" do
        @device_chosen.stop
      end
    end

    def select_device
      sdk_version = ENV['IOS_SDK_VERSION']
      @device_chosen = Device.with_sdk_version(sdk_version)
      return @device_chosen if @device_chosen
      choose do |menu|
        menu.prompt = "Please select a simulator"
        menu.choices(*Device.all) do |device|
          @device_chosen = device
        end
      end
    end
  end
end
