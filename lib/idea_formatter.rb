class IdeaFormatter
	def initialize(config_list)
		@config_list = config_list
	end

	def for_issue issue
		rule = @config_list.find do |rule|
			send(rule['key'], issue, rule['value'])
		end
		rule ? rule['color'] : '#E0E0E0'  
	end

	private
	def status(issue, value)
		issue.status == value
	end 

	def labels(issue, value)
		issue.labels.include? value
	end

	def versions(issue, value)
		issue.versions.include? value
	end

	def sprints(issue, value)
		issue.sprints.include? value
	end

	def issuetype(issue, value)
		issue.issuetype == value
	end
end
