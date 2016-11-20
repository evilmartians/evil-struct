require "spec_helper"

describe "shared options" do
  it "supported via .attributes" do
    class Test::Foo < Evil::Struct
      attributes type: Dry::Types["strict.string"], default: proc { "bar" } do
        attribute :foo
        attribute :baz, default: proc { "qux" }
      end
    end

    expect(Test::Foo.new).to eq foo: "bar", baz: "qux"
    expect { Test::Foo.new foo: 1 }.to raise_error(TypeError)
  end
end
