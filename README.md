# te - universal test runner

Well.. soon to be universal test runner. The vision is to build a generic command line interface to to running tests.

## Usage

From the root directory of your project, open two terminals (or splits/panes/whatever) and in one run:

`te init`
`te listen`

In the other run your tests!

`te run spec.rb`

## Vision

Eventually, running tests for multiple langauges and frameworks will be support. 
For example, to run rspec tests, you run:

`te run spec/some_test_spec.rb`
`te run spec/some_test_spec.rb:123`

And to run haskell tests you run:

`te run tests/MainSpec.hs`
`te run tests/MainSpec.hs:123`

Right now it only runs rspec. Next languages/frameworks to be support:
* ruby minitest
* haskell hspec
