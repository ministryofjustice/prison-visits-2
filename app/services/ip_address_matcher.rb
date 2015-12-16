require 'netaddr'

class IpAddressMatcher
  def initialize(terms)
    @cidrs = cidrs(terms)
  end

  def include?(addr)
    @cidrs.any? { |cidr| cidr.matches?(addr) }
  end

  alias_method :===, :include?

private

  def cidrs(terms)
    terms.split(/[,;]/).map { |s| cidr(s) }
  end

  def cidr(term)
    NetAddr::CIDR.create(term)
  end
end
