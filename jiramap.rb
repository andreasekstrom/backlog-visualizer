#!/usr/bin/ruby

require 'json'

def idea_title(item) 
	"#{item['fields']['summary']} * #{JIRA_WEB_URL}/#{item['key']}"
end

def idea_color(item)
	status_name = item['fields']['status']['name']
	labels = item['fields']['labels']
	version = item['fields']['fixVersions'][0]['name'] unless item['fields']['fixVersions'].empty?
	case status_name
	when "Closed"
		if labels.include? "customer_accepted"
			"#008000"
		else	
			"#FFFF00"
		end		
	else 
		if version == '1.0'
			"#FFC0CB"
		else
			"#E0E0E0"
		end
	end 		
end

def should_be_included(item)
	item['fields']['issuetype']['name'] != "Technical task"
end

def existing_idea?(item, existing_jira_issues)
	key = item['key']
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

def update_existing(mindmap, item, remove_filter)
	mindmap.each do |key, idea|
		if idea.has_key? 'ideas'
			update_existing(idea['ideas'], item, remove_filter)
	 	end
	
		if idea['title'] && idea['title'].match(/#{JIRA_ISSUE_LINK_REGEXP}\/#{item['key']}$/)
			p "Found #{item['key']}"
			
			if (!idea.has_key?('ideas') || idea['ideas'].empty?) && remove_filter
				p "Remove - check #{item['key']}"
				if item['fields']['status']['name'] == "Closed" 
					mindmap.delete key
					p "Removed #{item['key']}"
				end
			else 
				idea['title'] = idea_title(item)
				idea['attr'] = {
                    "style" => {
                      "background" => idea_color(item)
                    }
                  }
      end
    end
	end
end

remove_filter = true

JIRA_WEB_URL="https://services.ucr.uu.se/jira/browse"
JIRA_ISSUE_LINK_REGEXP = Regexp.escape(JIRA_WEB_URL)

jira = JSON.parse(File.read('search_all.json'))
mindmap = JSON.parse(File.read('aurff_new2.mup'))

p "JIRA-issues to sync:"
jira['issues'].each_with_index do |item, i|
	p "#{i}: #{item['fields']['summary']}"
end

existing_jira_issues = scan_existing_jira_issues_in_map('aurff_new2.mup')
p "Existing issues in map: #{existing_jira_issues}"

ID_START=2000
mindmap['ideas'][ID_START.to_s] = {
                      "title" => "Uncategorized",
                      "id" => ID_START
                    }
new_issues = mindmap['ideas'][ID_START.to_s]['ideas'] = {}

jira['issues'].each_with_index do |item, i|
	if should_be_included(item)
		if existing_idea?(item, existing_jira_issues)
			update_existing(mindmap['ideas'], item, remove_filter)
		else
	 		new_issues[(i+ID_START+1).to_s] = { 'title' => idea_title(item), 'id' => i+ID_START+1, "attr" => {
                    "style" => {
                      "background" => idea_color(item)
                    }
                  }}
        end
    end
end

File.open("temp.mup","w") do |f|
  f.write(mindmap.to_json)
end

