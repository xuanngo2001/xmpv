#!/bin/bash

# -Extract text between <readme> and </readme>.
# -Remove <readme>.
# -Remove </readme>.
sed -n "/<readme>/,/<\/readme>/p" ./xmpv/xmpv.lua | sed 's/<readme>//' | sed 's/<\/readme>//' > README.md
