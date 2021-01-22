# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module MarkupFuel
  module Library
    module Deserialize
      # This job works on a single register, reads its value, and de-serializes it using
      # the XmlSimple gem.  There is some nice documentation that ships with the gem
      # located here: https://github.com/maik/xml-simple/tree/master/docs.
      # More or less, this is just a Burner::Job wrapper around the XmlSimple#xml_in API.
      #
      # Expected Payload[register] input: string of XML.
      # Payload[register] output: Ruby object representation of the XML.
      class Xml < Burner::JobWithRegister
        FORCE_ARRAY_KEY = 'ForceArray'

        attr_reader :options

        def initialize(
          force_array: false,
          name: '',
          register: Burner::DEFAULT_REGISTER
        )
          super(name: name, register: register)

          @options = make_options(force_array)

          freeze
        end

        def perform(_output, payload)
          value = payload[register]

          if value.to_s.empty?
            payload[register] = nil
            return
          end

          payload[register] = XmlSimple.xml_in(payload[register], options)
        end

        private

        def make_options(force_array)
          { FORCE_ARRAY_KEY => force_array }
        end
      end
    end
  end
end
