#!/bin/bash

# Description: Copy xmpv lua scripts to the mpv scripts directory

LUA_DIR=${HOME}/.config/mpv/scripts
mkdir -p ${LUA_DIR}

yes | cp -av * ${LUA_DIR}

