class Frog

  def self.shifr block, key
    key_bytes = key.bytes.to_a
    block_bytes = block.bytes.to_a
    result = block_bytes.dup
    (0..7).each do |i|
      current_key = key_bytes[i * 288, 288]
      x = current_key[0,16]
      s = current_key[16,256]
      b = current_key[272,16]
      (0..15).each do |index|
#        result[index] ^= x[index]
#        result[index] = s[result[index]]
#        if index<15
#          result[index+1] ^= result[index]
#        else
#          result[0] ^= result[index]
#        end
#        k = b[index]
#        result[k] ^= result[index]
      end
    end
    result
  end

  def self.deshifr block, key
    key_bytes = key.bytes.to_a
    block_bytes = block.bytes.to_a
    result = block_bytes.dup
    7.downto(0).each do |i|
      current_key = key_bytes[i * 288, 288]
      x = current_key[0,16]
      s = current_key[16,256]
      b = current_key[272,16]
      15.downto(0).each do |index|
#        k = b[index]
#        result[k] ^= result[index]
#        if index<15
#          result[index+1] ^= result[index]
#        else
#          result[0] ^= result[index]
#        end
#        result[index] = s[result[index]]
#        result[index] ^= x[index]
      end
    end
    result
  end
end

class ExtendedKey
  @random_table = [
  113, 21,232, 18,113, 92, 63,157,124,193,166,197,126, 56,229,229,
  156,162, 54, 17,230, 89,189, 87,169,  0, 81,204,  8, 70,203,225,
  160, 59,167,189,100,157, 84, 11,  7,130, 29, 51, 32, 45,135,237,
  139, 33, 17,221, 24, 50, 89, 74, 21,205,191,242, 84, 53,  3,230,
  231,118, 15, 15,107,  4, 21, 34,  3,156, 57, 66, 93,255,191,  3,
  85,135,205,200,185,204, 52, 37, 35, 24, 68,185,201, 10,224,234,
    7,120,201,115,216,103, 57,255, 93,110, 42,249, 68, 14, 29, 55,
  128, 84, 37,152,221,137, 39, 11,252, 50,144, 35,178,190, 43,162,
  103,249,109,  8,235, 33,158,111,252,205,169, 54, 10, 20,221,201,
  178,224, 89,184,182, 65,201, 10, 60,  6,191,174, 79, 98, 26,160,
  252, 51, 63, 79,  6,102,123,173, 49,  3,110,233, 90,158,228,210,
  209,237, 30, 95, 28,179,204,220, 72,163, 77,166,192, 98,165, 25,
  145,162, 91,212, 41,230,110,  6,107,187,127, 38, 82, 98, 30, 67,
  225, 80,208,134, 60,250,153, 87,148, 60, 66,165, 72, 29,165, 82,
  211,207,  0,177,206, 13,  6, 14, 92,248, 60,201,132, 95, 35,215,
  118,177,121,180, 27, 83,131, 26, 39, 46, 12
]
  def self.extendKey key, decrypting = false
    key = key.bytes.to_a
    k = (key * (2304/key.size + 1))[0,2304]
    r = (@random_table * (2304/@random_table.size + 1))[0,2304]
    w = []
    (0..2303).each do |index|
      w[index] = k[index] ^ r[index]
    end
    p = self.make_internal_key(w, decrypting)
    buffer = key.dup
    buffer[0] += key.size
    result = []
    while result.size < 2304
    buffer = Frog.shifr buffer.pack("c*"), p.pack("c*")
    result += buffer
    end
    result = result[0, 2304]
    (self.make_internal_key result, decrypting).pack("c*")
  end

  def self.make_internal_key array, decrypting
    result = []
    (0..7).each do |index|
      xorBu = array[index * 288, 16]
      substPermu = make_permutation array[index * 288 + 16, 256]
      substPermu = self.invert_permutation(substPermu) if decrypting
      bombPermu = make_permutation array[index * 288 + 272, 16]
      validate bombPermu
      result += xorBu + substPermu + bombPermu
    end
    result
  end

  def self.make_permutation array
    use = (0..array.size-1).to_a
    index = 0
    result = []
    (0..array.size-1).each do |i|
      index = (index + array[i]) % use.size
      result[i] = use.delete_at index
    end
    result
  end

  def self.invert_permutation array
    invert = []
    (0..array.size-1).each do |i|
      invert[array[i]] = i
    end
    invert
  end

  def self.validate bombPermu
    used = [false] * bombPermu.size
    index = 0
    (0..bombPermu.size - 2).each do |i|
      if bombPermu[index] == 0
        k = used.index false
        bombPermu[index] = k
        l = k
        while bombPermu[l] != k
          l = bombPermu[l]
        end
        bombPermu[l] = 0
      end

      used[index] = true
      index = bombPermu[index]
    end

    bombPermu.each_with_index do |b,i|
      if b == (i+1)%bombPermu.size
        bombPermu[i] = (i+2) % bombPermu.size
      end
    end
  end

end

key_s = ExtendedKey.extendKey("a"*16)
key_d = ExtendedKey.extendKey("a"*16)
Frog.shifr("test"*4, key_s).pack("c*")
#p Frog.deshifr(Frog.shifr("test"*4, key_s).pack("c*"), key_d).pack("c*")

