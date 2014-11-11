#!/usr/bin/ruby

require 'rubygems'
require 'httparty'
require 'yaml'
require 'optparse'
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

#ruby ./lib/jiramap.rb -s settings_another.yml

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: jiramap.rb [options]"

  opts.on("-s", "--settings name", "Settings file name (if omitted 'settings.yml' is used)") do |s|
    options[:settings_file] = s
  end
end.parse!

p "Parameters: #{options}" 

settings_file_name = options[:settings_file] || 'settings.yml'

unless File.exists?(settings_file_name)
	p "File: '#{settings_file_name}'' is missing. Please copy/adapt settings_example.yml." 
	exit 
end

settings = YAML.load_file(settings_file_name)

JIRA_WEB_URL=settings['jira']['weburl']
JIRA_ISSUE_LINK_REGEXP = Regexp.escape(JIRA_WEB_URL)

auth = {:username => settings['jira']['username'], :password => settings['jira']['password']}

p "Calling JIRA with url: #{settings['jira']['rest_search_url']}..."
response = HTTParty.get(settings['jira']['rest_search_url'], :basic_auth => auth)

jira_issues_hash = JSON.parse(response.body)
#p "JIRA-json: #{jira_issues_hash}"

idea_formatter = IdeaFormatter.new settings['idea_formatter']
mindmap = Mindmap.new(JSON.parse(File.read(settings['mindmup']['original_file'])), idea_formatter)

jira_issues = []

p "JIRA-issues to sync:"
jira_issues_hash['issues'].each_with_index do |item, i|
	p "#{i}: #{item['fields']['summary']}"
	jira_issues << JiraIssue.new(item)
end

existing_jira_issues = scan_existing_jira_issues_in_map(settings['mindmup']['original_file'])
p "Existing issues in map: #{existing_jira_issues}"

jira_issues.each_with_index do |item, i|
	if item.should_be_included?
		if existing_idea?(item, existing_jira_issues)
			mindmap.update_existing(item)
		else
	 		mindmap.add_to_uncategorized_ideas item
        end
    end
end

File.open("temp.mup","w") do |f|
  f.write(mindmap.json.to_json)
end

