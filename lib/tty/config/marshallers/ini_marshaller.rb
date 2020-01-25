# frozen_string_literal: true

require_relative "../generator"
require_relative "../marshaller"

module TTY
  class Config
    module Marshallers
      class INIMarshaller
        include TTY::Config::Marshaller

        dependency "inifile"

        extension ".ini", ".cnf", ".conf", ".cfg", ".cf"

        def marshal(object)
          TTY::Config::Generator.generate(object)
        end

        def unmarshal(content)
          ini = IniFile.new(content: content).to_h
          global = ini.delete('global')
          ini.merge!(global)
        end
      end # INIMarshaller
    end # Marshallers
  end # Config
end # TTY
