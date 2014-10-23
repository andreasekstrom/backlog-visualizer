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
	true
end

JIRA_WEB_URL="https://services.ucr.uu.se/jira/browse"

jira = JSON.parse(File.read('search_all.json'))
mindmap = JSON.parse(File.read('new_aurff.mup'))
jira['issues'].each_with_index do |item, i|
	puts "#{i}: #{item['fields']['summary']}"
end

ID_START=2000
mindmap['ideas'][ID_START.to_s] = {
                      "title" => "Uncategorized",
                      "id" => ID_START
                    }
new_issues = mindmap['ideas'][ID_START.to_s]['ideas'] = {}
jira['issues'].each_with_index do |item, i|
	if should_be_included(item)
	 	new_issues[(i+ID_START+1).to_s] = { 'title' => idea_title(item), 'id' => i+ID_START+1, "attr" => {
                    "style" => {
                      "background" => idea_color(item)
                    }
                  }}
    end
end
                  
File.open("temp.mup","w") do |f|
  f.write(mindmap.to_json)
end

