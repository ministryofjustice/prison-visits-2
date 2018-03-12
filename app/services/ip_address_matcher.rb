require 'netaddr'

class IpAddressMatcher
  def initialize(terms)
    @cidrs = cidrs(terms)
  end

  def include?(addr)
    @cidrs.any? do |cidr|
      begin
        cidr.matches?(addr)
      rescue NetAddr::ValidationError
        false
      end
    end
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
