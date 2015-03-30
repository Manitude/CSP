namespace :svn do
  desc "Run this to svn add ALL files in the current directory that are not under version control.  Be careful!"
  task :add_all_unversioned_files do
    system(%Q[svn st | grep "^\?" | awk '{print $2}' | sed -e "s/^/svn add /" | bash])
  end

  desc "look at common places for svn externals and show svn URLs that are not https"
  task :show_externals_not_using_https do
    externals_directories = %w(vendor vendor/gems)
    externals_directories << 'vendor/plugins' if File.exists?('vendor/plugins')
    system(%Q[svn propget svn:externals #{externals_directories.join(' ')} | grep '://' | grep -v https])
  end

  desc "Alphabetically sort the contents of the svn:externals property for the specified directory"
  task :sort_externals do
    directory = ENV['directory'] || ENV['dir']
    raise "Must specify a directory using directory=path/to/directory" unless directory
    system(%Q[svn propset svn:externals "`svn propget svn:externals '#{directory}' | sort | grep -v '^\W*$'`" "#{directory}"])
  end

  desc "Alphabetically sort the contents of the svn:ignore property for the specified directory"
  task :sort_ignores do
    directory = ENV['directory'] || ENV['dir']
    raise "Must specify a directory using directory=path/to/directory" unless directory
    system(%Q[svn propset svn:ignore "`svn propget svn:ignore '#{directory}' | sort | grep -v '^\W*$'`" "#{directory}"])
  end

  # some sample commands:
  # ./rake svn:remove_trailing_whitespace
  # ./rake svn:remove_trailing_whitespace file_pattern="*.yml" directories="config test/fixtures"
  # ./rake svn:remove_trailing_whitespace file_pattern="*.erb" directories="app/views"
  # ./rake svn:remove_trailing_whitespace file_pattern="*.css" directories="public/stylesheets"
  # ./rake svn:remove_trailing_whitespace file_pattern="*.js" directories="public/javascripts"
  desc "Remove trailing whitespace from files.  Optionally specify file_pattern='*.rb' and directories='app config db lib test'"
  task :remove_trailing_whitespace => :environment do
    file_pattern = ENV['file_pattern'] || "*.rb"
    directories = ENV['directories'] || 'app config db lib test'
    system(%Q(perl -pi -e "s/[^\\S\\n]+$//g" `find #{directories} -type f -name "#{file_pattern}" | fgrep -v .svn`))

    if Rake::Task.task_defined?('annotate_models')
      puts `#{RosettaStone::PlatformIndependentRake.rake_invocation} annotate_models`
    end
  end

  # some sample commands:
  # ./rake svn:tabs_to_spaces
  # ./rake svn:tabs_to_spaces file_pattern="*.yml" directories="config test/fixtures"
  # ./rake svn:tabs_to_spaces file_pattern="*.rb" directories="app config db lib test"
  # ./rake svn:tabs_to_spaces file_pattern="*.css" directories="public/stylesheets"
  # ./rake svn:tabs_to_spaces file_pattern="*.js" directories="public/javascripts"
  desc "Convert tab characters to two spaces.  Optionally specify file_pattern='*.erb' and directories='app/views vendor/plugins/*/app/views'"
  task :tabs_to_spaces do
    file_pattern = ENV['file_pattern'] || "*.erb"
    directories = ENV['directories'] || 'app/views vendor/plugins/*/app/views'
    system(%Q(perl -pi -e "s/\\t/  /g" `find #{directories} -type f -name "#{file_pattern}" | fgrep -v .svn`))
  end
end
