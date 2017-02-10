# Testing

Testing Timber uses [`appraisal`](https://github.com/thoughtbot/appraisal). This allows us to
test across multiple versions and combinations of libraries.

To get started:

```shell
bundle install
bundle exec appraisal install
```

To see all appraisal commands:

```shell
appraisal --help
```

You can run tests with:

```shell
appraisal rails-3.2.X rspec
```