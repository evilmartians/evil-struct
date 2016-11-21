require "spec_helper"

describe "deep merge" do
  before do
    class Test::Foo < Evil::Struct
      attribute :foo
      attribute :bar
    end
  end

  let(:struct) do
    Test::Foo.new foo: { bar: [{ foo: :FOO }] },
                  bar: { baz: :FOO, qux: :QUX }
  end

  let(:result) do
    struct.merge_deeply foo: { bar: [{ qux: :QUX }] },
                        bar: { "qux" => :FOO }
  end

  it "works" do
    expect { result }.not_to change { struct }

    expect(result).to be_instance_of Test::Foo
    expect(result).to eq foo: { bar: [{ qux: :QUX }] },
                         bar: { baz: :FOO, qux: :FOO }
  end
end
