require_relative 'mindmap_tree_node'
require_relative 'idea_formatter'

class MindmapTree

  attr_accessor :jira_nodes

	def initialize(hash={})
    @idea_formatter = IdeaFormatter.new(Settings.instance.hash['idea_formatter'])
		@highest_id = 1
    @jira_nodes = {}
    ideas = hash.delete 'ideas'
		@tree = Tree::TreeNode.new("ROOT", hash)
    create_nodes(ideas, @tree)
	end

	def create_nodes(ideas, root)
		if ideas
			ideas.each do |key, value|
				children = value.delete 'ideas'
        #p "Key: #{key}, #{value}"
				node = MindmapTreeNode.new(key, value)
        store_jira_node(node) if node.from_jira?
        update_highest_id(value['id'])
				root << node 
				create_nodes(children, node) if children
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

  def add(title, attributes = nil)
    name = find_highest_child_name(@tree)

    @highest_id +=1
    value = {'title' => title, 'id' => @highest_id}
    value["attr"] = attributes if attributes 
    node = MindmapTreeNode.new(name, value)
    @tree << node
    store_jira_node(node) if node.from_jira?
  end

  def sync_jira_issue(issue)
    attr_hash = {
      "style" => {
          "background" => @idea_formatter.for_issue(issue)
      }
    }   

    existing = @jira_nodes[issue.key]
    if existing
      existing.content['title'] = issue.title
      existing.content['attr'] = attr_hash
    else
      add(issue.title, attr_hash)
    end
  end

  private

  def update_highest_id number 
    @highest_id = number if number > @highest_id
  end

  def find_highest_child_name(root)
    id = root.children.collect {|child| child.name.to_i}.sort.last || 0
    (id + 1).to_s
  end 

  def store_jira_node(node)
    @jira_nodes[node.jira_issue_key] = node
  end
end
