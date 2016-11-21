# Collection of utility methods to hashify and merge structures
module Evil::Struct::Utils
  extend self

  # Converts value to nested hash
  #
  # Makes conversion through nested hashes, arrays, enumerables,
  # and other objects that respond to `to_a`, `to_h`, `to_hash`, or `each`.
  # Doesn't convert `nil` (even though it responds to `to_h` and `to_a`).
  #
  # @param  [Object] value
  # @return [Hash]
  #
  def hashify(value)
    hash = to_h(value)
    list = to_a(value)

    if hash
      hash.each_with_object({}) { |(key, val), obj| obj[key] = hashify(val) }
    elsif list
      list.map { |item| hashify(item) }
    else
      value
    end
  end

  # Shallowly merges target object to the source hash
  #
  # The target object can be hash, or respond to either `to_h`, or `to_hash`.
  # Before a merge, the keys of the target object are symbolized.
  #
  # @param  [Hash<Symbol, Object>]  source
  # @param  [Hash, #to_h, #to_hash] target
  # @return [Hash<Symbol, Object>]
  #
  def merge(source, target)
    source.merge(to_h(target))
  end

  # Deeply merges target object to the source one
  #
  # The nesting stops when a first non-hashified value reached.
  # It do not merge arrays of hashes!
  #
  # @param  [Object] source
  # @param  [Object] target
  # @return [Object]
  #
  def merge_deeply(source, target)
    source_hash = to_h(source)
    target_hash = to_h(target)
    return target unless source_hash && target_hash

    keys = (source_hash.keys | target_hash.keys)
    keys.each_with_object(source_hash) do |key, obj|
      next unless target_hash.key? key
      obj[key] = merge_deeply source_hash[key], target_hash[key]
    end
  end

  private

  def to_h(value)
    to_hash(value)&.each_with_object({}) do |(key, val), obj|
      obj[key.to_sym] = val
    end
  end

  def to_hash(value)
    if    value.is_a? Hash           then value
    elsif value.is_a? Array          then nil
    elsif value.nil?                 then nil
    elsif value.respond_to? :to_h    then value.to_h
    elsif value.respond_to? :to_hash then value.to_hash
    end
  end

  def to_a(value)
    if    value.is_a? Array       then value
    elsif value.is_a? Hash        then nil
    elsif value.nil?              then nil
    elsif value.respond_to? :to_a then value.to_a
    end
  end
end
