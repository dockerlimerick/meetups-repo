#!/bin/bash

echo "== Acquire Dependencies =="
bundle install --jobs 3

echo "== Run tests =="
bundle exec rspec --format progress -r rspec_junit_formatter --format RspecJunitFormatter -o artifacts/tests_output.xml