require_relative '../lib/jira_issue'
require 'json'

describe JiraIssue do
	it "has a key" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.key).to eq("TEST-21")
	end

	it "has a title containing text + url for issue, separated by a *" do
		Settings.instance.hash = {'jira' => {'weburl' => 'https://jira.com/browse' }}	
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.title).to eq("Om jag sparar apelsiner så lagras päron * https://jira.com/browse/TEST-21")
	end

	it "has a status" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.status).to eq("Closed")
	end

	it "has an issuetype" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0]
		expect(issue.issuetype).to eq("Bug")
	end

	it "has labels" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.labels).to include("fruit")
	end

	it "has versions" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0]
		expect(issue.versions).to include("1.0") 
	end

	it "has storypoints" do
		Settings.instance.hash =  { 'jira' => { 'config' => { 'storypoints' => 'customfield_10043' }}}
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0]
		expect(issue.storypoints).to eq(5)
  end

  it "has epic link" do
		Settings.instance.hash =  { 'jira' => { 'config' => { 'epic_link' => 'customfield_10381' }}}
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0]
		expect(issue.epic_link).to eq("TEST-100")
  end

	it "tells sprint that issue belongs to" do
		Settings.instance.hash =  { 'jira' => { 'config' => { 'sprint' => 'customfield_10270' }}}
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0]
		expect(issue.sprints).to include("sprint1")
		expect(issue.sprints).to include("sprint including spaces")
		expect(issue.sprints).to_not include("sprint3")
	end

	it "handle issues that do not belong to any sprints" do
		Settings.instance.hash =  { 'jira' => { 'config' => { 'sprint' => 'customfield_10270' }}}
		json = JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0]
		json['fields'][Settings.instance.hash['jira']['config']['sprint']] = nil
		issue = JiraIssue.new json
		expect(issue.sprints).to eq []
	end

	it "can tell if issue should be included" do
		issue = JiraIssue.new JSON.parse(File.read('spec/jira_search_test.json'))['issues'][0] 
		expect(issue.should_be_included?).to eq(true)
	end
end