require_relative '../lib/mindmap_tree_node'

describe MindmapTreeNode do

	describe '#from_jira?' do
		it "false if node does not have JIRA url i title" do
			Settings.instance.hash = {'jira' => {'weburl' => 'https://jira.com/browse' }}
			node = MindmapTreeNode.new "test", {"title" => "testing", "id" => 8}
			expect(node.from_jira?).to eq(false)
		end

		it "true if node has JIRA url i title" do
			Settings.instance.hash = {'jira' => {'weburl' => 'https://jira.com/browse' }}
			node = MindmapTreeNode.new "test", {"title" => "testing * https://jira.com/browse/AURFF-62", "id" => 8}
			expect(node.from_jira?).to eq(true)
		end
	end

	describe '#jira_issue_key' do
		it "returns JIRA issue key if link with correct prefix is found" do
			Settings.instance.hash = {'jira' => {'weburl' => 'https://jira.com/browse' }}
			node = MindmapTreeNode.new "test", {"title" => "testing * https://jira.com/browse/AURFF-62", "id" => 8}
			expect(node.jira_issue_key).to eq("AURFF-62")
		end

		it "returns if no link with correct prefix is found" do
			Settings.instance.hash = {'jira' => {'weburl' => 'https://jira.com/browse' }}
			node = MindmapTreeNode.new "test", {"title" => "testing * https://jira.blaha.com/browse/AURFF-62", "id" => 8}
			expect(node.jira_issue_key).to be(nil)
		end
	end

end
