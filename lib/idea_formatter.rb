class IdeaFormatter
	def initialize(config_list)
		@config_list = config_list
	end

	def for_issue issue
		rule = @config_list.find do |rule|
			send(rule[0], issue, rule[1])
		end
		rule ? rule[2] : '#E0E0E0'  
	end

	private
	def status(issue, value)
		issue.status == value
	end 

	def labels(issue, value)
		issue.labels.include? value
	end

	def version(issue, value)
		issue.versions.include? value
	end

end
