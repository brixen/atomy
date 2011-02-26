module Atomo
  module Macro
    # hash from method names to something that can be #call'd
    @macros = {}

    module Environment
    end

    def self.register(name, args, body)
      name = (intern name).to_sym
      body = expand(body) # TODO: verify this

      if ms = @macros[name]
        ms << [[Patterns::Any.new, args], body.method(:bytecode)]
      else
        @macros[name] = [[[Patterns::Any.new, args], body.method(:bytecode)]]
      end

      Atomo.add_method(Environment.metaclass, name, @macros[name], true)
    end

    def self.expand?(node)
      case node
      when AST::BinarySend, AST::UnarySend, AST::KeywordSend
        true
      else
        false
      end
    end

    def self.intern(name)
      "atomo_macro::" + name
    end

    def self.no_macro(node)
      case node
      when AST::BinarySend
        AST::BinarySend.new(
          node.operator,
          expand(node.lhs),
          expand(node.rhs)
        )
      when AST::UnarySend
        AST::UnarySend.new(
          expand(node.receiver),
          node.method_name,
          node.arguments.collect { |a| expand(a) },
          node.block,
          node.private
        )
      when AST::KeywordSend
        AST::KeywordSend.new(
          expand(node.receiver),
          node.method_name,
          node.arguments.collect { |a| expand(a) }
        )
      else
        node
      end
    end

    # take a node and return its expansion
    def self.expand(root)
      root.recursively(proc { |x| expand? x }) do |node|
        begin
          case node
          when AST::BinarySend
            expand Environment.send(
              (intern node.operator).to_sym,
              nil,
              node.lhs,
              node.rhs
            )
          when AST::UnarySend
            expand Environment.send(
              (intern node.method_name).to_sym,
              node.block,
              node.receiver,
              *node.arguments
            )
          when AST::KeywordSend
            expand Environment.send(
              (intern node.method_name).to_sym,
              nil,
              node.receiver,
              *node.arguments
            )
          else
            node
          end
        rescue NoMethodError, ArgumentError
          no_macro(node)
        end
      end
    end

    def self.macro_pattern(n)
      n = n.recursively do |sub|
        case sub
        when Atomo::AST::Constant
          Atomo::AST::Constant.new(["Atomo", "AST"] + sub.chain)
        else
          sub
        end
      end

      case n
      when Atomo::AST::Primitive
        if n.value == :self
          Atomo::Patterns::Quote.new(Atomo::AST::Primitive.new(:self))
        else
          n
        end
      else
        Atomo::Patterns.from_node(n)
      end
    end
  end
end