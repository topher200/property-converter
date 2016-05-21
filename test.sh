#!/bin/bash

# undo changes to ws directory
pushd ~/dev/wordstream
git checkout -f &> /dev/null
popd

# run our script
perl property_conversion.pl &> log.txt || true && tail -n 30 log.txt
