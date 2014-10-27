require_relative '../lib/mindmap'
require 'json'

describe Mindmap do
  it "creates ideas if it does not exist" do
    mindmap = Mindmap.new JSON.parse(File.read('spec/test.mup'))
  end

  it "creates an idea Uncategorized if it does not exists" do
  	mindmap = Mindmap.new JSON.parse(File.read('spec/test2.mup'))
  	expect(mindmap.uncategorized_node_id).not_to be_nil 
  	expect(mindmap.uncategorized_node_id).not_to eq(Mindmap::ID_HIGH) 
  end

  it "does not create an Uncategorized idea if it already exists" do
  	mindmap = Mindmap.new JSON.parse(File.read('spec/test3.mup'))
  	expect(mindmap.json['ideas'].length).to eq(1)
  end

  it "can add an idea to Uncategorized" do
  	item = double(title: "Testing", color: "n/a")
  	#expect(dbl).to receive(:foo).and_return(14)
  	mindmap = Mindmap.new JSON.parse(File.read('spec/test.mup'))
  	mindmap.add_to_uncategorized_ideas item
  	expect(mindmap.uncategorized_ideas.length).to eq 1
  end


end