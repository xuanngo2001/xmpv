#!/bin/bash

# Description: Copy xmpv lua scripts to the mpv scripts directory

LUA_DIR=${HOME}/.config/mpv/scripts
mkdir -p ${LUA_DIR}

# Add lua scripts
TEST_DIR=test

yes | cp -av ./xmpv/* ${LUA_DIR}


### Unit tests
#rm -f ${LUA_DIR=}/xmpv-unit-tests.lua

#yes | cp ${TEST_DIR}/xmpv-unit-tests.lua ${LUA_DIR}
#yes | cp ${TEST_DIR}/luaunit.lua ${LUA_DIR}