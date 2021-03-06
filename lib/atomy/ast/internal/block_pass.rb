module Atomy::AST
  class BlockPass < Node
    children :body

    def bytecode(g, mod)
      mod.compile(g, @body)
      nil_block = g.new_label
      g.dup
      g.is_nil
      g.git nil_block

      g.push_cpath_top
      g.find_const :Proc

      g.swap
      g.send :__from_block__, 1

      nil_block.set!
    end
  end
end
