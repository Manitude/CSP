class Hash

  def recursively_symbolize_keys
    this_hash = symbolize_keys
    this_hash.each do |key,val|
      this_hash[key] = val.recursively_symbolize_keys if val.respond_to?(:recursively_symbolize_keys)
    end
  end

end
