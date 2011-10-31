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
  @p = 51
  @q = 5
  @g = 5**((@p-1)/@q)%@p
  @x = 19
  @y = Pow.pow(@g,@x,@p)
  def self.podpis text
    k = 2 + rand(@p-1)
    h = MyHash.hash(text) % @p
    r = Pow.pow(@g,k,@p)
    po = r % @q
    s = ((po*h*k-1)*Pow.obr(po*@x, @p)) % @q
    return {:r => r, :s => s}
  end

  def self.check result, text
    h = MyHash.hash(text) % @p
    r = result[:r]
    s = result[:s]
    po = r % @q
    Pow.pow(r,po*h,@p) == (@g * Pow.pow(@y,r*po,@p))%@p
  end
end
res = Podpis.podpis "12"*1000
p Podpis.check res, "12"*1000

