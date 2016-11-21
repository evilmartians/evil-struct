require "dry-initializer"

# Nested structure with type constraints, based on the `dry-initializer` DSL
class Evil::Struct
  extend Dry::Initializer::Mixin

  require_relative "struct/attributes"
  require_relative "struct/utils"

  class << self
    # Builds a struct from value that respond to `to_h` or `to_hash`
    #
    # @param  [#to_h, #to_hash] value (nil)
    # @return [Evil::Struct]
    #
    # @alias :call
    # @alias :[]
    # @alias :load
    #
    def new(value = {})
      value if value.instance_of? self.class

      hash = value           if value.is_a? Hash
      hash ||= value.to_h    if value.respond_to? :to_h
      hash ||= value.to_hash if value.respond_to? :to_hash

      hash_with_symbolic_keys = hash.each_with_object({}) do |(key, val), obj|
        obj[key.to_sym] = val
      end
      super hash_with_symbolic_keys
    end
    alias_method :call, :new
    alias_method :[],   :new
    alias_method :load, :new

    # @!method attributes(options)
    # Shares options between definitions made inside the block
    #
    # @example
    #   attributes optional: true do
    #     attribute :foo
    #     attribute :bar
    #   end
    #
    # @option options (see #attribute)
    # @return [self] itself
    #
    def attributes(**options, &block)
      Attributes.call(self, options, &block)
      self
    end

    # Returns the list of defined attributes
    #
    # @return [Array<Symbol>]
    #
    def list_of_attributes
      @list_of_attributes ||= []
    end

    # @!method attribute(name, type = nil, options)
    # Declares the attribute
    #
    # @param  [#to_sym] name       The name of the key
    # @param  [#call]   type (nil) The type constraint
    # @option options [#call]   :type     Type constraint (alternative syntax)
    # @option options [#to_sym] :as       The name of the attribute
    # @option options [Proc]    :default  Block returning a default value
    # @option options [Boolean] :optional (nil) Whether key is optional
    # @return [self]
    #
    # @alias :option
    # @alias :param
    #
    def option(name, type = nil, as: nil, **opts)
      super.tap { list_of_attributes << (as || name).to_sym }
      self
    end
    alias_method :attribute, :option
    alias_method :param,     :option

    private

    def inherited(klass)
      super
      klass.instance_variable_set :@list_of_attributes, list_of_attributes.dup
    end
  end

  # Checks an equality to other object that respond to `to_h` or `to_hash`
  #
  # @param  [Object] other
  # @return [Boolean]
  #
  def ==(other)
    if other&.respond_to?(:to_h)
      to_h == other.to_h
    elsif other.respond_to?(:to_hash)
      to_h == other.to_hash
    else
      false
    end
  end

  # Converts nested structure to hash
  #
  # Makes conversion through nested hashes, arrays, enumerables, as well
  # as trhough values that respond to `to_a`, `to_h`, and `to_hash`.
  # Doesn't convert `nil`.
  #
  # @return [Hash]
  #
  # @alias :to_hash
  # @alias :dump
  #
  def to_h
    self.class.list_of_attributes.each_with_object({}) do |key, hash|
      val = send(key)
      hash[key] = Utils.hashify(val) unless val == Dry::Initializer::UNDEFINED
    end
  end
  alias_method :to_hash, :to_h
  alias_method :dump,    :to_h

  # @!method [](key)
  # Gets the attribute value by name
  #
  # @example
  #   class User < Evil::Struct
  #     attribute :name
  #   end
  #
  #   joe = User.new(name: "Joe")
  #   joe.name    # => "Joe"
  #   joe[:name]  # => "Joe"
  #   joe["name"] # => "Joe"
  #
  # @param  [Symbol, String] key The name of the attribute
  # @return [Object] A value of the attribute
  #
  alias_method :[], :send

  # Shallowly merges other object to the current struct
  #
  # @example
  #   class User < Evil::Struct
  #     attribute :name
  #     attribute :age
  #   end
  #   joe_at_3 = User.new(name: "Joe", age: 3)
  #
  #   joe_at_4 = joe_at_3.merge(age: 4)
  #   joe_at_4.name # => "Joe"
  #   joe_at_4.age  # => 4
  #
  # @param  [Hash, #to_h, #to_hash] other
  # @return [self.class] new instance of the current class
  #
  def merge(other)
    self.class[Utils.merge(to_h, other)]
  end

  # Deeply merges other object to the current struct
  #
  # It iterates through hashes and objects responding to `to_h` and `to_hash`.
  # The iteration stops when any non-hash value reached.
  #
  # @example
  #   class User < Evil::Struct
  #     attribute :info
  #     attribute :meta
  #   end
  #   user = User.new info: { names: [{ first: "Joe", last: "Doe" }], age: 33 },
  #                   meta: { type:  :admin }
  #
  #   user.merge info: { names: [{ first: "John" }] }, meta: { "role" => :cto }
  #   user.to_h # => {
  #             #      info: { names: [{ first: "John" }], age: 33 },
  #             #      meta: { type: :admin, role: :cto }
  #             #    }
  #
  # @param  [Hash, #to_h, #to_hash] other
  # @return [self.class] new instance of the current class
  #
  # @alias :deep_merge
  #
  def merge_deeply(other)
    self.class[Utils.merge_deeply(self, other)]
  end
  alias_method :deep_merge, :merge_deeply
end
