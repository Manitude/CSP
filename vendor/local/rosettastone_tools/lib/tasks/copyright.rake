

desc 'add copyright lines to the top of specified files'
task :copyrightize do
  puts "Must specify a comma-separated list of files with file=path/to/file.rb" unless ENV['file']
  files = ENV['file'].split(',')
  files.each do |file|
    Copyright.copyrightize!(file)
  end
end

module Copyright
  class << self
    def copyrightize!(file)
      if has_copyright?(file)
        puts "file already has copyright"
        return
      end
      puts "Adding copyright to #{file}"
      contents = copyright_text + File.read(file)
      File.open(file, 'w') {|f| f << contents}
    end

    def has_copyright?(file)
      File.read(file).match('Copyright::')
    end

    def copyright_text
      %Q[# Copyright:: Copyright (c) #{Time.now.year} Rosetta Stone
# License:: All rights reserved.

]
    end
  end
end