# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module MarkupFuel
  module Library
    module Serialize
      # This job works on a single register, reads its value, and serializes it using
      # the XmlSimple gem.  There is some nice documentation that ships with the gem
      # located here: https://github.com/maik/xml-simple/tree/master/docs.
      # More or less, this is just a Burner::Job wrapper around the XmlSimple#xml_out API.
      #
      # Expected Payload[register] input: Ruby object modeling.
      # Payload[register] output: XML representation of the Ruby object modeling as a string.
      class Xml < Burner::JobWithRegister
        NO_ATTR_KEY   = 'NoAttr'
        ROOT_NAME_KEY = 'RootName'

        attr_reader :options

        def initialize(
          name: '',
          no_attributes: true,
          register: Burner::DEFAULT_REGISTER,
          root_name: nil
        )
          super(name: name, register: register)

          @options = make_options(no_attributes, root_name)

          freeze
        end

        def perform(_output, payload)
          payload[register] = XmlSimple.xml_out(payload[register] || {}, options)
        end

        def make_options(no_attributes, root_name)
          { NO_ATTR_KEY => no_attributes }.tap do |opts|
            opts[ROOT_NAME_KEY] = root_name unless root_name.to_s.empty?
          end
        end
      end
    end
  end
end
