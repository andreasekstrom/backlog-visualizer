Backlog Visualizer
==================

What?
-----

A small hack to improve upon an impact map by adding status from a backlog tool (JIRA).

Basic idea
----------

1. [Mindmup](https://www.mindmup.com) is a great tool to create and share impact maps
2. My company uses JIRA as an agile management tool
3. In my opinion; JIRA does not provide a clear overview where I can show a customer where we are going and what goals we are working on right now
4. __It would be great to start with a mindmup and automatically add information from JIRA__
5.  __It would be great to be able to sync mindmap with JIRA at any time (without touching nodes that are not connected to a JIRA Story)__ 

Mindmup does not provide an API to change a mindmap. But my 'heureka' moment was when I realized that a Mindmup ["*.mup" file is just a json-file](https://github.com/mindmup/mapjs/wiki/Data-Format). 
So the basic idea of this tool is to take an existing "*.mup"-file and add status information and links to JIRA in that map, with a single shell-command.

## Requirements
* Ruby must be installed (Tested with Ruby 2.1)
* Bundler must be installed (gem install bundler)

## Install & use
1. Clone this repo and run:

		bundle install

3. Create a mindmap on mindmup.com (or use Mindmup Chrome Desktop app), store the map in same folder as cloned repo
4. Create a settings.yml file (copy settings_example.yml and adapt to your needs, i.e. configure JIRA-search url, credentials, choose colors for JIRA-statuses etc.)
5. Run command:

		./lib/jiramap.sh
6. Whenever you want to resync the map with current JIRA status, just run the command again

### TODOs (maybe...)
* Very inefficient node traversal right now. Use an internal node-structure in tool instead of just wrapping a JSON-hash?
* Make it possible to filter out all nodes that are "DONE" according to JIRA

Do you like the idea? Please comment, make Pull requests or fork the project at your will!







