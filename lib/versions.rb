#!/usr/bin/env ruby

require 'rubygems'
require 'httparty'
require 'yaml'
require 'optparse'
require_relative 'jira_version'
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

	  opts.on("-m", "--add-measurement", "Add measurement 'storypoints' to JIRA-nodes") do |m|
	  	options[:measurement] = m
	  end
	end.parse!
	options
end

def lookup_versions_from_jira(settings, project)
	auth = {:username => settings['jira']['username'], :password => settings['jira']['password']}

	p "Calling JIRA with project: #{project}"
	response = HTTParty.get("https://services.ucr.uu.se/jira/rest/api/2/project/#{project}/versions", :basic_auth => auth)
	jira_versions_hash = JSON.parse(response.body)
	
	jira_versions_hash.collect do |item, i|
		JiraVersion.new(item, project)
	end
end

def lookup_projects_from_jira(settings)
	auth = {:username => settings['jira']['username'], :password => settings['jira']['password']}

	p "Calling JIRA for projects"
	response = HTTParty.get("https://services.ucr.uu.se/jira/rest/api/2/project", :basic_auth => auth)
	jira_projects_hash = JSON.parse(response.body)
	
	jira_projects_hash.collect do |item, i|
		item['key']
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

#exit_if_file_is_missing(settings_file_name)
exit_if_file_is_missing('settings_jira_credentials.yml')

settings = Settings.instance.hash = read_settings(settings_file_name)

projects = lookup_projects_from_jira settings

jira_versions = projects.collect {|project| lookup_versions_from_jira(settings, project) }

jira_versions.flatten.each do |version|
	next unless version.releaseDate && version.released?
	rd = Date.parse(version.releaseDate)
	if rd > Date.today - 14
		p "#{version.releaseDate} - #{version.project} - #{version.name} - #{version.description}"
	end
end

