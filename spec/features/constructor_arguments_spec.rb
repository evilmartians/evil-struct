require "spec_helper"

describe "constructor" do
  before do
    class Test::Foo < Evil::Struct
      attribute :foo, default: proc { "qux" }
    end
  end

  it "accepts hash with symbolic keys" do
    expect(Test::Foo.new foo: "bar").to eq foo: "bar"
  end

  it "accepts hash with string keys" do
    expect(Test::Foo.new "foo" => "bar").to eq foo: "bar"
  end

  it "accepts nil" do
    expect(Test::Foo.new nil).to eq foo: "qux"
  end

  it "accepts no arguments" do
    expect(Test::Foo.new).to eq foo: "qux"
  end
end
