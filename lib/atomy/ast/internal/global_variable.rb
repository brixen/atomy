module Atomy
  module AST
    class GlobalVariable < Node
      attributes :identifier

      def name
        :"$#{@identifier}"
      end

      def bytecode(g, mod)
        pos(g)
        g.push_rubinius
        g.find_const :Globals
        g.push_literal name
        g.send :[], 1
      end
    end
  end
end
