require 'spec_helper'

describe Device do

  before do
    @hash = {
      'UDID' => 'EFA1B4B1-5741-4396-AF52-F8AD29229CFC',
      'deviceType' => 'com.apple.CoreSimulator.SimDeviceType.iPhone-4s',
      'name' => 'iPhone 4s',
      'runtime' => 'com.apple.CoreSimulator.SimRuntime.iOS-8-0',
      'state' => 1
    }
  end

  context "initialization" do
    it "#from_hash" do
      subject = Device.from_hash(@hash)

      expect(subject.UUID).to eql('EFA1B4B1-5741-4396-AF52-F8AD29229CFC')
      expect(subject.type).to eql('com.apple.CoreSimulator.SimDeviceType.iPhone-4s')
      expect(subject.name).to eql('iPhone 4s')
      expect(subject.runtime).to eql('com.apple.CoreSimulator.SimRuntime.iOS-8-0')
      expect(subject.state).to eql(1)
    end

    it "#from_plist" do
      plist = CFPropertyList::List.new(:file => "spec/fixtures/device.plist")
      subject = Device.from_plist(plist)

      expect(subject.UUID).to eq('EFA1B4B1-5741-4396-AF52-F8AD29229CFC')
      expect(subject.type).to eq('com.apple.CoreSimulator.SimDeviceType.iPhone-4s')
      expect(subject.name).to eq('iPhone 4s')
      expect(subject.runtime).to eq('com.apple.CoreSimulator.SimRuntime.iOS-8-0')
      expect(subject.state).to eq(1)
    end

    describe "#with_sdk_version" do
      before do
        allow(Device).to receive(:sim_root_path) { File.join('spec', 'fixtures', 'sim_root_path') }
      end

      it "returns device if one is found" do
        subject = Device.with_sdk_version('8.0')

        expect(subject.UUID).to eq('EFA1B4B1-5741-4396-AF52-F8AD29229CFC')
        expect(subject.type).to eq('com.apple.CoreSimulator.SimDeviceType.iPhone-4s')
        expect(subject.name).to eq('iPhone 4s')
        expect(subject.runtime).to eq('com.apple.CoreSimulator.SimRuntime.iOS-8-0')
        expect(subject.state).to eq(1)
      end

      it "returns nil if nothing is found" do
        subject = Device.with_sdk_version('6.0')
        expect(subject).to be_nil
      end
    end
  end

  context "class methods" do
    describe "#all" do
      before do
        allow(Device).to receive(:sim_root_path) { File.join('spec', 'fixtures', 'sim_root_path') }
      end

      it "returns correct number of devices" do
        expect(Device.all.count).to eq(2)
      end

      it "returns valid device instances" do
        subject = Device.all.first
        expect(subject.UUID).to eq("61C01D44-431C-11E4-9BFF-20C9D08353AF")
      end
    end

    it "#stop" do
      expect(Device).to receive(:system).with('killall', '-m', '-TERM', 'iOS Simulator')
      Device.stop
    end

    it "#sim_root_path" do
      expect(Device.sim_root_path).to eq("#{ENV['HOME']}/Library/Developer/CoreSimulator/Devices")
    end
  end

  context "allow services" do
    before do
      @subject = Device.from_hash(@hash)
      @path = File.join('spec', 'fixtures', 'sim_root_path')
      allow(Device).to receive(:sim_root_path) { @path }
    end

    it "#allow_addressbook_access" do
      expect(@subject).to receive(:allow_tcc_access).with('kTCCServiceAddressBook', 'com.xing.israkel')
      @subject.allow_addressbook_access('com.xing.israkel')
    end

    it "#allow_photos_access" do
      expect(@subject).to receive(:allow_tcc_access).with('kTCCServicePhotos', 'com.xing.israkel')
      @subject.allow_photos_access('com.xing.israkel')
    end

    describe "#allow_gps_access" do
      it "opens the right plist" do
        expect(Helper).to receive(:edit_plist).with("#{@subject.send(:path)}/Library/Caches/locationd/clients.plist")
        @subject.allow_gps_access('com.xing.israkel')
      end

      it "allows GPS acces" do
        hash = {}
        expect(Helper).to receive(:edit_plist).and_yield hash
        @subject.allow_gps_access('com.xing.israkel')
        expect(hash).to eq({
          'com.xing.israkel' => {
            'Authorized' => true,
            'BundleId' => 'com.xing.israkel',
            'Executable' => '',
            'Registered' => '',
            'Whitelisted' => false
          }
        })
      end
    end

    describe "#set_language" do
      it "opens the right plist" do
        expect(Helper).to receive(:edit_plist).with("#{@subject.send(:path)}/Library/Preferences/.GlobalPreferences.plist")
        @subject.set_language("de_DE")
      end

      it "writes the language" do
        hash = { 'AppleLanguages' => ['en', 'de'] }
        expect(@subject).to receive(:edit_global_preferences).and_yield hash
        @subject.set_language("de")
        expect(hash).to eq({'AppleLanguages' => ['de', 'en'] })
      end

      it "fails if language is invalid" do
        hash = { 'AppleLanguages' => ['fr'] }
        expect(@subject).to receive(:edit_global_preferences).and_yield hash
        expect { @subject.set_language("de") }.to raise_error(RuntimeError, "de is not a valid language")
      end
    end
  end

  context "simulator run tasks" do
    before do
      @subject = Device.from_hash(@hash)
      @path = File.join('spec', 'fixtures', 'sim_root_path')
      allow(Device).to receive(:sim_root_path) { @path }
    end

    it "#start" do
      expect(@subject).to receive(:system).with("ios-sim start --devicetypeid \"com.apple.CoreSimulator.SimDeviceType.iPhone-4s, 8.0\"")
      @subject.start
    end

    it "#reset" do
      sim_path = "spec/fixtures/sim_root_path/EFA1B4B1-5741-4396-AF52-F8AD29229CFC/data"
      expect(FileUtils).to receive(:rm_rf).with(sim_path)
      expect(FileUtils).to receive(:mkdir).with(sim_path)
      @subject.reset
    end
  end

  context "other public methods" do
    before { @subject = Device.from_hash(@hash) }

    it "#os" do
      expect(@subject.os).to eq('8.0')
    end
  end

  context "private methods" do
    before do
      @subject = Device.from_hash(@hash)
    end

    it "#to_s" do
      expect(@subject.to_s).to eq("iPhone 4s iOS 8.0")
    end

    it "#pretty_runtime" do
      expect(@subject.send(:pretty_runtime)).to eq('iOS 8.0')
    end


    it "#path" do
      expect(@subject.send(:path)).to eq("#{ENV['HOME']}/Library/Developer/CoreSimulator/Devices/EFA1B4B1-5741-4396-AF52-F8AD29229CFC/data")
    end

    it "#device_type" do
      expect(@subject.send(:device_type)).to eq("com.apple.CoreSimulator.SimDeviceType.iPhone-4s, 8.0")
    end
  end
end
