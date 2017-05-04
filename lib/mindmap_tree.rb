require_relative 'mindmap_tree_node'
require_relative 'idea_formatter'

class MindmapTree

  attr_accessor :jira_nodes

	def initialize(hash={})
    @idea_formatter = IdeaFormatter.new(Settings.instance.hash['idea_formatter'] || [])
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
    add_to_node(@tree, title, attributes)
  end

  def add_to_node(root, title, attributes = nil)
    name = find_highest_child_name(root)

    @highest_id +=1
    value = {'title' => title, 'id' => @highest_id}
    value["attr"] = attributes if attributes 
    node = MindmapTreeNode.new(name, value)
    root << node
    store_jira_node(node) if node.from_jira?
    node
  end

  def sync_jira_issue(issue, use_storypoints = false, show_epic=false)
    attributes = style_attribute_for(@idea_formatter.for_issue(issue))
    attributes.merge!(storypoints_attributes_for(issue)) if use_storypoints
    existing = @jira_nodes[issue.key]
    title_to_use = "#{issue.key} - #{issue.title}"
    title_to_use << " (#{issue.epic_link})" if show_epic && issue.epic_link
    if existing
      existing.content['title'] = title_to_use
      existing.content['attr'] = attributes 
    else
      add_to_node(find_or_create_uncategorized_node, title_to_use, attributes)
    end
  end

  def add_legend_nodes
    legend = reset_or_create_legend_node
    Settings.instance.hash['idea_formatter'].each do |item|
      add_to_node(legend, "#{item['key']} = #{item['value']}", style_attribute_for(item['color']))
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

  def find_or_create_uncategorized_node
    uncategorized_nodes = @tree.children.select {|child| child.content['title'] == 'Uncategorized'}
    uncategorized_nodes.empty? ?  add("Uncategorized") : uncategorized_nodes[0]
  end

  def reset_or_create_legend_node
    legend_nodes = @tree.children.select {|child| child.content['title'] == 'Legend'}
    node = legend_nodes.empty? ?  add("Legend") : legend_nodes[0]
    node.remove_all!
  end

  def style_attribute_for(color)
    {
      "style" => {
          "background" => color
      }
    }   
  end

  def storypoints_attributes_for(issue)
    {
      "measurements" => {
        "storypoints" => issue.storypoints.to_s
      }
    }
  end
end
