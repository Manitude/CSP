#Rather than figure out how to make this 'safe', allow it everywhere but production
unless RosettaStone::ProductionDetection.could_be_on_production?
  ActionController::Routing::Routes.draw do |map|
    map.lion_index 'lion', :controller => 'lion', :action => 'index'
    map.lion_export 'lion/export', :controller => 'lion', :action => 'export'
    map.lion_show 'lion/show/:key', :requirements => { :key => /.*/ }, :controller => 'lion', :action => 'show'
  end
end
