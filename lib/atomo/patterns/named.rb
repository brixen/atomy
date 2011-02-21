module Atomo::Patterns
  class Named < Pattern
    def initialize(n, p)
      @name = n
      @pattern = p
    end

    def target(g)
      @pattern.target(g)
    end

    def matches?(g)
      @pattern.matches?(g)
    end

    def match(g, matched = false, locals = {})
      if locals[@name]
        var = locals[@name]
      else
        var = g.state.scope.new_local @name
      end

      if not matched
        g.dup
        @pattern.match(g)
      end

      g.set_local var.slot
      g.pop
    end

    def local_names
      [@name]
    end
  end
end