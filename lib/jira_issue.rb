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
		@json['fields']['fixVersions']
	end

	def should_be_included?
		true
	end
end