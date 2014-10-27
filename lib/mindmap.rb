require_relative 'idea_formatter'

class Mindmap
	attr_accessor :uncategorized_node_id, :json, :highest_id

	ID_HIGH = 10000

	def initialize(json, idea_formatter = IdeaFormatter.new([]))
		@json = json
		@idea_formatter = idea_formatter
		@json['ideas'] ||= {}   
		@uncategorized_node_id = find_uncategorized_node_id || ID_HIGH.to_s
		
		unless @json['ideas'][@uncategorized_node_id]  
			@json['ideas'][@uncategorized_node_id] = {
                      "title" => "Uncategorized",
                      "id" => @uncategorized_node_id,
                      "ideas" => {}
                    }
        end
        @highest_id = ID_HIGH + 1
	end

	def add_to_uncategorized_ideas jira_issue
		uncategorized_ideas[new_id.to_s] = { 'title' => jira_issue.title, 'id' => new_id, "attr" => {
                    "style" => {
                      "background" => @idea_formatter.for_issue(jira_issue)
                    }
                  }} 
	end

	def update_existing(item, remove_filter)
		update_existing_for_idea(@json['ideas'], item, remove_filter)	
	end

	def update_existing_for_idea(mindmap, item, remove_filter)
		mindmap.each do |key, idea|
			if idea.has_key? 'ideas'
				update_existing_for_idea(idea['ideas'], item, remove_filter)
		 	end
		
			if idea['title'] && idea['title'].match(/#{JIRA_ISSUE_LINK_REGEXP}\/#{item.key}$/)
				
				# if (!idea.has_key?('ideas') || idea['ideas'].empty?) && remove_filter
				# 	p "Remove - check #{item.key}"
				# 	if item.status == "Closed" 
				# 		mindmap.delete key
				# 		p "Removed #{item.key}"
				# 	end
				# else 
				idea['title'] = item.title
				idea['attr'] = {
	            	"style" => {
                      "background" => @idea_formatter.for_issue(item)
                    }
                  }
	      		
	    	end
		end
	end

	def uncategorized_ideas
		@json['ideas'][@uncategorized_node_id]['ideas']
	end

	private
	def find_uncategorized_node_id
		ids = @json['ideas'].each_key.select { |key| @json['ideas'][key]['title'] == 'Uncategorized' }
		raise "Does not allow 2 uncategorized nodes" if ids.length > 1
		ids[0]
	end

	def new_id
		@highest_id +=1
		@highest_id
	end
end
