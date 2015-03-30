class Ambient

  def self.init
    Thread.current[:lis_hash] = {}
  end

  def self.method_missing(name, *args)
    name_as_string= name.to_s
    if name_as_string.ends_with?("=")
      value= args.first
      set(name_as_string.chomp("=").to_sym, value)
    else
      get(name)
    end
  end

  def self.set(key, value)
    Thread.current[:lis_hash][key] = value
  end

  def self.get(key)
    Thread.current[:lis_hash][key]  if Thread.current[:lis_hash]
  end

end