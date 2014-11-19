require 'tree'

class MindmapTree

	def initialize(hash)
		@highest_id = 1
    ideas = hash.delete 'ideas'
		@tree = Tree::TreeNode.new("ROOT", hash)
		create_node(ideas, @tree)
    
	end

	def create_node(ideas, root)
		if ideas
			ideas.each do |key, value|
				children = value.delete 'ideas'
				node = Tree::TreeNode.new(key, value)
        update_highest_id(value['id'])
				root << node 
				create_node(children, node) if children
			end	
		end
		#@tree.print_tree
	end

	def root
		@tree
	end

	def to_mindmap_json
    hash = @tree.content
    hash['ideas'] = to_node_json @tree
    hash
  end

  def to_node_json tree
		hash = {}
		tree.children do |child|
			hash[child.name] = child.content
			if child.has_children?
        hash[child.name]['ideas'] = to_node_json child
      end
		end
		hash
	end

  def add title
    name = find_highest_child_name(@tree)

    @highest_id +=1
    @tree << Tree::TreeNode.new(name, {'title' => title, 'id' => @highest_id})
  end

  private

  def update_highest_id number 
    @highest_id = number if number > @highest_id
  end

  def find_highest_child_name(root)
    (root.children.collect {|child| child.name.to_i}.sort.last + 1).to_s
  end 
end
