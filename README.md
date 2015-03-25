# UtilityAPI

## Overview

> UtilityAPI enables the new energy economy one data set at a time.

UtilityAPI is an enterprise software company that delivers simple access to
energy usage data. We aim to solve one of the biggest soft cost problems in the
industry. We are currently in the SfunCube Solar Accelerator Program, as well as
the Department of Energy's SunShot Catalyst Program.

This gem is a ruby SDK for the UtilityAPI web API. Currently it provides access
to most of the web interface features, including all sorts of operations with
accounts and services. The SDK methods can be called either synchronously or
asynchronously.

## Setup Prerequisites

To use this SDK you need to:

- install Ruby 2.*
- obtain the access token at the [UtilityAPI
  website](https://www.utilityapi.com):
    - create an account at https://utilityapi.com/api/users/new.html and login
      to it
    - go to settings (use top right corner gear to navigate to settings page)
    - in the Tokens table add a new token of type API

## How to install

Checkout the repository, or download an unpack the archive. In the root folder
of this project run:

    $ gem build utilityapi.gemspec

to build the gem, and:

    $ gem install utilityapi-*.gem

to install it (the wildcard can be replaced with the exact filename printed by
`gem build`).

## Including in your project

Write:

    require 'utilityapi'

at the top of the files where you would like to use this SDK. Then you will be
able to use all the provided API.

## Usage

This library has the following structure:

- `UtilityApi::Endpoints` namespace contains all the supported endpoints.
  Currently there are `AccountsApi` and `ServicesApi`.
- `UtilityApi::Models` namespace contains the models of entities which are
  either received from the API or sent to it.
- `UtilityApi` namespace itself contains helper and convenience classes. Two of
  them are to be commonly used: `AccountsUtilities` which provide relatively
  complex actions with accounts, and `Client` that incorporates instances of all
  the `Endpoints` classes and `AccountsUtilities` for ease of access.

### Basic usage

The most basic workflow using this SDK consists of two steps:

- instantiate the endpoint you'd want to use, providing the access token and
  base API URL, if it differs from the default
- make the requests you need

#### Using `AccountsApi`

Get the list of accounts:

    access_token = '...'
    accounts_api = UtilityApi::Endpoints::AccountsApi(access_token)
    accounts = accounts_api.list
    # process accounts

#### Using `ServicesApi`

Get the list of services:

    access_token = '...'
    services_api = UtilityApi::Endpoints::ServicesApi(access_token)
    services = services_api.list
    # process services

#### Using `AccountsUtilities`

Create a new account and get all the service data for it:

    access_token = '...'
    account_options = UtilityApi::Models::AccountOptions.new() # specify options in constructor
    accounts_utilities = UtilityApi::Endpoints::AccountsUtilities(access_token)
    result = accounts_utilities.create_account(account_options)
    # process result[:account], result[:service], result[:bills]

#### Using `Client`

For convenience, especially if several endpoints are needed, you can use the
`Client` class:

    access_token = '...'
    client = UtilityApi::Client(access_token)
    accounts = client.accounts.list
    services = client.services.list
    # process accounts and services
    accounts_utilities.create_account(account_options)

### Calling any method asynchronously

Any API method of this SDK can be called asynchronously. To do this, you just
need to call `.async` on an endpoint, and the call the method as usual:

    thread = accounts_api.async.list
    # ... other operations, while the request is done in the background ...
    accounts = thread.value # blocks until completed and raises errors, if any

Another possibility is to specify a callback:

    thread = accounts_api.async { |accounts| process accounts }.list
    # ... other operations, while the request is done in the background ...
    thread.join # blocks until completed and raises errors, if any

and an errback to handle errors:

    thread = accounts_api.
      async { |accounts| process accounts }
      onerror! { |e| puts e }.
      list
    # ... other operations, while the request is done in the background ...
    thread.join # only blocks, no errors raised here

This works with all the endpoints, and with `AccountsUtilities`.

## Documentation

The complete HTML documentation can be found in the `doc/` folder of the project
*(and later at a web address)*. It is generated using YARD from TomDoc-style
comments in the code.

Execute

    $ rake yard

to generate the HTML documentation from source files anew.

The UtilityAPI web API documentation can be found at
https://utilityapi.com/api/docs/api.html.

## SDK Limitations and Notes

Currently only services and accounts endpoints are supported, no operations with
users and tokens implemented.

There are several `XXX` markers in the code and tests which point at different
flaws in the UtilityAPI web API, such as wrong HTTP code returned, undocumented
field, or absence of a documented one. They correspond to the web API itself,
and don't mean errors in this SDK.

## Testing the SDK

The SDK is thoroughly tested using RSpec, and code coverage is more than 98%
(calculated with SimpleCov). There are tests both for normal operations of
methods (synchronous and asynchronous), and different error conditions.

To run the tests, install the gem locally by executing:

    $ bundle

in the root directory of the project. Then run:

    $ rake spec

to actually run all the RSpec tests. They may take quite a while, because real
requests to the remote server are used. All tests should pass, if there are no
unexpected server errors. Detailed coverage report is generated in the
`coverage/` directory.

The names of each testcase and their groups are self-explanatory, and helper
functions used in testing have comments. When the autogenerated testcase name
reads well and clear, explicit name was not given. Also there is a small amount
of repeating code in test cases, but this was not removed to keep the cases
clear and error-free.

## Contributing

1. Fork it (https://github.com/repo/fork) *not published yet!*
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
