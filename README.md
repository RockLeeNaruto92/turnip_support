# turnip-support
**turnip-support** is the tool that support testing features of Rails applications.


## Table of contents:
- [Requirements](#requirements)
- [Install](#install)
- [How to use](#how-to-use)
  - [Initialize environment](#initialize-environment)
  - [Generate feature file](#generate-feature-file)

## Install

Add below line to your Gemfile.

```
gem "turnip_support", git: "https://github.com/ThuBM/turnip_support"
```

then run

```
bundle install
```

## How to use

### Initialize environment

At the first time, you must run below command to initialize the enviroment:

```
cd [YOUR_PROJECT_FOLDER]
rake turnip_support init
```

### Generate feature file

For test a feature of your app, you must:
- prepare 2 files:
  - A test pattern spread sheet. Please follow [Test pattern spread sheet template](https://github.com/ThuBM/turnip_support/wiki/Test-pattern-spread-sheet-template) to create your test pattern spread sheet file.
  - A configure file. [View more](https://github.com/ThuBM/turnip_support/wiki/Configuration)
- run below command to generate the corresponding feature file:

```
cd [YOUR_PROJECT_FOLDER]
rake turnip_support [feature_name] [yml_config_file]
```

Now you can run below command for testing:

```
rspec spec/features/[feature_name].feature
```
