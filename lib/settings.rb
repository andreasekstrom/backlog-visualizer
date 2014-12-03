require 'singleton'
class Settings
	include Singleton

	attr_writer :hash

	def hash
		@hash || {}
	end
end