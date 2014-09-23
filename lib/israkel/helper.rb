require 'cfpropertylist'

module Helper
  def edit_plist(path, &block)
    if File.exists?(path)
      plist = CFPropertyList::List.new(:file => path)
      content = CFPropertyList.native_types(plist.value)
    end
    yield content || {}
    if plist
      plist.save(path, CFPropertyList::List::FORMAT_BINARY)
    end
  end
end
