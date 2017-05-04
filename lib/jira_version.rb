class JiraVersion

	attr_accessor :json, :project

	def initialize json, project
		@json = json
		@project = project
	end

	def releaseDate 
		@json['releaseDate']
	end

	def description 
		@json['description']
	end

	def name
		@json['name']
	end

	def released?
		@json['released']
	end
end