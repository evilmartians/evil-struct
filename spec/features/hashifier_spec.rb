require "spec_helper"

describe "hashifier" do
  before do
    class Test::Foo < Evil::Struct
      attribute :foo
      attribute :bar, optional: true
    end
  end

  it "converts struct to hash" do
    result = Test::Foo[foo: "bar", bar: "baz"].to_h

    expect(result).to be_instance_of Hash
    expect(result).to eq foo: "bar", bar: "baz"
  end

  it "hides unassigned values" do
    result = Test::Foo[foo: "bar"].to_h

    expect(result).to eq foo: "bar"
  end

  it "has alias .to_hash" do
    result = Test::Foo[foo: "bar"].to_hash

    expect(result).to eq foo: "bar"
  end

  it "has alias .dump" do
    result = Test::Foo[foo: "bar"].dump

    expect(result).to eq foo: "bar"
  end

  it "applied deeply" do
    data = { foo: double(to_h: { baz: [double(to_hash: { qux: nil })] }) }

    expect(Test::Foo[data].to_h).to eq foo: { baz: [{ qux: nil }] }
  end
end
