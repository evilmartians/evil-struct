require "spec_helper"

describe "attributes" do
  before do
    class Test::Foo < Evil::Struct
      attribute :"some argument", as: "qux"
    end
  end

  let(:struct) { Test::Foo.new "some argument": "bar" }

  it "accessible via method" do
    expect(struct.qux).to eq "bar"
  end

  it "accessible by symbolic key" do
    expect(struct[:qux]).to eq "bar"
  end

  it "accessible by string key" do
    expect(struct["qux"]).to eq "bar"
  end
end
