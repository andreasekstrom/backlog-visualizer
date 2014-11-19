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

	it "can add a node to first level of map, setting id and name correct" do
		mindmap = MindmapTree.new example_multilevel_map_json
		expect(mindmap.root.first_child.breadth).to eq(1)
		mindmap.add("another")
		expect(mindmap.root.first_child.breadth).to eq(2)
		#mindmap.root.print_tree
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

	def example_multilevel_map_json
		JSON.parse(File.read('spec/test_multi_level.mup'))
	end
end