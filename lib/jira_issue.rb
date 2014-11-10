class JiraIssue
	JIRA_WEB_URL="https://services.ucr.uu.se/jira/browse"

	attr_accessor :json

	def initialize json
		@json = json
	end

	def key 
		@json['key']
	end

	def title 
		"#{@json['fields']['summary']} * #{JIRA_WEB_URL}/#{key}"
	end

	def status
		@json['fields']['status']['name']
	end

	def labels
		@json['fields']['labels']
	end

	def versions
		@json['fields']['fixVersions'].collect { |version| version['name'] }
	end

	def sprints
		sprint_array = @json['fields']['customfield_10270'] || []
		sprint_array.collect {|sprint| sprint.match(/name\=(.*),startDate.*/)[1] } if sprint_array
	end

	def should_be_included?
		true
	end
end