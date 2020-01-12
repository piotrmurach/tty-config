# frozen_string_literal: true

require "tty/config/dependency_loader"

RSpec.describe TTY::Config::DependencyLoader do
  it "loads a dependency" do
    stub_const("Marshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency "yaml"
    end)

    allow(Marshaller).to receive(:require)

    Marshaller.new

    expect(Marshaller.dep_name).to eq(["yaml"])
    expect(Marshaller).to have_received(:require).once
  end

  it "fails to load a dependency" do
    stub_const("Marshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency "unknown"
    end)

    allow(Marshaller).to receive(:require).and_raise(LoadError)

    expect {
      Marshaller.new
    }.to raise_error(TTY::Config::DependencyLoadError,
                     /The dependency `unknown` is missing/)
  end

  it "loads many dependencies in an array" do
    stub_const("Marshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency "yaml", "json"
    end)

    allow(Marshaller).to receive(:require)

    Marshaller.new

    expect(Marshaller.dep_name).to eq(%w[yaml json])
    expect(Marshaller).to have_received(:require).twice
  end

  it "fails to load many dependencies in an array" do
    stub_const("Marshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency "unknown1", "unknown2"
    end)

    allow(Marshaller).to receive(:require).and_raise(LoadError)

    expect {
      Marshaller.new
    }.to raise_error(TTY::Config::DependencyLoadError,
                     /The dependencies `unknown1, unknown2` are missing/)
  end

  it "loads many dependencies in a block" do
    stub_const("Marshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency do
        require "yaml"
        require "json"
      end
    end)

    allow(Marshaller).to receive(:require)

    Marshaller.new

    expect(Marshaller.dep_name).to eq([])
    expect(Marshaller).to have_received(:require).twice
  end

  it "fails to load many dependencies in a block" do
    stub_const("Marshaller", Class.new do
      extend TTY::Config::DependencyLoader

      dependency do
        require "unknown"
      end
    end)

    allow(Marshaller).to receive(:require).and_raise(LoadError)

    expect {
      Marshaller.new
    }.to raise_error(TTY::Config::DependencyLoadError,
                     /One or more dependency are missing/)
  end
end
