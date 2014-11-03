require_relative '../lib/idea_formatter'
require 'json'

describe IdeaFormatter do
	it "has default color grey" do
		issue = double(status: "Closed")
		idea_formatter = IdeaFormatter.new []
		color = idea_formatter.for_issue issue
		expect(color).to eq("#E0E0E0")
	end 

	it "can be configured for status" do
		issue = double(status: "Closed")
		issue2 = double(status: "Other")
		idea_formatter = IdeaFormatter.new [{'key' => 'status', 'value' => 'Closed', 'color' => '#008000'}]
		expect(idea_formatter.for_issue(issue)).to eq('#008000')
		expect(idea_formatter.for_issue(issue2)).to eq('#E0E0E0')
	end

	it "can be configured for label" do
		issue = double(labels: ["a", "b", "c"])
		issue2 = double(labels: ["other", "stuff"])
		idea_formatter = IdeaFormatter.new [{'key' => 'labels', 'value' => 'b', 'color' => '#008000'}]
		expect(idea_formatter.for_issue(issue)).to eq('#008000')
		expect(idea_formatter.for_issue(issue2)).to eq('#E0E0E0')
	end

	it "can be configured for version" do
		issue = double(versions: ['1.0','1.1'])
		issue2 = double(versions: ['1.2'])
		idea_formatter = IdeaFormatter.new [{'key' => 'versions', 'value' => '1.0', 'color' => '#008000'}]
		expect(idea_formatter.for_issue(issue)).to eq('#008000')
		expect(idea_formatter.for_issue(issue2)).to eq('#E0E0E0')
	end

	it "bases formatting on first match rule" do
		issue = double(versions: ['1.0','1.1'], status: "Closed")
		issue2 = double(versions: ['other'], status: "Closed")
		
		idea_formatter = IdeaFormatter.new [
			{'key' => 'versions', 'value' => '1.0', 'color' => '1'},
			{'key' => 'status', 'value' => 'Closed', 'color' => '2'}
		]
		expect(idea_formatter.for_issue(issue)).to eq('1')
		expect(idea_formatter.for_issue(issue2)).to eq('2')
	end
end