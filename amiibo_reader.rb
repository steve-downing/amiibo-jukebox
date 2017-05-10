require 'ruby-nfc'
require 'sonos'
require './amiibo_tag.rb'

class AmiiboReader
  SPEAKER_NAME = 'Game Room'
  
  UID_MAP = {
    '049917F29A3D80' => 'Mario',
    '04A86A7ABF4880' => 'Olimar',
    '0409490A1F3E81' => 'Zelda',
    '0462942A704081' => 'Charizard',
    '04DD8792C64080' => 'Jigglypuff',
    '04779C92C23E81' => 'Bowser',
    '047E3862014980' => 'Mr. Game & Watch',
    '045A98AAA04081' => 'Palutena',
    '041790FAA04081' => 'Wario',
    '0489F832724080' => 'Ness',
    '046DA06A613E81' => 'Donkey Kong'
  }

  MUSIC_MAP = {
    'Mario' => 'http://66.90.93.122/ost/super-mario-64-soundtrack/vnfzvvacca/09-dire-dire-docks.mp3',
    'Zelda' => 'http://66.90.93.122/ost/zelda-twilight-princess/cyitksfmwt/07-twilight-princess-theme.mp3',
    'Olimar' => 'http://66.90.93.122/ost/pikmin-worlds-original-soundtrack/xqlscjobtm/07.-the-forest-of-hope.mp3',
    'Donkey Kong' => 'http://66.90.93.122/ost/donkey-kong-64-game-music/exphputupu/jungle-japes-jungle.mp3',
    'Ness' => 'http://66.90.93.122/ost/mother-vocal/obovrpommw/01-pollyanna-i-believe-in-you.mp3',
    'Wario' => 'http://66.90.93.122/ost/wario-ware-inc/fjobfuqpkp/005.-wario-s-badass-medley.mp3',
    'Palutena' => 'http://66.90.93.122/ost/kid-icarus-uprising-original-soundtrack/lzynmnvyke/1-02-chapter-1-the-return-of-palutena.mp3',
    'Mr. Game & Watch' => 'http://66.90.93.122/ost/super-smash-bros.-melee-original-sound-version/vqdpzpjmce/26-flat-zone.mp3',
    'Bowser' => 'http://66.90.93.122/ost/super-mario-64-soundtrack/iihwwgfjfr/32-ultimate-koopa.mp3',
    'Jigglypuff' => 'http://66.90.93.122/ost/totally-pokemon/fpueplrtcp/09.-song-of-jigglypuff.mp3',
    'Charizard' => 'http://66.90.93.122/ost/super-smash-bros.-melee-original-sound-version/cjwpcrndne/15-pokemon-stadium.mp3'
  }
  
  def initialize
    readers = NFC::Reader.all
    @reader = readers[0]
    @reader.connect
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
    speakers = Sonos::System.new.speakers
    speaker = speakers.select { |speaker| speaker.name == SPEAKER_NAME }.first

    character_name = UID_MAP[tag.uid]
    puts "#{tag.uid}:#{character_name}"
    # tag.print_details
    mp3_url = MUSIC_MAP[character_name]
    if mp3_url
      speaker.play(mp3_url)
      speaker.play
    else
      speaker.pause
    end
  end

end

if __FILE__ == $0
  reader = AmiiboReader.new
  reader.amiibo_loop
end
