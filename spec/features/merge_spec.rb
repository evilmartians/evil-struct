require "spec_helper"

describe "merge" do
  before do
    class Test::Foo < Evil::Struct
      attribute :foo
      attribute :bar
    end
  end

  let(:struct) { Test::Foo.new foo: :FOO, bar: :BAR }

  it "merges hash with symbol keys" do
    other = { bar: :BAZ, baz: :QUX }
    expect { struct.merge(other) }.not_to change { struct }

    result = struct.merge(other)
    expect(result).to be_instance_of Test::Foo
    expect(result).to eq foo: :FOO, bar: :BAZ
  end

  it "merges hash with string keys" do
    other = { "bar" => :BAZ, "baz" => :QUX }
    expect { struct.merge(other) }.not_to change { struct }

    result = struct.merge(other)
    expect(result).to be_instance_of Test::Foo
    expect(result).to eq foo: :FOO, bar: :BAZ
  end

  it "merges objects supporting #to_h" do
    other = double to_h: { bar: :BAZ, baz: :QUX }
    expect { struct.merge(other) }.not_to change { struct }

    result = struct.merge(other)
    expect(result).to be_instance_of Test::Foo
    expect(result).to eq foo: :FOO, bar: :BAZ
  end

  it "merges objects supporting #to_hash" do
    other = double to_hash: { bar: :BAZ, baz: :QUX }
    expect { struct.merge(other) }.not_to change { struct }

    result = struct.merge(other)
    expect(result).to be_instance_of Test::Foo
    expect(result).to eq foo: :FOO, bar: :BAZ
  end
end
