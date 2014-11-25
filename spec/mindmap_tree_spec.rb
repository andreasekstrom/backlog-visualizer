require_relative '../lib/mindmap_tree'
require 'json'

describe MindmapTree do
	it "can be constructed from mindmup hash" do
		mindmap = MindmapTree.new JSON.parse(File.read('spec/test2.mup'))
		expect(mindmap.root.name).to eq("ROOT")
		expect(mindmap.root).to have_children
		expect(mindmap.root['1']).to_not eq(nil)
	end

	it "can be constructed from multilevel mindmup hash" do
		mindmap = MindmapTree.new example_multilevel_map_json
		expect(mindmap.root['1']).to_not eq(nil)
		expect(mindmap.root['1'].content['title']).to eq('level 1')
		expect(mindmap.root['1']['1'].content['title']).to eq('level 2.1')
		expect(mindmap.root['1']['1']['1'].content['title']).to eq('level 3.1')
	end

	it "can construct a mindmup json" do
		mindmap = MindmapTree.new example_multilevel_map_json
		expect(mindmap.to_mindmap_json).to eql(example_multilevel_map_json)
	end

	it "can add a node to first level of map" do
		mindmap = MindmapTree.new example_multilevel_map_json
		expect(mindmap.root.first_child.breadth).to eq(1)
		mindmap.add("another")
		expect(mindmap.root.first_child.breadth).to eq(2)
		#mindmap.root.print_tree
	end

	it "can add a node to any part of tree" do
		mindmap = MindmapTree.new example_multilevel_map_json
		expect(mindmap.root.first_child.breadth).to eq(1)
		expect(mindmap.root.first_child.breadth).to eq(1)
		node = mindmap.root.first_child.first_child
		expect(node.content['title']).to eq('level 2.1')
		mindmap.add_to_node(node, "another")
		expect(mindmap.root.first_child.breadth).to eq(1)
		expect(mindmap.root.first_child.first_child.breadth).to eq(2)
	end

	it "sets name correct when adding a new node" do
		mindmap = MindmapTree.new example_multilevel_map_json
		mindmap.add("another")
		expect(mindmap.root.last_child.name).to eq("2")
	end

	it "sets id to highest id in map when adding a new node" do
		mindmap = MindmapTree.new example_multilevel_map_json
		mindmap.add("another")
		expect(mindmap.root.last_child.content).to eq({"title" => "another", "id" => 8})
	end

	it "sets additional attributes when adding a new node" do
		mindmap = MindmapTree.new example_multilevel_map_json
		mindmap.add("another", { "style" => {
                      "background" => "some_color"
                    }})
		expect(mindmap.root.last_child.content).to eq({"title" => "another", "id" => 8, "attr" => { "style" => {
                      "background" => "some_color"
                    }}})
	end

	it "keeps track of all nodes with JIRA-url" do
		Settings.instance.hash = {'jira' => {'weburl' => 'https://jira.com/browse' }}	
		mindmap = MindmapTree.new
		mindmap.add("Some story * https://jira.com/browse/AB-21")
		mindmap.add("another * https://jira.com/browse/BA-31")
		mindmap.add("no jira")
		expect(mindmap.jira_nodes.length).to eq(2)
	end

	describe "#sync_jira_issue" do
		it "syncs jira issues that is already in map" do
			Settings.instance.hash = {'jira' => {'weburl' => 'https://jira.com/browse' }, 'idea_formatter' => {}}	
			mindmap = MindmapTree.new example_jira_map_json
			#mindmap.jira_nodes.keys.each {|node| p node }
			issue = double(key: 'SCON-307', title: 'Changed name * https://jira.com/browse/SCON-307', status: 'Changed')
			mindmap.sync_jira_issue issue
			expect(mindmap.jira_nodes.length).to eq(2)
			expect(mindmap.jira_nodes['SCON-307'].content['title']).to eq('Changed name * https://jira.com/browse/SCON-307')
		end

		it "adds a new node for issues that are not in map" do
			Settings.instance.hash = {'jira' => {'weburl' => 'https://jira.com/browse' }, 'idea_formatter' => {}}	
			mindmap = MindmapTree.new example_jira_map_json
			issue = double(key: 'NEW-1', title: 'Changed name * https://jira.com/browse/NEW-1', status: 'In Development')
			mindmap.sync_jira_issue issue
			expect(mindmap.jira_nodes.length).to eq(3)
			#mindmap.jira_nodes.keys.each {|node| p node }
			expect(mindmap.jira_nodes['NEW-1'].content['title']).to eq('Changed name * https://jira.com/browse/NEW-1')			
		end

		it "unmapped issues are added under Uncategorized" do
			Settings.instance.hash = {'jira' => {'weburl' => 'https://jira.com/browse' }, 'idea_formatter' => {}}	
			mindmap = MindmapTree.new example_jira_map_json
			issue = double(key: 'NEW-1', title: 'Changed name * https://jira.com/browse/NEW-1', status: 'In Development')
			mindmap.sync_jira_issue issue
			expect(mindmap.jira_nodes['NEW-1'].parent.content['title']).to eq("Uncategorized")
		end
	end

	private
	def example_multilevel_map_json
		JSON.parse(File.read('spec/test_multi_level.mup'))
	end

	def example_jira_map_json
		JSON.parse(File.read('spec/test_jira.mup'))
	end
end