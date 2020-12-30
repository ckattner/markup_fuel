# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe MarkupFuel::Library::Serialize::Xml do
  let(:output)        { Burner::Output.new(outs: [StringIO.new]) }
  let(:register)      { 'register_a' }
  let(:no_attributes) { true }
  let(:root_name)     { 'patients' }

  let(:contents) do
    {
      'patient' => [
        {
          'demographics' => {
            'first' => 'Bozo',
            'last' => 'Clown'
          },
          'id' => '1'
        },
        {
          'demographics' => {
            'first' => 'Frank',
            'last' => 'Rizzo'
          },
          'id' => '2'
        }
      ]
    }
  end

  let(:payload) { Burner::Payload.new(registers: { register => contents }) }

  subject do
    described_class.make(
      name: 'test_job',
      no_attributes: no_attributes,
      register: register,
      root_name: root_name
    )
  end

  describe '#perform' do
    before(:each) { subject.perform(output, payload) }

    context 'when root_name is blank' do
      let(:root_name) { '' }

      it 'serializes data with default root node' do
        actual = payload[register]

        expected = <<~XML
          <opt>
            <patient>
              <demographics>
                <first>Bozo</first>
                <last>Clown</last>
              </demographics>
              <id>1</id>
            </patient>
            <patient>
              <demographics>
                <first>Frank</first>
                <last>Rizzo</last>
              </demographics>
              <id>2</id>
            </patient>
          </opt>
        XML

        expect(actual).to eq(expected)
      end
    end

    context 'when root_name is present' do
      it 'serializes data with specified root node' do
        actual = payload[register]

        expected = <<~XML
          <patients>
            <patient>
              <demographics>
                <first>Bozo</first>
                <last>Clown</last>
              </demographics>
              <id>1</id>
            </patient>
            <patient>
              <demographics>
                <first>Frank</first>
                <last>Rizzo</last>
              </demographics>
              <id>2</id>
            </patient>
          </patients>
        XML

        expect(actual).to eq(expected)
      end
    end

    context 'when no_attributes is false' do
      let(:no_attributes) { false }

      it 'serializes data with attributes' do
        actual = payload[register]

        expected = <<~XML
          <patients>
            <patient id="1">
              <demographics first="Bozo" last="Clown" />
            </patient>
            <patient id="2">
              <demographics first="Frank" last="Rizzo" />
            </patient>
          </patients>
        XML

        expect(actual).to eq(expected)
      end
    end
  end

  describe 'README examples' do
    specify 'the simple writing example works' do
      pipeline = {
        jobs: [
          {
            name: 'load_patients',
            type: 'b/value/static',
            register: :patients,
            value: {
              'patient' => [
                {
                  'demographics' => {
                    'first' => 'Bozo',
                    'last' => 'Clown'
                  },
                  'id' => '1'
                },
                {
                  'demographics' => {
                    'first' => 'Frank',
                    'last' => 'Rizzo'
                  },
                  'id' => '2'
                }
              ]
            }
          },
          {
            name: 'to_xml',
            type: 'markup_fuel/serialize/xml',
            register: :patients,
            root_name: :patients
          }
        ]
      }

      payload = Burner::Payload.new

      Burner::Pipeline.make(pipeline).execute(output: output, payload: payload)

      actual = payload['patients']

      expected = <<~XML
        <patients>
          <patient>
            <demographics>
              <first>Bozo</first>
              <last>Clown</last>
            </demographics>
            <id>1</id>
          </patient>
          <patient>
            <demographics>
              <first>Frank</first>
              <last>Rizzo</last>
            </demographics>
            <id>2</id>
          </patient>
        </patients>
      XML

      expect(actual).to eq(expected)
    end
  end
end
