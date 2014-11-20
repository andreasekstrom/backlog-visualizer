require 'tree'

class MindmapTreeNode < Tree::TreeNode
	JIRA_ISSUE_LINK_REGEXP = Regexp.escape("https://services.ucr.uu.se/jira/browse")

	def from_jira?
		content && content['title'] && !!(content['title'] =~ /#{JIRA_ISSUE_LINK_REGEXP}/)
	end
end
