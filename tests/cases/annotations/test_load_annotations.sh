#!/bin/bash

assert_stderr "bake -q -f '${__TEST_BAKEFILES_PATH__}/annotations/load_annotations.bakefile' recipe" ""

assert_stderr "bake -q -f '${__TEST_BAKEFILES_PATH__}/annotations/load_annotations.bakefile' recipe--subprocess" ""
