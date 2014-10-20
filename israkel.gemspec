Gem::Specification.new do |s|
  s.name = "israkel"
  s.version = "1.0.0"
  s.require_paths = ["lib"]
  s.authors = ["Johannes Plunien", "Stefan Munz", "Matthias Männich", "Piet Brauer"]
  s.description = "Collection of common rake tasks for the iPhone Simulator like start/stop and some more."
  s.email = ["johannes.plunien@xing.com", "stefan.munz@xing.com", "matthias.maennich@xing.com", "piet.brauer@xing.com"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "lib/israkel.rb",
    "lib/israkel/device.rb",
    "lib/israkel/tasks.rb",
  ]
  s.homepage = "http://github.com/xing/israkel"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Collection of common rake tasks for the iPhone Simulator."
  s.add_runtime_dependency 'highline', '~> 1.6', '>= 1.6.15'
  s.add_runtime_dependency 'json', '~> 1.8', '>= 1.8.0'
  s.add_runtime_dependency 'rake', '~> 10.3', '>= 10.3.2'
  s.add_runtime_dependency 'sqlite3', '~> 1.3', '>= 1.3.7'
  s.add_runtime_dependency 'CFPropertyList', '~> 2.2', '>= 2.2.8'
end

