class SubSequence
  @@next_value=0
  def self.next
    @@next_value += 1
  end
end