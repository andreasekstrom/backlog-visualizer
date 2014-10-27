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
		idea_formatter = IdeaFormatter.new [['status', 'Closed', '#008000']]
		expect(idea_formatter.for_issue(issue)).to eq('#008000')
		expect(idea_formatter.for_issue(issue2)).to eq('#E0E0E0')
	end

	it "can be configured for label" do
		issue = double(labels: ["a", "b", "c"])
		idea_formatter = IdeaFormatter.new [['labels', 'b', '#008000']]
		expect(idea_formatter.for_issue(issue)).to eq('#008000')
	end

	it "can be configured for version" do
		issue = double(versions: ['1.0','1.1'])
		issue2 = double(versions: ['1.2'])
		idea_formatter = IdeaFormatter.new [['version', '1.0', '#008000']]
		expect(idea_formatter.for_issue(issue)).to eq('#008000')
		expect(idea_formatter.for_issue(issue2)).to eq('#E0E0E0')
	end
end