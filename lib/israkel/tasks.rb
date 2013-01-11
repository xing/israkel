require 'fileutils'
require 'json'
require 'rake'
require 'rake/tasklib'

module ISRakel
  class Tasks < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :name, :sdk_version

    def initialize(name = :simulator)
      @name = name
      @sdk_version = ENV['IOS_SDK_VERSION'] || '6.0'
      yield self if block_given?

      # Make sure all external commands are in the PATH.
      xcode_path

      define_reset_task
      define_set_language_task
      define_start_task
      define_stop_task
    end

    def edit_global_preferences(&block)
      edit_file( File.join(simulator_preferences_path, '.GlobalPreferences.plist'), &block )
    end

    def edit_preferences(&block)
      edit_file( File.join(simulator_preferences_path, 'com.apple.Preferences.plist'), &block )
    end

    private

    def edit_file(file)
      content = plist_to_hash(file)
      yield content
      puts content
      hash_to_plist(content, file)
    end

    def edit_global_preferences(&block)
      edit_file( File.join(simulator_preferences_path, '.GlobalPreferences.plist'), &block )
    end

    def edit_preferences(&block)
      edit_file( File.join(simulator_preferences_path, 'com.apple.Preferences.plist'), &block )
    end

    def define_reset_task
      desc "Reset content and settings of the iPhone Simulator"
      task "#{name}:reset" do
        rm_rf simulator_support_path
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
        sh 'killall', '-m', '-KILL', 'iPhone Simulator' do |ok, res|
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

    def simulator_path
      @simulator_path ||= File.join(xcode_path, 'Platforms', 'iPhoneSimulator.platform', 'Developer', 'Applications', 'iPhone Simulator.app')
    end

    def simulator_preferences_path
      File.join(simulator_support_path, 'Library', 'Preferences')
    end

    def simulator_support_path
      @simulator_support_path ||= File.join(ENV['HOME'], 'Library', 'Application Support', 'iPhone Simulator', sdk_version)
    end

    def xcode_path
      @xcode_path ||= `xcode-select --print-path`.chomp
    end

  end
end
