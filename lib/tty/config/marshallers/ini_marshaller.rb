# frozen_string_literal: true

require_relative "abstract"
require_relative "../generator"

module TTY
  class Config
    module Marshallers
      class INIMarshaller < Abstract

        dependency "inifile"

        extension ".ini", ".cnf", ".conf", ".cfg", ".cf"

        def marshal(data, options = {})
          TTY::Config::Generator.generate(data)
        end

        def unmarshal(file, options = {})
          ini = IniFile.load(file).to_h
          global = ini.delete('global')
          ini.merge!(global)
        end
      end # INIMarshaller
    end # Marshallers
  end # Config
end # TTY
