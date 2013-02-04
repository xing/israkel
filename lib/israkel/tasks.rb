require 'fileutils'
require 'highline/import'
require 'json'
require 'rake'
require 'rake/tasklib'

module ISRakel
  class Tasks < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :name

    def initialize(name = :simulator)
      @name = name

      yield self if block_given?

      # Make sure all external commands are in the PATH.
      xcode_path

      define_reset_task
      define_set_language_task
      define_start_task
      define_stop_task
    end

    def edit_global_preferences(&block)
      sdk_version_choice do |version|
        edit_file( File.join(simulator_preferences_path(version), '.GlobalPreferences.plist'), &block )
      end
    end

    def edit_preferences(&block)
      sdk_version_choice do |version|
        edit_file( File.join(simulator_preferences_path(version), 'com.apple.Preferences.plist'), &block )
      end
    end

    private

    def edit_file(file)
      content = plist_to_hash(file)
      yield content
      hash_to_plist(content, file)
    end

    def define_reset_task
      desc "Reset content and settings of the iPhone Simulator"
      task "#{name}:reset" do
        sdk_version_choice do |version|
          rm_rf File.join(simulator_support_path(version), '*')
        end
      end
    end

    def define_set_language_task
      desc "Set the system language (via IOS_LANG environment variable)"
      task "#{name}:set_language" do
        language = ENV['IOS_LANG']
        if language.nil?
          fail "You must set the IOS_LANG environment variable"
        end
        edit_global_preferences do |p|
          unless p['AppleLanguages'].include?(language)
            fail "#{language} is not a valid language"
          end
          p['AppleLanguages'].unshift(language).uniq!
        end
      end
    end

    def define_start_task
      desc "Start the iPhone Simulator"
      task "#{name}:start" do
        sh 'open', '-g', simulator_path
      end
    end

    def define_stop_task
      desc "Stop the iPhone Simulator"
      task "#{name}:stop" do
        sh 'killall', '-m', '-TERM', 'iPhone Simulator' do |ok, res|
        end
      end
    end

    def hash_to_plist(hash, path)
      cmd = IO.popen(['plutil', '-convert', 'binary1', '-o', path, '-'], 'w')
      cmd.puts hash.to_json
    end

    def plist_to_hash(path)
      JSON.parse( IO.popen(['plutil', '-convert', 'json', '-o', '-', path]) {|f| f.read} )
    end

    def sdk_version_choice
      if ENV['IOS_SDK_VERSION']
        yield ENV['IOS_SDK_VERSION']
        return
      end
      versions = Dir[File.join(ENV['HOME'], 'Library', 'Application Support', 'iPhone Simulator', '*')].map {|dir| File.basename(dir)}
      choose do |menu|
        menu.prompt = "Please select an SDK version"
        menu.choices(*versions) do |version|
          yield version
        end
      end
    end

    def simulator_path
      @simulator_path ||= File.join(xcode_path, 'Platforms', 'iPhoneSimulator.platform', 'Developer', 'Applications', 'iPhone Simulator.app')
    end

    def simulator_preferences_path(sdk_version)
      File.join(simulator_support_path(sdk_version), 'Library', 'Preferences')
    end

    def simulator_support_path(sdk_version)
      @simulator_support_path ||= File.join(ENV['HOME'], 'Library', 'Application Support', 'iPhone Simulator', sdk_version)
    end

    def xcode_path
      @xcode_path ||= `xcode-select --print-path`.chomp
    end

  end
end
