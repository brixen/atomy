def wildcard
  Atomy::Patterns::Any.new
end

describe(Module) do
  describe(:atomy_methods) do
    it("contains a hash of Atomy-defined methods") do
      mod = Atomy::Module.new

      x = Module.new

      x.atomy_methods.keys.must_equal []

      Atomy.dynamic_branch(
        x,
        :foo,
        Atomy::Branch.new(mod, wildcard) { 42 })

      x.atomy_methods[:foo].must_be_kind_of Atomy::Method
      x.atomy_methods[:foo].size.must_equal 1

      Atomy.dynamic_branch(
        x,
        :bar,
        Atomy::Branch.new(mod, wildcard) { 41 })

      x.atomy_methods[:foo].must_be_kind_of Atomy::Method
      x.atomy_methods[:foo].size.must_equal 1

      x.atomy_methods[:bar].must_be_kind_of Atomy::Method
      x.atomy_methods[:bar].size.must_equal 1
    end
  end
end

describe(Atomy::Branch) do
  describe(:total_args) do
    it("is the amount of required or default arguments") do
      mod = Atomy::Module.new

      Atomy::Branch.new(mod, wildcard).total_args.must_equal 0

      Atomy::Branch.new(
        mod,
        wildcard,
        [wildcard]).total_args.must_equal 1

      Atomy::Branch.new(
        mod,
        wildcard,
        [wildcard],
        [wildcard, wildcard]).total_args.must_equal 3
    end

    it("does not reflect splatiness") do
      mod = Atomy::Module.new

      Atomy::Branch.new(
        mod,
        wildcard,
        [wildcard],
        [wildcard, wildcard],
        wildcard).total_args.must_equal 3
    end
  end

  describe(:<=>) do
    it("prioritizes a method with more arguments over another") do
      mod = Atomy::Module.new
      a = Atomy::Branch.new(mod, wildcard, [wildcard], [wildcard])
      b = Atomy::Branch.new(mod, wildcard, [wildcard])
      (a <=> b).must_equal 1
      (b <=> a).must_equal -1
    end
  end
end

describe(Atomy) do
  describe(:define_branch) do
    it("adds a method branch to the target module") do
      mod = Atomy::Module.new

      x = Class.new

      Atomy.dynamic_branch(x, :foo, Atomy::Branch.new(mod, wildcard) { 42 })

      x.atomy_methods[:foo].wont_be_nil
      x.atomy_methods[:foo].size.must_equal 1
      x.new.foo.must_equal 42
    end

    it("replaces branches with equivalent patterns") do
      mod = Atomy::Module.new

      x = Class.new

      Atomy.dynamic_branch(x, :foo, Atomy::Branch.new(mod, wildcard) { 42 })

      Atomy.dynamic_branch(x, :foo, Atomy::Branch.new(mod, wildcard) { 43 })

      x.atomy_methods[:foo].must_be_kind_of Atomy::Method
      x.atomy_methods[:foo].size.must_equal 1

      x.new.foo.must_equal 43
    end
  end
end

