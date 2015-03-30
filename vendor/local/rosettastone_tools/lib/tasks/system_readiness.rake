desc "Check system readiness for running this application"
task :system_readiness => :environment do
  SystemReadiness.verify_verbose
end

namespace :system_readiness do
  desc "Compiles native libraries for your architecture"
  task :fix do
    Dir.glob(File.join(Rails.root, 'vendor', 'gems', '*', 'compile_native_library.rb')).each do |file|
      Dir.chdir(File.dirname(file)) do
        system(file)
      end
    end
    # Some things won't be reloaded, so do this in a separate process
    system("./rake system_readiness")
  end
end
