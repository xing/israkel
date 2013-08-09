require 'fileutils'
require 'highline/import'
require 'json'
require 'rake'
require 'rake/tasklib'

module ISRakel
  class Tasks < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)
    include Singleton

    attr_accessor :name, :sdk_version

    def initialize(name = :simulator)
      @name = name

      yield self if block_given?

      define_allow_gps_access_task
      define_reset_task
      define_set_language_task
      define_start_task
      define_stop_task
    end

    def allow_gps_access(bundle_id)
      directory = File.join(simulator_support_path, 'Library', 'Caches', 'locationd')
      FileUtils.mkdir_p(directory) unless Dir.exists?(directory)
      edit_file( File.join(directory, 'clients.plist') ) do |content|
        content.merge!({
          bundle_id => {
            :Authorized  => true,
            :BundleId    => bundle_id,
            :Executable  => "",
            :Registered  => "",
            :Whitelisted => false,
          }
        })
      end
    end

    def edit_global_preferences(&block)
      edit_file( File.join(simulator_preferences_path, '.GlobalPreferences.plist'), &block )
    end

    def edit_preferences(&block)
      edit_file( File.join(simulator_preferences_path, 'com.apple.Preferences.plist'), &block )
    end

    def sdk_version
      @sdk_version ||= select_sdk_version
    end

    def set_language(language)
      edit_global_preferences do |p|
        unless p['AppleLanguages'].include?(language)
          fail "#{language} is not a valid language"
        end
        p['AppleLanguages'].unshift(language).uniq!
      end
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

    private

    def edit_file(file)
      content = {}
      if File.exists?(file)
        content = plist_to_hash(file)
      end
      yield content
      hash_to_plist(content, file)
    end

    def define_allow_gps_access_task
      desc "Allow GPS access (via BUNDLE_ID environment variable)"
      task "#{name}:allow_gps_access" do
        bundle_id = ENV['BUNDLE_ID']
        if bundle_id.nil?
          fail "You must set the BUNDLE_ID environment variable"
        end
        allow_gps_access(bundle_id)
      end
    end

    def define_reset_task
      desc "Reset content and settings of the iPhone Simulator"
      task "#{name}:reset" do
        rm_rf File.join(simulator_support_path)
      end
    end

    def define_set_language_task
      desc "Set the system language (via IOS_LANG environment variable)"
      task "#{name}:set_language" do
        language = ENV['IOS_LANG']
        if language.nil?
          fail "You must set the IOS_LANG environment variable"
        end
        set_language(language)
      end
    end

    def define_start_task
      desc "Start the iPhone Simulator"
      task "#{name}:start" do
        sh 'ios-sim', 'start', '--retina', '--sdk', sdk_version
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
      cmd.close
    end

    def ios_sim_path
      @ios_sim_path ||= `which ios-sim`.chomp
      abort "please install ios-sim" if @ios_sim_path.empty?
      @ios_sim_path
    end

    def plist_to_hash(path)
      JSON.parse( IO.popen(['plutil', '-convert', 'json', '-o', '-', path]) {|f| f.read} )
    end

    def sdk_versions
      versions = `#{ios_sim_path} showsdks 2>&1`.split("\n").find_all {|version| version =~ /Simulator - iOS (\d\.\d)/ }
      versions.each {|version| version.gsub!(/.*?Simulator - iOS (\d.\d).*?$/, '\1')}
      versions
    end

    def select_sdk_version
      result = ENV['IOS_SDK_VERSION']
      return result unless result.nil?
      choose do |menu|
        menu.prompt = "Please select an SDK version"
        menu.choices(*sdk_versions) do |version|
          result = version
        end
      end
      result
    end

    def xcode_path
      @xcode_path ||= `xcode-select --print-path`.chomp
      abort "please install xcode and the command line tools" if @xcode_path.empty?
      @xcode_path
    end

  end
end
