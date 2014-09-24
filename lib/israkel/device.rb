require 'cfpropertylist'

class Device

  attr_accessor :UUID, :type, :name, :state, :runtime

  def initialize(uuid, type, name, state, runtime)
    @UUID = uuid
    @type = type
    @name = name
    @state = state
    @runtime = runtime
  end

  def self.from_hash(hash)
    self.new(hash['UDID'], hash['deviceType'], hash['name'], hash['state'], hash['runtime'])
  end

  def self.from_plist(plist)
    self.from_hash(CFPropertyList.native_types(plist.value))
  end

  def self.with_sdk_version(sdk_version)
    Device.all.each do |device|
      return device if device.os == sdk_version
    end
    nil
  end

  def self.all
    devices = []
    dirs = Dir.entries(Device.sim_root_path).reject { |entry| File.directory? entry }
    dirs.sort.each do |simulator_dir|
      plist_path = "#{Device.sim_root_path}/#{simulator_dir}/device.plist"
      if File.exists?(plist_path)
        plist = CFPropertyList::List.new(:file => plist_path)
        devices << Device.from_plist(plist)
      end
    end
    devices
  end

  def to_s
    "#{name} #{pretty_runtime}"
  end

  def allow_addressbook_access(bundle_id)
    allow_tcc_access('kTCCServiceAddressBook', bundle_id)
  end

  def allow_photos_access(bundle_id)
    allow_tcc_access('kTCCServicePhotos', bundle_id)
  end

  def allow_gps_access(bundle_id)
    directory = File.join(path, 'Library', 'Caches', 'locationd')
    FileUtils.mkdir_p(directory) unless Dir.exists?(directory)
    Helper.edit_plist(File.join(directory, 'clients.plist')) do |content|
      set_gps_access(content, bundle_id)
    end
  end

  def set_language(language)
    edit_global_preferences do |p|
      unless p['AppleLanguages'].include?(language)
        fail "#{language} is not a valid language"
      end
      p['AppleLanguages'].unshift(language).uniq!
    end
  end

  def start
    sh 'ios-sim', 'start', '--devicetypeid', "\"#{device_type}\""
  end

  def stop
    sh 'killall', '-m', '-TERM', 'iPhone Simulator'
  end

  def reset
    rm_rf File.join(path)
    mkdir File.join(path)
  end

  def self.sim_root_path
    File.join(ENV['HOME'], 'Library', 'Developer', 'CoreSimulator', 'Devices')
  end

  def os
    runtime.gsub('com.apple.CoreSimulator.SimRuntime.iOS-', '').gsub('-', '.')
  end

  private

  def edit_global_preferences(&block)
    pref_path = File.join(path, 'Library', 'Preferences')
    Helper.edit_plist( File.join(pref_path, '.GlobalPreferences.plist'), &block )
  end

  def set_gps_access(hash, bundle_id)
    hash.merge!({
      bundle_id => {
        'Authorized'  => true,
        'BundleId'    => bundle_id,
        'Executable'  => "",
        'Registered'  => "",
        'Whitelisted' => false,
      }
    })
  end

  def allow_tcc_access(service, bundle_id)
    db_path = File.join(path, 'Library', 'TCC', 'TCC.db')
    db = SQLite3::Database.new(db_path)
    db.prepare "insert into access (service, client, client_type, allowed, prompt_count, csreq) values (?, ?, ?, ?, ?, ?)" do |query|
      query.execute service, bundle_id, 0, 1, 0, ""
    end
  end

  def pretty_runtime
    "iOS #{os}"
  end

  def path
    File.join(Device.sim_root_path, @UUID, 'data')
  end

  def device_type
    [@type, os].join(', ')
  end
end
