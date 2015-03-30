desc "Tell hoptoad we just deployed"
namespace :hoptoad do
  task :notify_of_deploy => :environment do
    begin
      HoptoadTasks
    rescue NameError => ee
      puts "HoptoadTasks not defined.  Is the hoptoad gem in your project?"
      next
    end 
  
    svn_info = `svn info #{Rails.root}`
    svn_info = Hash[*(svn_info.split("\n").map! {|m| m.split(": ", 2)}).flatten]
  
    res = HoptoadTasks.deploy(
      :rails_env => Rails.env,
      :scm_revision => svn_info['Revision'],
      :scm_repository => svn_info['URL'],
      :local_username => ENV['USER']
    )
  end
end
