# Markup Fuel

[![Gem Version](https://badge.fury.io/rb/markup_fuel.svg)](https://badge.fury.io/rb/markup_fuel) [![Build Status](https://travis-ci.com/bluemarblepayroll/markup_fuel.svg?branch=master)](https://travis-ci.com/bluemarblepayroll/markup_fuel) [![Maintainability](https://api.codeclimate.com/v1/badges/e38efa993c8292a45a99/maintainability)](https://codeclimate.com/github/bluemarblepayroll/markup_fuel/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/e38efa993c8292a45a99/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/markup_fuel/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This library is a plugin for [Burner](https://github.com/bluemarblepayroll/burner).  It adds jobs focused around XML processing such as reading and writing XML documents.  XML can get very non-trivial quickly, but this library aims at implementing only what is identified as necessary for XML processing.  Pull requests are welcomed to add more additional functionality.

## Installation

To install through Rubygems:

````bash
gem install markup_fuel
````

You can also add this to your Gemfile:

````bash
bundle add markup_fuel
````
## Jobs

Refer to the [Burner](https://github.com/bluemarblepayroll/burner) library for more specific information on how Burner works.  This section will just focus on what this library directly adds.

* **markup_fuel/deserialize/xml** [force_array, register]: Take a register's value as a string and parse it as XML into a rich Ruby object modeling.  The `force_array` option is false by default.  If `force_array` is true then each keys' value will be wrapped in an array.
* **markup_fuel/serialize/xml** [no_attributes, register, root_name]: Take a register's value as a Ruby object model and convert it to an XML document in string form.  The `no_attributes` option is set to true by default which will force each key to a node.  The `root_name` is nil by default, which will produce an `<opt>` node around the entire document.  This can be configured to be something other than `<opt>` by passing in something not nil.  If `root_name` is a blank string then no top level node will exist.

## Examples

### Parsing (de-serializing) an XML Document

Let's use the example fixture file as an example XML file to read and parse (located at `spec/fixtures/patients.xml`).  We could execute the following Burner pipeline:

````ruby
pipeline = {
        jobs: [
          {
            name: 'read',
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
            name: 'parse',
            register: 'patients',
            type: 'markup_fuel/deserialize/xml'
          }
        ]
      }

payload = Burner::Payload.new

Burner::Pipeline.make(pipeline).execute(payload: payload)
````

Inspecting the payload's registers would now look something like this:

````ruby
patients = payload['patients']

#{
#  'patient' => [
#    {
#      'demographics' => {
#        'first' => 'Bozo',
#        'last' => 'Clown'
#      },
#      'id' => '1'
#    },
#    {
#      'demographics' => {
#        'first' => 'Frank',
#        'last' => 'Rizzo'
#      },
#      'id' => '2'
#    }
#  ]
#}
````

### Writing (serializing) an XML Document

Let's do an exact opposite of the above example.  Let's say we would like to write an XML document:

````ruby
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

Burner::Pipeline.make(pipeline).execute(payload: payload)
````

Inspecting the payload's registers would now look something like this:

````ruby
patients = payload['patients']

# <patients>
#   <patient>
#     <demographics>
#       <first>Bozo</first>
#       <last>Clown</last>
#     </demographics>
#     <id>1</id>
#   </patient>
#   <patient>
#     <demographics>
#       <first>Frank</first>
#       <last>Rizzo</last>
#     </demographics>
#     <id>2</id>
#   </patient>
# </patients>
````

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check markup_fuel.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/markup_fuel.git)
4. Navigate to the root folder (cd markup_fuel)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````bash
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````bash
bundle exec guard
````

Also, do not forget to run Rubocop:

````bash
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update `lib/markup_fuel/version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bluemarblepayroll/markup_fuel/blob/master/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.

