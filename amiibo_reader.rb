require 'ruby-nfc'
require './amiibo_tag.rb'
require './sonos_player.rb'
require './hue_controller.rb'

class AmiiboReader
  def initialize
    readers = NFC::Reader.all
    @reader = readers[0]
    @reader.connect

    config = YAML.load_file('config.yml')
    @hue = HueController.new(config['hue'])
    @sonos = SonosPlayer.new(config['sonos'])
    @amiibo_map = config['amiibo']
  end

  def amiibo_loop
    @reader.poll(AmiiboTag) do |tag|
      begin
        process_tag(tag)
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end

  def get_next_tag
    ret = nil
    @reader.poll(AmiiboTag) do |tag|
      ret = tag
      break
    end
    ret
  end

  private

  def process_tag(tag)
    char_info = @amiibo_map[tag.uid]
    character_name = char_info['name']
    puts "#{tag.uid}:#{character_name}"
    unless char_info
      puts 'Char info not found'
      return
    end

    if @sonos
      mp3_url = char_info['track']
      if mp3_url
        @sonos.play_url(mp3_url)
      else
        @sonos.pause
      end
    end

    primary = char_info['primary']
    secondary = char_info['secondary']
    if primary && secondary && @hue
      @hue.set_colors(primary, secondary)
    end
  end

end

if __FILE__ == $0
  reader = AmiiboReader.new
  reader.amiibo_loop
end
