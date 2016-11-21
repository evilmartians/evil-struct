# Evil::Struct

Nested structure with type constraints, based on the [dry-initializer][dry-initializer] DSL.

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

[![Gem Version][gem-badger]][gem]
[![Build Status][travis-badger]][travis]
[![Dependency Status][gemnasium-badger]][gemnasium]
[![Inline docs][inch-badger]][inch]

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'evil-struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install evil-struct

## Synopsis

The structure is like [dry-struct][dry-struct] except for it controls optional attributes and default values aside of type constraints.

Its DSL is taken from [dry-initializer][dry-initializer]. Its method `attribute` is just an alias for `option`.

```ruby
require "evil-struct"
require "dry-types"

class Product < Evil::Struct
  attribute :title
  attribute :price,    Dry::Types["coercible.float"]
  attribute :quantity, Dry::Types["coercible.int"], default: proc { 0 }

  # shared options
  attributes optional: true do
    attribute :subtitle
    attribute :description
  end
end

# Accepts both symbolic and string keys.
# Class methods `[]`, `call`, and `load` are just aliases for `new`
product = Product[title: "apple", "price" => "10.9", description: "a fruit"]

# Attributes are available via methods or `[]`
product.title       # => "apple"
product[:price]     # => 10.9
product["quantity"] # => 0
product.description # => "a fruit"

# unassigned value differs from `nil`
product.subtitle    # => Dry::Initializer::UNDEFINED

# Raises in case a mandatory value not assigned
Product.new # BOOM! because neither title, nor price are assigned

# Hashifies all attributes except for undefined subtitle
# You can use `dump` as an alias for `to_h`
product.to_h
# => { title: "apple", price: 10.9, description: "a fruit", quantity: 0 }

# The structure is comparable to any object that responds to `#to_h`
product == { title: "apple", price: 10.9, description: "a fruit", quantity: 0 }
# => true
```

The structure is designed for immutability. That's why it doesn't contain writers (but you can define them by yourself via `attr_writer`).

Instead of mutating current instance, you can merge another hash to the object via `merge` or `deep_merge`.

```ruby
new_product = product.merge(title: "orange")
new_product.class # => Product
new_product.to_h
# => { title: "orange", price: 10.9, description: "a fruit", quantity: 0 }

# you can merge any object that responds to `to_h` or `to_hash`
other = Product[title: "orange", price: 12]
new_product = product.merge(other)
new_product.to_h
# => { title: "orange", price: 12, description: "a fruit", quantity: 0 }

# merge_deeply (deep_merge) gracefully merge nested hashes or hashified objects
grape = Product.new title: "grape",
                    price: 30,
                    description: { country: "FR", year: 2016, sort: "Merlot" }

new_grape = grape.merge_deeply description: { year: 2017 }
new_grape.to_h
# => {
#      title: "grape",
#      price: 30,
#      description: { country: "FR", year: 2017, sort: "Merlot" }
#     }
```

## Compatibility

Tested under rubies [compatible to MRI 2.2+](.travis.yml).

## Contributing

* [Fork the project](https://github.com/dry-rb/dry-initializer)
* Create your feature branch (`git checkout -b my-new-feature`)
* Add tests for it
* Commit your changes (`git commit -am '[UPDATE] Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](./LICENSE.txt).

[dry-initializer]: https://rom-rb.org/gems/dry-initializer
[dry-struct]: https://rom-rb.org/gems/dry-struct
[gem-badger]: https://img.shields.io/gem/v/evil-struct.svg?style=flat
[gem]: https://rubygems.org/gems/evil-struct
[gemnasium-badger]: https://img.shields.io/gemnasium/evilmartians/evil-struct.svg?style=flat
[gemnasium]: https://gemnasium.com/evilmartians/evil-struct
[inch-badger]: http://inch-ci.org/github/evilmartians/evil-struct.svg
[inch]: https://inch-ci.org/github/evilmartians/evil-struct
[travis-badger]: https://img.shields.io/travis/evilmartians/evil-struct/master.svg?style=flat
[travis]: https://travis-ci.org/evilmartians/evil-struct
