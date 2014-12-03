#!/usr/bin/env ruby

require 'rubygems'
require 'httparty'
require 'yaml'
require 'optparse'
require_relative 'mindmap_tree'
require_relative 'jira_issue'
require_relative 'idea_formatter'
require_relative 'settings'

def get_in_arguments
	options = {}

	OptionParser.new do |opts|
	  opts.banner = "Usage: jiramap.rb [options]"

	  opts.on("-s", "--settings filename", "Settings file name (if omitted 'settings.yml' is used)") do |s|
	    options[:settings_file] = s
	  end

	  opts.on("-l", "--legend", "Create a legend node that describes colors used in map") do |l|
	  	options[:legend] = l
	  end

	  opts.on("-o", "--out filename", "Output filename (if ommitted 'temp.mup' will be used) ") do |o|
	  	options[:output_file] = o
	  end
	end.parse!
	options
end

def lookup_issues_from_jira(settings)
	auth = {:username => settings['jira']['username'], :password => settings['jira']['password']}

	p "Calling JIRA with url: #{settings['jira']['rest_search_url']}..."
	response = HTTParty.get(settings['jira']['rest_search_url'], :basic_auth => auth)
	jira_issues_hash = JSON.parse(response.body)
	
	jira_issues_hash['issues'].collect do |item, i|
		JiraIssue.new(item)
	end
end

def read_settings(settings_file_name)
	settings = YAML.load_file(settings_file_name)	
	settings_credentials = YAML.load_file('settings_jira_credentials.yml') 
	settings['jira']['username'] = settings_credentials['username']
	settings['jira']['password'] = settings_credentials['password']
	settings
end

def exit_if_file_is_missing(filename)
	unless File.exists?(filename)
		p "File: '#{filename}'' is missing. Please copy/adapt #{filename}_example.yml." 
		exit 
	end
end

options = get_in_arguments
p "Parameters: #{options}" 

settings_file_name = options[:settings_file] || 'settings.yml'

exit_if_file_is_missing(settings_file_name)
exit_if_file_is_missing('settings_jira_credentials.yml')

settings = Settings.instance.hash = read_settings(settings_file_name)

jira_issues = lookup_issues_from_jira(settings)

mindmap = MindmapTree.new JSON.parse(File.read(settings['mindmup']['original_file']))

jira_issues.each_with_index do |item, i|
	if item.should_be_included?
		mindmap.sync_jira_issue(item)
    end
end

mindmap.add_legend_nodes if options[:legend]

output_filename = options[:output_file] || 'temp'

File.open("#{output_filename}.mup","w") do |f|
  f.write(mindmap.to_mindmap_json.to_json)
end

File.open("sync-log-#{Time.now.strftime("%Y%m%dT%H%M%S")}","w") do |f|
  f.write("After sync: Existing issues in map\n") 
  mindmap.jira_nodes.each do |key, value|
  	f.write("#{key} - #{value.content['title']}\n")
  end
end
