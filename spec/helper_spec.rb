require 'spec_helper'

describe Helper do  
  describe "#edit_plist" do
    it "calls the block" do
      expect { |b| Helper.edit_plist('spec/fixtures/madeup.plist', &b) }.to yield_with_args({})
    end

    it "returns empty hash if file doesn't exist" do
      Helper.edit_plist('spec/fixtures/madeup.plist') do |content|
        expect(content).to eq({})
      end
    end

    it "returns hash" do
      Helper.edit_plist('spec/fixtures/test.plist') do |content|
        expect(content).to eq({'test' => 'YAAYY'})
      end
    end
  end
end
