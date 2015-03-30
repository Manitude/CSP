# -*- encoding : utf-8 -*-
class RosettaStone::SpeechLog
  attr_reader :xml
  
  def self.find_in_event(event_id, location)
    event_id = BSON::ObjectId(event_id) unless event_id.is_a?(BSON::ObjectId)
    doc = Eve::MongoMapper::Event.collection.find_one({'_id' => event_id}, {:fields => location})
    raise SpeechLogEventNotFound.new("No event found for `#{event_id}`") unless doc
    value = doc
    begin
      location.split('.').each do |key|
        value = value[key]
      end
    rescue NoMethodError => e; end
    raise SpeechLogNotFound.new("No speech log found at `#{location}` in event `#{event_id}`") unless value
    new(value)
  end

  def initialize(xml)
    @xml = xml
    @doc = XML::Parser.string(xml, :options => XML::Parser::Options::NOBLANKS).parse
  end

  def silent?
    hypothesis.attributes['class'] == "silence"
  end

  def verified?
    hypothesis.attributes['verified'] == "1"
  end

  def hypothesis
    @doc.find('/sound_log/hypotheses/hypothesis').first
  end

  #  Use speexdec to decode the audio
  def mp3_bytes
    converter = Kernel.open(build_conversion_command, "wb+")
    converter.write(Base64.decode64(@doc.find('/sound_log/data').first.inner_xml))
    converter.close_write
    bytes = converter.read
    converter.close_read
    return bytes
  end

  # returns base64 encoded speech data
  def speex_bytes
    @doc.find('/sound_log/data').first.inner_xml
  end

  def to_h
    @to_h ||= Hash.from_xml(@xml)['sound_log']
  end

  private
  def build_conversion_command
    #   For some reason version 3.97 needs the -x
    if lame_version =~ /3\.97/
      return "| #{find_speexdec} - - | #{find_lame} -r -x -s 16 -m m - -"
    else
      return "| #{find_speexdec} - - | #{find_lame} -r -s 16 -m m - -"
    end
  end

  private
  def lame_version
    `#{find_lame} --version | grep -E "version [0-9]*\.[0-9]*"`.split[3]
  end

  private
  def find_speexdec
    return '/usr/bin/speexdec' if File.exists?('/usr/bin/speexdec')
    return '/opt/local/bin/speexdec' if File.exists?('/opt/local/bin/speexdec')
    return '/usr/local/bin/speexdec' if File.exists?('/usr/local/bin/speexdec')

    raise "Can't find speexdec!  Checked /usr/bin, /opt/local/bin, and /usr/local/bin"
  end

  private
  def find_lame
    return '/usr/bin/lame' if File.exists?('/usr/bin/lame')
    return '/opt/local/bin/lame' if File.exists?('/opt/local/bin/lame')
    return '/usr/local/bin/lame' if File.exists?('/usr/local/bin/lame')

    raise "Can't find lame!  Checked /usr/bin, /opt/local/bin, and /usr/local/bin"
  end

  class SpeechLogEventNotFound < MongoMapper::DocumentNotFound; end
  class SpeechLogNotFound < RuntimeError; end
end
