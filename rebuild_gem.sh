#!/bin/sh -e

gem build vagrant-rightscale.gemspec && vagrant plugin install ./vagrant-rightscale-0.0.1.dev.gem
