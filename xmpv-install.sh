#!/bin/bash

# Description: 
# Author: Xuan Ngo
# Version: 0.0.1
# Requirements: 
# Reference: 

LUA_DIR=~/.config/mpv/scripts
mkdir -p ${LUA_DIR}

# Add lua scripts
TEST_DIR=test

yes | cp xmpv.lua ${LUA_DIR}
yes | cp xmpv-*.lua ${LUA_DIR}


### Unit tests
#rm -f ${LUA_DIR=}/xmpv-unit-tests.lua

yes | cp ${TEST_DIR}/xmpv-unit-tests.lua ${LUA_DIR}
yes | cp ${TEST_DIR}/luaunit.lua ${LUA_DIR}