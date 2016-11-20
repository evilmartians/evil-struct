require "spec_helper"

describe "constructor aliases" do
  it ".new" do
    class Test::Foo < Evil::Struct
      attribute :foo
      attribute :baz, default: proc { "qux" }
    end

    expect(Test::Foo.new foo: "bar").to eq foo: "bar", baz: "qux"
  end

  it ".call" do
    class Test::Foo < Evil::Struct
      attribute :foo
      attribute :baz, default: proc { "qux" }
    end

    expect(Test::Foo.call foo: "bar").to eq foo: "bar", baz: "qux"
  end

  it ".load" do
    class Test::Foo < Evil::Struct
      attribute :foo
      attribute :baz, default: proc { "qux" }
    end

    expect(Test::Foo.load foo: "bar").to eq foo: "bar", baz: "qux"
  end

  it ".[]" do
    class Test::Foo < Evil::Struct
      attribute :foo
      attribute :baz, default: proc { "qux" }
    end

    expect(Test::Foo[foo: "bar"]).to eq foo: "bar", baz: "qux"
  end
end
