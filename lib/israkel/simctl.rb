class SIMCTL

  def self.list
    `xcrun simctl list`
  end

  def self.booted_devices_uuids
    devices = self.list.split("\n")
    devices.keep_if { |entry| entry =~ /(\(Booted\))/ }
    devices.map { |device| device.match(/\(([^\)]+)\)/)[1] }
  end

  def self.shutdown(device_uuid)
    system "xcrun simctl shutdown #{device_uuid}"
  end

  def self.erase(device_uuid)
    system "xcrun simctl erase #{device_uuid}"
  end

end
