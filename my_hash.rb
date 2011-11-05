require './frog.rb'
class MyHash
  def self.hash text
    h = ""
    result = ""
    (1..1).each do
      h = self.hash_help(h+text)
      result += h
    end
    number = 0
    rang = 1
    result.bytes.each do |b|
      number += number * rang + b
      rang = rang * 256
    end
    number
  end

  private
  def self.hash_help text
    text = text + "1" + "0" * (15 - text.size % 16) if text.size % 16 != 0
    h = ("0" * 16).bytes.to_a
    rounds = text.size / 16
    (1).upto(rounds) do |i|
      m = text[(i-1)*16, 16].bytes.to_a
      b = m.zip(h).map{|mas| mas[0] ^ mas[1]}
      key = ExtendedKey.extendKey m.pack("c*")
      h = Frog.shifr(b.pack("c*"), key).zip(h).map{|mas| mas[0] ^ mas[1]}
    end
    h.pack("c*")
  end
end
