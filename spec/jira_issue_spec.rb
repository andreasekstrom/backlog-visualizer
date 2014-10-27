require_relative '../lib/jira_issue'
require 'json'

describe JiraIssue do
	it "has a key" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.key).to eq("TEST-21")
	end

	it "has a title containing text + url for issue, separated by a *" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.title).to eq("Om jag sparar apelsiner så lagras päron * https://services.ucr.uu.se/jira/browse/TEST-21")
	end

	it "has a status" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.status).to eq("Closed")
	end

	it "has labels" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.labels).to include("fruit")
	end

	it "has versions" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0]
		expect(issue.versions).to include("1.0") 
	end

	it "can tell if issue should be included" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.should_be_included?).to eq(true)
	end
end