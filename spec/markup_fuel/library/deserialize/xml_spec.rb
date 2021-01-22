# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe MarkupFuel::Library::Deserialize::Xml do
  let(:output)      { Burner::Output.new(outs: [StringIO.new]) }
  let(:register)    { 'register_a' }
  let(:path)        { File.join('spec', 'fixtures', 'patients.xml') }
  let(:contents)    { File.open(path, &:read) }
  let(:payload)     { Burner::Payload.new(registers: { register => contents }) }
  let(:force_array) { false }

  subject do
    described_class.make(
      force_array: force_array,
      name: 'test_job',
      register: register
    )
  end

  describe '#perform' do
    specify 'payload register has deserialized data' do
      subject.perform(output, payload)

      actual = payload[register]

      expected = {
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

      expect(actual).to eq(expected)
    end

    context 'when content has attributes' do
      let(:path) { File.join('spec', 'fixtures', 'patients_with_attrs.xml') }

      specify 'payload register has deserialized data' do
        subject.perform(output, payload)

        actual = payload[register]

        expected = {
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

        expect(actual).to eq(expected)
      end
    end

    context 'when content is nil' do
      let(:contents) { nil }

      specify 'payload register is set to nil' do
        subject.perform(output, payload)

        actual   = payload[register]
        expected = nil

        expect(actual).to eq(expected)
      end
    end

    context 'when content is a blank string' do
      let(:contents) { '' }

      specify 'payload register is set to nil' do
        subject.perform(output, payload)

        actual   = payload[register]
        expected = nil

        expect(actual).to eq(expected)
      end
    end

    context 'when forcing arrays' do
      let(:force_array) { true }

      specify 'payload register key values are arrays' do
        subject.perform(output, payload)

        actual   = payload[register]
        expected = {
          'patient' => [
            {
              'demographics' => [
                {
                  'first' => ['Bozo'],
                  'last' => ['Clown']
                }
              ],
              'id' => ['1']
            },
            {
              'demographics' => [
                {
                  'first' => ['Frank'],
                  'last' => ['Rizzo']
                }
              ],
              'id' => ['2']
            }
          ]
        }

        expect(actual).to eq(expected)
      end
    end
  end

  describe 'README examples' do
    specify 'the simple parsing example works' do
      pipeline = {
        jobs: [
          {
            type: 'b/value/static',
            register: 'patients',
            value: <<~XML
              <patients>
                <patient>
                  <id>1</id>
                  <demographics>
                    <first>Bozo</first>
                    <last>Clown</last>
                  </demographics>
                </patient>
                <patient>
                  <id>2</id>
                  <demographics>
                    <first>Frank</first>
                    <last>Rizzo</last>
                  </demographics>
                </patient>
              </patients>
            XML
          },
          {
            register: 'patients',
            type: 'markup_fuel/deserialize/xml'
          }
        ]
      }

      payload = Burner::Payload.new

      Burner::Pipeline.make(pipeline).execute(output: output, payload: payload)

      actual = payload['patients']

      expected = {
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

      expect(actual).to eq(expected)
    end
  end
end
