# Handler for shared options
class Evil::Struct::Attributes
  # @private
  def self.call(*args, &block)
    new(*args).instance_eval(&block)
  end

  private

  def initialize(klass, **options)
    @klass   = klass
    @options = options
  end

  # Declares an attribute that shares options of the block
  # @param  (see Struct.attribute)
  # @option (see Struct.attribute)
  # @return (see Struct.attribute)
  def attribute(name, type = nil, **options)
    @klass.send :attribute, name, type, @options.merge(options)
  end
  alias_method :option, :attribute
  alias_method :param,  :attribute
end
