require './my_hash.rb'
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
  @g = 1 + rand(@p-2)
  @x = 1 + rand(@q-2)
  @y = Pow.pow(@g,@x,@p)
  def self.podpis text
    k = 67
    h = MyHash.hash(text) % @p
    r = Pow.pow(@g,k,@p)
    po = r % @q
    s = (po * k - h * @x) % (@p-1)
    return {:r => r, :s => s}
  end

  def self.check result, text
    h = MyHash.hash(text) % @p
    r = result[:r]
    s = result[:s]
    po = r % @q
    p "first", Pow.pow(r,po,@p)
    p "second", (Pow.pow(@g, s, @p) * Pow.pow(@y, h ,@p)) % @p
  end
end
res = Podpis.podpis "10"
Podpis.check res, "10"
#p Pow.pow(-2,3,51)

