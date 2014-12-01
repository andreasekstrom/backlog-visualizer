#!/usr/bin/env ruby

require 'rubygems'
require 'httparty'
require 'yaml'
require 'optparse'
require_relative 'mindmap_tree'
require_relative 'jira_issue'
require_relative 'idea_formatter'
require_relative 'settings'

def should_be_included(item)
	item.json['fields']['issuetype']['name'] != "Technical task"
end

def get_in_arguments
	options = {}

	OptionParser.new do |opts|
	  opts.banner = "Usage: jiramap.rb [options]"

	  opts.on("-s", "--settings name", "Settings file name (if omitted 'settings.yml' is used)") do |s|
	    options[:settings_file] = s
	  end
	end.parse!
	options
end

options = get_in_arguments
p "Parameters: #{options}" 

settings_file_name = options[:settings_file] || 'settings.yml'

unless File.exists?(settings_file_name)
	p "File: '#{settings_file_name}'' is missing. Please copy/adapt settings_example.yml." 
	exit 
end

settings = Settings.instance.hash = YAML.load_file(settings_file_name)

#JIRA_WEB_URL=settings['jira']['weburl']
#JIRA_ISSUE_LINK_REGEXP = Regexp.escape(JIRA_WEB_URL)

auth = {:username => settings['jira']['username'], :password => settings['jira']['password']}

p "Calling JIRA with url: #{settings['jira']['rest_search_url']}..."
response = HTTParty.get(settings['jira']['rest_search_url'], :basic_auth => auth)

jira_issues_hash = JSON.parse(response.body)
#p "JIRA-json: #{jira_issues_hash}"

#idea_formatter = IdeaFormatter.new settings['idea_formatter']
#mindmap = Mindmap.new(JSON.parse(File.read(settings['mindmup']['original_file'])), idea_formatter)
mindmap = MindmapTree.new JSON.parse(File.read(settings['mindmup']['original_file']))

jira_issues = []

p "JIRA-issues to sync:"
jira_issues_hash['issues'].each_with_index do |item, i|
	p "#{i}: #{item['key']} - #{item['fields']['summary']}"
	jira_issues << JiraIssue.new(item)
end

#existing_jira_issues = scan_existing_jira_issues_in_map(settings['mindmup']['original_file'])
#p "Existing issues in map: #{existing_jira_issues}"

jira_issues.each_with_index do |item, i|
	if item.should_be_included?
		mindmap.sync_jira_issue(item)
    end
end
mindmap.add_legend_nodes

File.open("temp.mup","w") do |f|
  f.write(mindmap.to_mindmap_json.to_json)
end

