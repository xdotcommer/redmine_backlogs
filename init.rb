require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'issue'

  if Issue.const_defined? "SAFE_ATTRIBUTES"
    Issue::SAFE_ATTRIBUTES << "story_points"
    Issue::SAFE_ATTRIBUTES << "remaining_hours"
    Issue::SAFE_ATTRIBUTES << "position"
  else
    Issue.safe_attributes "story_points", "remaining_hours", "position"
  end

  require_dependency 'backlogs_query_patch'
  require_dependency 'backlogs_issue_patch'
  require_dependency 'backlogs_version_patch'
  require_dependency 'backlogs_project_patch'
  require_dependency 'backlogs_user_patch'
  require_dependency 'backlogs_my_controller_patch'
end

require_dependency 'backlogs_hooks'

Redmine::Plugin.register :redmine_backlogs do
  name 'Redmine Backlogs'
  author 'relaxdiego, friflaj'
  description 'A plugin for agile teams'
  version 'master branch (unstable)'

  settings :default => { 
                         :story_trackers  => nil, 
                         :task_tracker    => nil, 
                         :card_spec       => nil 
                       }, 
           :partial => 'shared/settings'

  project_module :backlogs do
    # SYNTAX: permission :name_of_permission, { :controller_name => [:action1, :action2] }
        
    # Master backlog permissions
    permission :view_master_backlog, { 
                                       :rb_master_backlogs  => :show,
                                       :rb_sprints          => [:index, :show],
                                       :rb_wikis            => :show,
                                       :rb_stories          => [:index, :show],
                                       :rb_queries          => :show,
                                       :rb_server_variables => :show,
                                       :rb_burndown_charts  => :show,
                                       :rb_updated_items    => :show
                                     }
    
    permission :view_taskboards,     { 
                                       :rb_taskboards       => :show,
                                       :rb_sprints          => :show,
                                       :rb_stories          => [:index, :show],
                                       :rb_tasks            => [:index, :show],
                                       :rb_impediments      => [:index, :show],
                                       :rb_wikis            => :show,
                                       :rb_server_variables => :show,
                                       :rb_burndown_charts  => :show,
                                       :rb_updated_items    => :show
                                     }

    # Sprint permissions
    # :show_sprints and :list_sprints are implicit in :view_master_backlog permission
    permission :update_sprints,      { 
                                        :rb_sprints => [:edit, :update],
                                        :rb_wikis   => [:edit, :update]
                                      }
    
    # Story permissions
    # :show_stories and :list_stories are implicit in :view_master_backlog permission
    permission :create_stories,         { :rb_stories => :create }
    permission :update_stories,         { :rb_stories => :update }
    
    # Task permissions
    # :show_tasks and :list_tasks are implicit in :view_sprints
    permission :create_tasks,           { :rb_tasks => [:new, :create]  }
    permission :update_tasks,           { :rb_tasks => [:edit, :update] }
    
    # Impediment permissions
    # :show_impediments and :list_impediments are implicit in :view_sprints
    permission :create_impediments,     { :rb_impediments => [:new, :create]  }
    permission :update_impediments,     { :rb_impediments => [:edit, :update] }

    permission :subscribe_to_calendars,  { :rb_calendars  => :show }
    permission :view_scrum_statistics,   { :rb_statistics => :show }
  end

  #menu :project_menu, :new_issue, { :controller => 'issues', :action => 'new', :issue => {:description => "h3. Rationale & Intent\n\nDescribe the business problem you are trying to solve and the feature you are suggesting to solve it.\n\nh3. Acceptance Criteria\n\n# It should do stuff"} }, :caption => :label_issue_new, :param => :project_id
  menu :project_menu, :backlogs, { :controller => :rb_master_backlogs, :action => :show }, :caption => :label_backlogs, :after => :issues, :param => :project_id
  menu :application_menu, :backlogs, { :controller => :rb_statistics, :action => :show}, :caption => :label_scrum_statistics
end
