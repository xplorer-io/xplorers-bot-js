#!/bin/bash

deliverable=$(pwd)/lambda.zip

echo 'Creating deployment package'

echo "Including source files"
zip -jrq9 ${deliverable} src/*.js cloudformation/*.yml

echo "Build complete! Moving file to destination"
mv ${deliverable} cloudformation/
