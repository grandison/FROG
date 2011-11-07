require './my_hash.rb'
class Fixnum
  def to_byte_array
    num = self 
    result = [] 
    begin 
      result << (num & 0xff) 
      num >>= 8 
    end until result.size == self.size
    result.reverse 
  end 
end
class Bignum
  def to_byte_array
    num = self 
    result = [] 
    begin 
      result << (num & 0xff) 
      num >>= 8 
    end until result.size == self.size
    result.reverse 
  end  
end
class Pow
  def self.pow a,k,n
    b = 1
    while k >= 1
      if (k%2==0)
      k /= 2;
      a = (a * a) % n
      else
      k-=1
      b = (a*b)%n
      end
    end
    b
  end

  def self.obr a,n
    d,m,y,x = a,n,0,1
    r = m % d
    while r>0
      q =m / d
      z = (y+(n-((q*x)%n))) %n
      m,d = d,r
      y,x = x,z
      r = m % d
    end
    x
  end
end
class Podpis
  @p = 340282366920938463463374607431768211507
  @q = 12275703273579557140363
  @gamma = 2 + rand(@p-2)
  @g = Pow.pow(@gamma, (@p-1)/@q, @p)
  @x = 1 + rand(@q-2)
  @y = Pow.pow(@g,@x,@p)
  def self.podpis text
    k = 1 + rand(@q-1)
    h = MyHash.hash(text)
    r = Pow.pow(@g,k,@p)
    po = r % @q
    s = ((h*k-po) * Pow.obr(@x, @q)) % (@q)
    return {:r => r, :s => s}
  end

  def self.check result, text
    h = MyHash.hash(text)
    r = result[:r]
    s = result[:s]
    po = r % @q
    Pow.pow(r,h,@p) == (Pow.pow(@g, r, @p) * Pow.pow(@y, s ,@p)) % @p
  end
end

class Rejim
  @key = "keys"*4
  def self.read text
    text += "0"*(text.size%16)
    blocks_kol = text.size/16
    result = []
    g = "0"*16
    extendKey = ExtendedKey.extendKey @key
    1.upto(blocks_kol) do |i|
      g = Frog.shifr(g, extendKey)
      text[16*(i-1),16].bytes.to_a.each_with_index{|t,i| result<< (t^g[i])}
      g = g.pack("c*")
    end
    result.pack("c*")
  end
end

text = "test"*4
podpis = Podpis.podpis(text)
p_s = podpis[:s].to_byte_array.pack("c*")
p_s += " "*((16 - p_s.size)%16)
p_r = podpis[:r].to_byte_array.pack("c*")
p_r += " "*((16 - p_r.size)%16)
shifr_with_podpis = Rejim.read(text + p_s + p_r)
deshifr = Rejim.read(shifr_with_podpis)
r = deshifr.slice!(-16,16).rstrip.bytes.inject(0){|pr,n| pr*256+n}
s = deshifr.slice!(-16,16).rstrip.bytes.inject(0){|pr,n| pr*256+n}
p Podpis.check({:s => s, :r => r}, deshifr)
