path = File.join(Rails.root, 'config', 'lcdb.yml')
sample_path = File.join(Rails.root, 'config', 'lcdb.yml.sample')

if File.exist?(path) && File.readable?(path)
        LCDBConfig = YAML.load(ERB.new(File.read(path)).result)[Rails.env]
elsif File.exist?(sample_path) && File.readable?(sample_path)
        LCDBConfig = YAML.load(ERB.new(File.read(sample_path)).result)[Rails.env]
else
        raise "Missing config/lcdb.yml or config/lcdb.yml.sample"
end

