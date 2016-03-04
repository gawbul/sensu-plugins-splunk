## Sensu-Plugins-Splunk

[ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-splunk.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-splunk)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-splunk.svg)](http://badge.fury.io/rb/sensu-plugins-splunk)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-splunk/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-splunk)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-splunk/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-splunk)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-splunk.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-splunk)
[ ![Codeship Status for sensu-plugins/sensu-plugins-splunk](https://codeship.com/projects/a5fd5b10-ea2e-0132-7a33-32dfa18a9fce/status?branch=master)](https://codeship.com/projects/83064)

## Functionality

## Files
 * bin/check-splunk-license-usage.rb
 * bin/check-splunk-service-status.rb
 * bin/metrics-splunk-license-usage.rb

## Usage

```
{
  "checks": {
    "check-splunk-service-status": {
      command: "check-splunk-service-status.rb -h localhost -u admin -p changeme",
      "subscribers": [
        "splunk"
      ],
      interval: 60,
      timeout: 10
    }
  }
}
```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
