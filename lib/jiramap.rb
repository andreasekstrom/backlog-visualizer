#!/usr/bin/ruby

require 'json'
require_relative 'mindmap'
require_relative 'jira_issue'
require_relative 'idea_formatter'

def should_be_included(item)
	item.json['fields']['issuetype']['name'] != "Technical task"
end

def existing_idea?(item, existing_jira_issues)
	key = item.json['key']
	existing_jira_issues.include? key
end

def scan_existing_jira_issues_in_map(filename)
	issues = []
	File.readlines(filename).each do |line| 
		match = line.match(/#{JIRA_ISSUE_LINK_REGEXP}\/(.*)\"/)
		issues << match[1] if match
	end
	issues
end

remove_filter = true

JIRA_WEB_URL="https://services.ucr.uu.se/jira/browse"
JIRA_ISSUE_LINK_REGEXP = Regexp.escape(JIRA_WEB_URL)

jira_issues_hash = JSON.parse(File.read('search_all.json'))
mindmap = Mindmap.new JSON.parse(File.read('aurff_new2.mup'))

idea_formatter = IdeaFormatter.new [['status', 'Closed', '#008000']]

jira_issues = []

p "JIRA-issues to sync:"
jira_issues_hash['issues'].each_with_index do |item, i|
	p "#{i}: #{item['fields']['summary']}"
	jira_issues << JiraIssue.new(item)
end

existing_jira_issues = scan_existing_jira_issues_in_map('aurff_new2.mup')
p "Existing issues in map: #{existing_jira_issues}"

jira_issues.each_with_index do |item, i|
	if item.should_be_included?
		if existing_idea?(item, existing_jira_issues)
			mindmap.update_existing(item, remove_filter)
		else
	 		mindmap.add_to_uncategorized_ideas item
        end
    end
end

File.open("temp.mup","w") do |f|
  f.write(mindmap.json.to_json)
end

