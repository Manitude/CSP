path = File.join(Rails.root, 'config', 'eschool_error_codes.yml')
if File.exist?(path) && File.readable?(path)
        ERRORCodes = YAML.load(ERB.new(File.read(path)).result)
else
        raise "Missing config/eschool_error_codes.yml"
end
