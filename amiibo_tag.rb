require 'ruby-nfc'

class AmiiboTag < NFC::Tag
  attr_reader :uid, :target
  
  def initialize(target, reader)
    super(target, reader)
    @target = target
    set_uid
  end

  def print_details
    print_details_recursive(target, 0)
  end

  private

  def print_details_recursive(node, level)
    if node.class == FFI::StructLayout::CharArray
      str = '  ' * level + char_array_to_hex_str(node)
      puts str
    elsif node.respond_to?(:members)
      members = node.members
      members.each do |member|
        puts '  ' * level + member.to_s + ':'
        print_details_recursive(node[member], level + 1)
      end
    else
      puts '  ' * level + node.to_s
    end
  end

  def set_uid
    char_array = @target.values[0][:nai][:abtUid]
    @uid = char_array_to_hex_str(char_array)[0..13]
  end

  private

  def char_array_to_hex_str(char_array)
    str = ''
    char_array.size.times do |i|
      val_part = char_array[i]
      str_part = ''
      2.times do
        str_part = [
          '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
          'A', 'B', 'C', 'D', 'E', 'F'
        ][val_part % 16] + str_part
        val_part /= 16
      end
      str += str_part
    end
    str
  end
end
