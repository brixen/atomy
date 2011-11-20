module Atomy
  module AST
    class InstanceVariable < Node
      attributes :identifier
      generate

      def name
        :"@#{@identifier}"
      end

      def bytecode(g)
        pos(g)
        g.push_ivar name
      end
    end
  end
end
