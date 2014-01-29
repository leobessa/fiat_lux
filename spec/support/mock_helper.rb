class Mock

  attr_reader :expectations

  def initialize(name)
    @name = name
    @expectations = []
  end

  def should_receive(method_name, opts={})
    @expectations.unshift(name: method_name.to_sym, args: opts.fetch(:with){[]}, return: opts.fetch(:return){nil})
  end

  def method_missing(name,*args)
    expectation = @expectations.shift
    case expectation
    when Hash
      if expectation[:name] == name && expectation[:args] == args
        return expectation.fetch(:return)
      else
        super
      end
    else
      super
    end
  end

end

module MockHelper
  def mock(name)
    Mock.new(name)
  end
end

class Bacon::Context
  include MockHelper
end
