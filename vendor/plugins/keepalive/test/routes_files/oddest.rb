# Stuff
ActionController::Routing::Routes.draw   do   |map|      #Blah
  
  # Another comment
  
  
  map.lms_launch  '/lms/:lms_name', :controller => 'classic_application_launching', :action => 'launch'
  map.connect     '*path',          :controller => 'application',                   :action => 'routes_catchall'
end