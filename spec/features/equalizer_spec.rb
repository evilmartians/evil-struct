require "spec_helper"

describe "equalizer" do
  it "uses #to_h for comparison" do
    class Test::Foo < Evil::Struct
      attribute :foo
    end

    expect(Test::Foo.new foo: "bar").to eq foo: "bar"
    expect(Test::Foo.new foo: "bar").to eq double(to_h: { foo: "bar" })
  end

  it "makes struct not equal to nil" do
    class Test::Foo < Evil::Struct
      attribute :foo, optional: true
    end

    expect(Test::Foo.new).to eq({})
    expect(Test::Foo.new).not_to eq nil
  end
end
