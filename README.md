# te - universal test runner

Well.. soon to be universal test runner. The vision is to build a generic command line interface to to running tests.

## Usage

From the root directory of your project, open two terminals (or splits/panes/whatever) and in one run:

```bash
te init
te listen
```

In the other run your tests!

```bash
te run spec.rb
```

## Installation

Check out this repository, run `cabal install`, copy the `te` executable into your executable path of choice.

### Editor support
* [vim](https://github.com/jetaggart/vim-te)

## Vision

Eventually, running tests for multiple langauges and frameworks will be support. 
For example, to run rspec tests, you run:

```bash
te run spec/some_test_spec.rb
te run spec/some_test_spec.rb:123
```

And to run haskell tests you run:

```bash
te run tests/MainSpec.hs
te run tests/MainSpec.hs:123
```

Right now it only runs rspec. Next languages/frameworks to be support:
* ruby minitest
* haskell hspec
