# frozen_string_literal: true

require "tty/config/dependency_loader"

RSpec.describe TTY::Config::DependencyLoader do
  it "loads a dependency only when instatiated" do
    stub_const("CustomMarshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency "yaml"
    end)

    allow(CustomMarshaller).to receive(:require)

    CustomMarshaller.new

    expect(CustomMarshaller.dep_name).to eq(["yaml"])
    expect(CustomMarshaller).to have_received(:require).once
  end

  it "fails to load a dependency" do
    stub_const("CustomMarshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency "unknown"
    end)

    allow(CustomMarshaller).to receive(:require).and_raise(LoadError)

    expect {
      CustomMarshaller.new
    }.to raise_error(TTY::Config::DependencyLoadError,
                     /The dependency `unknown` is missing/)
  end

  it "loads many dependencies in an array" do
    stub_const("CustomMarshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency "yaml", "json"
    end)

    allow(CustomMarshaller).to receive(:require)

    CustomMarshaller.new

    expect(CustomMarshaller.dep_name).to eq(%w[yaml json])
    expect(CustomMarshaller).to have_received(:require).twice
  end

  it "fails to load many dependencies in an array" do
    stub_const("CustomMarshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency "unknown1", "unknown2"
    end)

    allow(CustomMarshaller).to receive(:require).and_raise(LoadError)

    expect {
      CustomMarshaller.new
    }.to raise_error(TTY::Config::DependencyLoadError,
                     /The dependencies `unknown1, unknown2` are missing/)
  end

  it "loads many dependencies in a block" do
    stub_const("CustomMarshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency do
        require "yaml"
        require "json"
      end
    end)

    allow(CustomMarshaller).to receive(:require)

    CustomMarshaller.new

    expect(CustomMarshaller.dep_name).to eq([])
    expect(CustomMarshaller).to have_received(:require).twice
  end

  it "fails to load many dependencies in a block" do
    stub_const("CustomMarshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency do
        require "unknown"
      end
    end)

    allow(CustomMarshaller).to receive(:require).and_raise(LoadError)

    expect {
      CustomMarshaller.new
    }.to raise_error(TTY::Config::DependencyLoadError,
                     /One or more dependency are missing/)
  end

  it "doesn't load any dependency when not specified" do
    stub_const("CustomMarshaller", Class.new do
      extend TTY::Config::DependencyLoader
    end)

    allow(CustomMarshaller).to receive(:require)

    CustomMarshaller.new

    expect(CustomMarshaller).to_not have_received(:require)
  end
end
