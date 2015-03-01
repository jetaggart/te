[![Stories in Ready](https://badge.waffle.io/jetaggart/te.svg?label=ready&title=Ready)](http://waffle.io/jetaggart/te)

# te - universal test runner

Well.. soon to be universal test runner. The vision is to build a generic command line interface for running tests. Because no one uses a single language anymore. Supports `rspec` and `minitest`.

## Usage

All tests:

```bash
te run
```

Single Test:

```bash
te run spec.rb
```

Single line:

```bash
te run spec.rb:12
```

### Async usage

From the root directory of your project, open two terminals (or splits/panes/whatever) and in one run:

```bash
te listen
```

In the other terminal run your tests!

```bash
te run spec.rb
```

## Installation

### os x

```bash
brew tap jetaggart/te
brew install jetaggart/te/te
```

### Other platforms

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
* haskell hspec
* go ginkgo

## Inspiration

The inconsistency of testing tools, inconsistency of plugins that run testing tools, the consistency of IDE test running (intellij), async test running being highly couple to applications, and Gary Bernhardt's destroy all software screencast #87: RUNNING TESTS ASYNCHRONOUSLY
