# -*- encoding : utf-8 -*-

class SystemReadiness::TmpDirectoryWriteability < SystemReadiness::Base
  class << self
    def verify
      begin
        tmp_dir = File.join(Framework.root, 'tmp')
        tmp_file = File.join(tmp_dir, 'system_readiness_tmp_file_test')
        File.open(tmp_file, 'w') {|f| f << 'test'}
        File.read(tmp_file)
        File.unlink(tmp_file)
        return true, nil
      rescue Errno::ENOENT => exception
        return false, "tmp directory (#{tmp_dir}) does not seem to exist? #{exception}"
      rescue Errno::EACCES => exception
        return false, "tmp directory (#{tmp_dir}) permission problem? #{exception}"
      end
    end
  end
end
