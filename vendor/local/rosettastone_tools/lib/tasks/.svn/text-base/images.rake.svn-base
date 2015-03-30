namespace :images do
  desc 'Run advpng, optipng, then pngcrush on PNG files in public/images.  Specify file_pattern=some_regex to operate on a subset of files.'
  task :run_all_optimizers => [:pngcrush, :advpng, :optipng]

  task :check_for_pngcrush_command do
    raise "'pngcrush' command not found in path.  On a Mac, try 'sudo port install pngcrush'" if `which pngcrush`.match(/no pngcrush/)
  end

  desc 'Use pngcrush command to losslessly reduce the file size of PNG files in public/images.  Specify file_pattern=some_regex to operate on a subset of files.'
  task :pngcrush => [:environment, :check_for_pngcrush_command] do
    tmpdir = File.join(Rails.root, 'tmp')
    pngs = Dir.glob(File.join(Rails.root, 'public', 'images', '**', '*.png'))

    if ENV['file_pattern'] # only do ones matching a certain file name
      pngs = pngs.select {|png| png =~ Regexp.new(ENV['file_pattern'])} 
    end

    pngs.each do |png|
      file_name = File.basename(png)
      new_file_path = File.join(tmpdir, file_name)
      output = `pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB -brute -d "#{tmpdir}" "#{png}"`
      raise "#{output}\nError processing #{png}!" if !File.file?(new_file_path)

      orig_size = File.size(png)
      new_size = File.size(new_file_path)
      if new_size < orig_size
        puts "Crushed #{orig_size - new_size} bytes (#{((orig_size - new_size) * 100.0 / orig_size).to_s[0..4]}%) from #{png} (now #{new_size} bytes)"
        FileUtils.cp(new_file_path, png)
      else
        puts "No improvement for #{png}"
      end
      File.unlink(new_file_path)
    end
  end

  task :check_for_optipng_command do
    raise "'optipng' command not found in path.  On a Mac, try 'sudo port install optipng'" if `which optipng`.match(/no optipng/)
  end

  desc 'Use optipng command to losslessly reduce the file size of PNG files in public/images.  Specify file_pattern=some_regex to operate on a subset of files.'
  task :optipng => [:environment, :check_for_optipng_command] do
    tmpdir = File.join(Rails.root, 'tmp')
    pngs = Dir.glob(File.join(Rails.root, 'public', 'images', '**', '*.png'))

    if ENV['file_pattern'] # only do ones matching a certain file name
      pngs = pngs.select {|png| png =~ Regexp.new(ENV['file_pattern'])} 
    end

    pngs.each do |png|
      file_name = File.basename(png)
      new_file_path = File.join(tmpdir, file_name)
      output = `optipng -o5 -dir "#{tmpdir}" "#{png}"`
      raise "#{output}\nError processing #{png}!" if !File.file?(new_file_path)

      orig_size = File.size(png)
      new_size = File.size(new_file_path)
      if new_size < orig_size
        puts "Optimized #{orig_size - new_size} bytes (#{((orig_size - new_size) * 100.0 / orig_size).to_s[0..4]}%) from #{png} (now #{new_size} bytes)"
        FileUtils.cp(new_file_path, png)
      else
        puts "No improvement for #{png}"
      end
      File.unlink(new_file_path)
    end
  end

  task :check_for_advpng_command do
    raise "'advpng' command not found in path.  On a Mac, try 'sudo port install advancecomp'" if `which advpng`.match(/no advpng/)
  end

  desc 'Use advpng command to losslessly reduce the file size of PNG files in public/images.  Specify file_pattern=some_regex to operate on a subset of files.'
  task :advpng => [:environment, :check_for_advpng_command] do
    pngs = Dir.glob(File.join(Rails.root, 'public', 'images', '**', '*.png'))

    if ENV['file_pattern'] # only do ones matching a certain file name
      pngs = pngs.select {|png| png =~ Regexp.new(ENV['file_pattern'])} 
    end

    pngs.each do |png|
      file_name = File.basename(png)
      orig_size = File.size(png)

      output = `advpng -z -4 "#{png}"`

      new_size = File.size(png)
      if new_size < orig_size
        puts "Advanced #{orig_size - new_size} bytes (#{((orig_size - new_size) * 100.0 / orig_size).to_s[0..4]}%) from #{png} (now #{new_size} bytes)"
      else
        puts "No improvement for #{png}"
      end
    end
  end
end
