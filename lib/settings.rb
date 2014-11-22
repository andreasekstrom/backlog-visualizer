require 'singleton'
class Settings
	include Singleton

	attr_accessor :hash
end