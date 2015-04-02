#!/bin/sh
# Description: 
# Author: Xuan Ngo
# Version: 0.0.1
# Requirements: 
# Reference: 

LUA_DIR=/root/.mpv/lua/
mkdir -p ${LUA_DIR}

# Add lua scripts
yes | cp xmpv.lua ${LUA_DIR}