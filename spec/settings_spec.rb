require_relative '../lib/settings'

describe Settings do
	it "is a singleton" do
		x = Settings.instance
		y = Settings.instance
		expect(x).to eq(y) 
	end

	it "holds the settings hash" do
		Settings.instance.hash= {'a' => 'a1', 'b' => 'b1'}
		expect(Settings.instance.hash['a']).to eq 'a1'
	end
end