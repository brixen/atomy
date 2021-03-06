module Atomy
  module AST
    class InstanceVariable < Node
      attributes :identifier

      def name
        :"@#{@identifier}"
      end

      def bytecode(g, mod)
        pos(g)
        g.push_ivar name
      end
    end
  end
end
