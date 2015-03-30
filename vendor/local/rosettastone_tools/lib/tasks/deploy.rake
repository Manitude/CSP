namespace :deploy do
  # this is used by cap and is run after any cap deploy
  desc "will be run after every cap deploy (e.g. minify)"
  task :post

  desc "will be run after the rollout has completed (e.g. hoptoad:notify_of_deploy)"
  task :finish
    
  namespace :post do
    # This is used by the local_dev/Rakefile and capistano to run specific tasks that might be needed
    # after new code is deployed.
    # Cap will run this right after the new code is on the deploy box, but before that code has been copied out 
    # to the other servers
    # You can tweak what is in this task by changing the prereqs for this class.  For example:
    #
    # Rake::Task[:'deploy:post'].prerequisites.delete('db:migrate')
    # Rake::Task[:'deploy:post'].prerequisites << 'db:migrate:mongo'
    desc "will be run after automatic cap deploy (e.g. migrations)"
    task :auto => [:'db:migrate']
  end
end
