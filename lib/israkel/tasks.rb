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

      define_start_task
      define_stop_task
    end

    private

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

    def simulator_path
      @simulator_path ||= File.join(xcode_path, 'Platforms', 'iPhoneSimulator.platform', 'Developer', 'Applications', 'iPhone Simulator.app')
    end

    def xcode_path
      @xcode_path ||= `xcode-select --print-path`.chomp
    end

  end
end
