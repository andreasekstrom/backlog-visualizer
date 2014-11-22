require 'tree'
require_relative 'settings'

class MindmapTreeNode < Tree::TreeNode
	
	def initialize name, content
		weburl =  Settings.instance.hash['jira']['weburl']
		@jira_issue_link_regexp = Regexp.escape(weburl)
		super
	end

	def from_jira?
		content && content['title'] && !!(content['title'] =~ /#{@jira_issue_link_regexp}/)
	end
end
