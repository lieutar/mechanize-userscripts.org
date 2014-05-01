#!/bin/bash

for CMD in "`make uninstall | grep "^unlink "`"; do
    bash -c "$CMD"
done
