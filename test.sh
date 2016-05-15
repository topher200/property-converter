#!/bin/bash

# undo changes to ws directory
pushd ~/dev/wordstream
git checkout -f
popd

# run our script
perl property_conversion.pl
