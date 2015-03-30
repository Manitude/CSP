# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.
#
# configuration management tasks
#
# examples:
#   ./rake cm:tag message='tagging trunk to default tags directory'
#   ./rake cm:tag tags_dir=tags_cd message='tagging trunk to tags_cd/'
#   ./rake cm:tag tags_dir=OnlineReleases tag_name="WickedTagName" message='New wicked name'
#   ./rake cm:tag branch=sprint49 message='creating branch for sprint 49'
#   ./rake cm:tag revision=12000 message='creating tag based on revision 12000 of trunk'
#   ./rake cm:tag branches_dir=Branches branch=TheNewBranch message='This is a new branch'
#   ./rake cm:merge revisions=3,4 work_item=2323 # yields commit message: "work item 2323. merging the following revisions from trunk to branches/yourmostrecentlytouchedbranch: 3,4" 
require 'tmpdir'

module RosettaStone
  class CmHelper
    class << self
      def output_and_execute_command(command)
        say_with_time "executing #{command}" do
          `#{command}`
        end
      end

      # note that this is dangerous. it will find the most recently touched branch, so if you use branches for things other than cm, you may want to pass branch=sprint23 to cm:merge 
      def get_most_recently_updated_branch(branches_path)
        puts "getting most recently updated branch under #{branches_path}..."
        command = %Q[svn info -R --depth immediates #{branches_path} / | grep -E "Path|Last Changed Date"]
        puts "running command: #{command}"
        svn_info = `#{command}`
        puts "command complete"
        lines = svn_info.split("\n")
        last_updates = process_path_lines(lines, {})
        last_updates.sort_by { |branch, date_string| Time.parse(date_string) }.last.first # take the last element in the array (the newest), and the first element of that array is the branch name
      end

      # lines like this: Path: rails_xss_upgrade
      def process_path_lines(lines, last_updates)
        line = lines.shift
        if line
          if line.include?('Path: ') && !line.blank? && !line.include?('branches') # the branches path is the parent path, not an actual branch
            path = line.sub(/Path: /, '') 
            process_date_line(lines, path, last_updates)
          else
            process_path_lines(lines, last_updates)
          end
        else
          last_updates # break out of recursion
        end
      end

      # lines like this: Last Changed Date: 2011-10-31 12:13:34 -0400 (Mon, 31 Oct 2011)
      def process_date_line(lines, path, last_updates)
        line = lines.shift
        date = line.sub(/Date: /, '').sub(/ \(.*/, '')
        last_updates[path] = date
        process_path_lines(lines, last_updates)
      end
    end
  end
end
# finds where the externals could be possibly set.  Returns an array of the
# possible directories
def svn_external_locations
  svn_status = `svn st --ignore-externals`
  #Parse that result, looking for all the external directories.
  #Then get a list of the parent directories of all the externals
  parent_directories = svn_status.split(/\n/).grep(/^X/).collect{|line| Pathname.new(line.gsub(/^X\W*(.*)/,'\1')).parent}.uniq

  #Now, take those, and add any entries for ancestors
  #(Externals can be set at any point in the directory hierarchy)
  external_locations = []
  parent_directories.each do |dir|
    path = Pathname.new(dir)
    while (!['.','..'].include?(path.to_s)) do
      external_locations << path.to_s
      path = path.parent
    end
  end
  #Don't forget about the parent dir
  external_locations << '.'
  external_locations.uniq!
  external_locations
end

def pin_externals(path='.')
  svn_external_locations.map {|ext_path| File.join(path, ext_path)}.each do |ext_dir|
    next unless File.directory?(ext_dir)
    svn_externals = `svn propget svn:externals #{ext_dir}`
    next if svn_externals.chomp!.nil?
    new_externals = []
    svn_externals.chomp!.split(/\n/).each do |external|
      pieces = external.split

      if (external =~ /^\s*#/) || (pieces.size != 2)
        # we get into this branch if the line was any of:
        #  * a comment
        #  * an empty line
        #  * a line with more than 2 parts, such as an already-pinned external
        #  * or even other jank we don't understand...
        # so, in this case, just copy it across as is!
        new_external = external.chomp
      else
        # we have a "regular" 2-part external.  pin it!
        dir, url = pieces.first, pieces.last

        svn_info = `svn info #{File.join(ext_dir, dir)}`
        external_revision = svn_info.split(/\n/).detect {|line| line =~ /^Revision: /}.gsub!(/^Revision: /, '')

        new_external = "#{dir} -r#{external_revision} #{url}"
      end
      new_externals << new_external
    end
    say_with_time "Setting new externals for #{ext_dir}" do
      `svn propset svn:externals "#{new_externals.join("\n")}" #{ext_dir}`
    end
  end
end

namespace :cm do

  desc "Pins all the externals that exist in the current directory"
  task :pin_externals => :environment do
    include SayWithTime
    pin_externals
  end

  desc "Tag this project with the next available tag number and pin all externals to their current revision"
  task :tag => :environment do
    include SayWithTime

    raise "must specify a commit message with message=''" unless ENV['message']

    puts ENV['PATH']
    svn_info = `svn info`
    raise RuntimeError.new(svn_info) if $? != 0 
    project_url = svn_info.split(/\n/).detect {|line| line =~ /^URL: /}.gsub(/^URL: /, '').chomp
    repository_root = svn_info.split(/\n/).detect {|line| line =~ /^Repository Root: /}.gsub(/^Repository Root: /, '').chomp
    project_location = project_url.gsub(repository_root, '')
    project_name = project_location.gsub(/\/[^\/]+$/, '')[1..-1] # Peel off leading '/' and trailing /trunk, etc.

    #  We need to figure out where we're copying to...  The tags or branches directory.
    if ENV['branch']
      copy_to_path = ENV['branches_dir'] || 'branches'
    else
      copy_to_path = ENV['tags_dir'] || 'tags'
    end
    if ENV['include_project_name'] == 'false'
      copy_to_path = "#{repository_root}/#{copy_to_path}"
    else
      copy_to_path = "#{repository_root}/#{project_name}/#{copy_to_path}"
    end

    #  Figure out what we're naming our copy
    if ENV['branch']
      copy_name = ENV['branch']
    else
      existing_tags = `svn ls #{copy_to_path}`
      if existing_tags.split.length == 0
        next_version = 0
      else
        next_version = existing_tags.split.last.chop.split('-').last.to_i + 1
      end
      tag_date = ENV['date'] || Date.today.strftime("%Y%m%d")
      copy_name = ENV['tag_name'] || "#{tag_date}-#{next_version}"
    end

    # supplying a revision argument to ./rake cm:tag will create the tag from
    # the working copy at a certain revision, but will not affect the pinning
    # of externals
    revision = ENV['revision'] ? "-r#{ENV['revision']}" : ""
    svn_copy_tag_command = "svn cp #{revision} #{project_url} #{copy_to_path}/#{copy_name} -m '#{ENV['message']}'"
    say_with_time "executing #{svn_copy_tag_command}" do
      `#{svn_copy_tag_command}`
    end

    puts "checking out new tag"
    new_checkout_path = File.join(Dir.tmpdir, "#{project_name}-#{copy_name}")
    svn_check_out_tag_command = "svn co #{copy_to_path}/#{copy_name} #{new_checkout_path}"
    say_with_time "executing #{svn_check_out_tag_command}" do 
      `#{svn_check_out_tag_command}`
    end

    pin_externals(new_checkout_path)

    svn_check_in_command = "svn ci #{new_checkout_path} -m 'pinning externals to current revision'"
    say_with_time "executing #{svn_check_in_command}" do
      `#{svn_check_in_command}`
    end
  end

  desc "merge changes in trunk into a branch"
  task :merge => :environment do
    include SayWithTime

    svn_info = `svn info`
    project_url = svn_info.split(/\n/).detect {|line| line =~ /^URL: /}.gsub(/^URL: /, '').chomp
    repository_root = svn_info.split(/\n/).detect {|line| line =~ /^Repository Root: /}.gsub(/^Repository Root: /, '').chomp
    project_location = project_url.gsub(repository_root, '')
    project_name = project_location.gsub(/\/[^\/]+$/, '')[1..-1] # Peel off leading '/' and trailing /trunk, etc.

    work_item_prefix = ENV['work_item'] ? "work item #{ENV['work_item']}. " : ""

    revisions = ENV['revisions'].me {|revs| raise "must specify ENV['revisions'] (comma-delimited revisions from trunk to merge into branch)" unless revs; revs.split(',') }

    full_project_path = "#{repository_root}/#{project_name}"
    branches_path = "#{full_project_path}/branches"

    if ENV['branch']
      branch_name = ENV['branch']
    else
      branch_name = RosettaStone::CmHelper.get_most_recently_updated_branch(branches_path)
    end

    new_checkout_path = File.join(Dir.tmpdir, "#{project_name}-#{branch_name}")

    `rm -rf #{new_checkout_path}` # clean  this up, in case it already exists

    svn_check_out_command = "svn co #{branches_path}/#{branch_name} #{new_checkout_path}"
    RosettaStone::CmHelper.output_and_execute_command(svn_check_out_command)

    Dir.chdir(new_checkout_path) do
      `svn info`
      revisions.each do |revision|
        merge_command = "svn merge -c #{revision} #{full_project_path}/trunk ."
        RosettaStone::CmHelper.output_and_execute_command(merge_command)
      end
    end

    svn_check_in_command = "svn ci #{new_checkout_path} -m '#{work_item_prefix}merging the following revisions from trunk to branches/#{branch_name}: #{ENV['revisions']}'"
    RosettaStone::CmHelper.output_and_execute_command(svn_check_in_command)
  end

end # namespace :cm
