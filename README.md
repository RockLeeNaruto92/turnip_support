# turnip-support
**turnip-support** supports testing Rails application features using [Turnip](https://github.com/jnicklas/turnip).


## Table of contents:
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Initialize environment](#initialize-environment)
  - [Generate feature file](#generate-feature-file)

## Installation

Add this line to your Gemfile:

```ruby
  gem "turnip_support", git: "https://github.com/ThuBM/turnip_support"
```

Now run:

```shell
bundle install
```

## Usage

### Initialize environment

On first use, you need to initialize the test enviroment:

```shell
  cd <your project folder>
  rake turnip_support init
```

### Generate feature file

To test a feature of your application, you first need to prepare two files:
- A test pattern spread sheet. Please follow [Test pattern spread sheet template](https://github.com/ThuBM/turnip_support/wiki/Test-pattern-spread-sheet-template) to create your test pattern spread sheet file.
- A configure file. [View more](https://github.com/ThuBM/turnip_support/wiki/Configuration)

Now run the below command to generate your feature file:

```shell
  rake turnip_support [feature_name] [yml_config_file]
```

Now you can run the feature test:

```shell
  rspec spec/features/[feature_name].feature
```
