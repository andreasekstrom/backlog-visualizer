require_relative '../lib/mindmap_tree_node'

describe MindmapTreeNode do

	describe '#from_jira?' do
		it "false if node does not have JIRA url i title" do
			Settings.instance.hash = {'jira' => {'weburl' => 'https://services.ucr.uu.se/jira/browse' }}
			node = MindmapTreeNode.new "test", {"title" => "testing", "id" => 8}
			expect(node.from_jira?).to eq(false)
		end

		it "true if node has JIRA url i title" do
			Settings.instance.hash = {'jira' => {'weburl' => 'https://services.ucr.uu.se/jira/browse' }}
			node = MindmapTreeNode.new "test", {"title" => "testing * https://services.ucr.uu.se/jira/browse/AURFF-62", "id" => 8}
			expect(node.from_jira?).to eq(true)
		end
	end

end
