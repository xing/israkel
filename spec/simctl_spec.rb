require 'spec_helper'

describe SIMCTL do
 
  describe "#booted_devices_uuids" do
    before do
      allow(SIMCTL).to receive(:list) { File.readlines(File.join('spec', 'fixtures', 'simctl_list_output.txt')).join("\n") }
    end

    it "returns all uuids for booted devices" do
      expect(SIMCTL.booted_devices_uuids).to eql([
        "1B22E427-F9BE-45D3-BD38-97C80AA8EC27", 
        "B87B2ED8-E184-44E0-AC02-4B162AB5FDD4"
      ])
    end

    it "shuts down the process via simctl" do
      SIMCTL.booted_devices_uuids.each do |uuid|
        expect(SIMCTL).to receive(:system).with("xcrun simctl shutdown #{uuid}")
        SIMCTL.shutdown(uuid)
      end
    end

    it "erase the device via simctl" do
      SIMCTL.booted_devices_uuids.each do |uuid|
        expect(SIMCTL).to receive(:system).with("xcrun simctl erase #{uuid}")
        SIMCTL.erase(uuid)
      end
    end
  end

end
