class JiraIssue

	attr_accessor :json

	def initialize json
		@json = json
	end

	def key 
		@json['key']
	end

	def title 
		"#{@json['fields']['summary']} * #{Settings.instance.hash['jira']['weburl']}/#{key}"
	end

	def status
		@json['fields']['status']['name']
	end

	def issuetype
		@json['fields']['issuetype']['name']
	end

	def labels
		@json['fields']['labels']
	end

	def versions
		@json['fields']['fixVersions'].collect { |version| version['name'] }
	end

	def sprints
		sprint_array = @json['fields'][Settings.instance.hash['jira']['config']['sprint']] || []
		sprint_array.collect {|sprint| sprint.match(/name\=(.*),startDate.*/)[1] } if sprint_array
	end

	def should_be_included?
		issuetype != 'Technical task' #hardcoded for now
	end
end