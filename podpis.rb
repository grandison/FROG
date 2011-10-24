require './my_hash.rb'
class Podpis
  @p = 192737
  @g = 317
  @x = 19
  @y = (@g ** @x) % @p
  def self.podpis text
    k = 2 + rand(@p-1)
    h = MyHash.hash(text)
    r = self.pow(@g,k,@p)
    s = (@p*h*k - 1)*(@p*@x)**(-1)
    return {:r => r, :s => s}
  end

  def self.check result, text
    h = MyHash.hash(text)
    r = result[:r]
    s = result[:s]
    r ** (@p*h) ==  @g * @y ** (@p * s)
  end

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
end
res = Podpis.podpis "12"*1000
res
p Podpis.check res, "12"*10000

