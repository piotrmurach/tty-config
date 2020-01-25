# frozen_string_literal: true

RSpec.describe TTY::Config::Marshaller do
  it "requires marshal method implementation" do
    stub_const("CustomMarshaller", Class.new do
      include TTY::Config::Marshaller
    end)

    custom = CustomMarshaller.new

    expect { custom.marshal({}) }.to raise_error(NotImplementedError)
  end

  it "requires unmarshal method implementation" do
    stub_const("CustomMarshaller", Class.new do
      include TTY::Config::Marshaller
    end)

    custom = CustomMarshaller.new

    expect { custom.unmarshal("") }.to raise_error(NotImplementedError)
  end
end
