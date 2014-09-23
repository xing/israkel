require 'spec_helper'

module ISRakel
  describe Tasks do
    before do
      @tasks = Tasks.instance
      plist = CFPropertyList::List.new(:file => "spec/fixtures/device.plist")
      @subject = Device.from_plist(plist)
      @tasks.device_chosen = @subject
      ENV['BUNDLE_ID'] = 'com.xing.israkel'
    end

    it "allows addressbook access" do
      expect(@subject).to receive(:allow_addressbook_access).with('com.xing.israkel')
      Rake::Task["simulator:allow_addressbook_access"].invoke
    end

    it "allows gps access" do
      expect(@subject).to receive(:allow_gps_access).with('com.xing.israkel')
      Rake::Task["simulator:allow_gps_access"].invoke
    end

    it "allows photos access" do
      expect(@subject).to receive(:allow_photos_access).with('com.xing.israkel')
      Rake::Task["simulator:allow_photos_access"].invoke
    end

    it "starts the simulator" do
      expect(@subject).to receive(:start)
      Rake::Task["simulator:start"].invoke
    end

    it "stops the simulator" do
      expect(@subject).to receive(:stop)
      Rake::Task["simulator:stop"].invoke
    end

    it "resets the simulator" do
      expect(@subject).to receive(:reset)
      Rake::Task["simulator:reset"].invoke
    end

    it "sets the simulators language" do
      ENV['IOS_LANG'] = "de_DE"
      expect(@subject).to receive(:set_language).with("de_DE")
      Rake::Task["simulator:set_language"].invoke
    end

    it "throws an exception if no language is set" do
      ENV['IOS_LANG'] = nil
      expect { @tasks.send(:ios_lang) }.to raise_error(RuntimeError, "You must set the IOS_LANG environment variable")
    end

    it "throws an exception if no bundle identifier is set" do
      ENV['BUNDLE_ID'] = nil
      expect { @tasks.send(:bundle_id) }.to raise_error(RuntimeError)
    end
  end
end
