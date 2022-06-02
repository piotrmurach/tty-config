# frozen_string_literal: true

require_relative "../marshaller"

module TTY
  class Config
    module Marshallers
      # Responsible for marshalling content from and into XML format
      #
      # @api public
      class XMLMarshaller
        include TTY::Config::Marshaller

        dependency "xmlsimple"

        extension ".xml"

        def marshal(object)
          XmlSimple.xml_out(object, {rootname: "config"})
        end

        def unmarshal(content)
          return {} if content.empty?

          XmlSimple.xml_in(content, {force_array: false})
        end
      end # XMLMarshaller
    end # Marshallers
  end # Config
end # TTY
