#!/bin/bash
find src -type f \( -name "*.jsx" -o -name "*.css" \) -print0 | xargs -0 sed -i '' \
  -e 's/from-indigo-500/from-slate-800/g' \
  -e 's/to-purple-700/to-slate-900/g' \
  -e 's/bg-indigo-600/bg-blue-700/g' \
  -e 's/bg-indigo-500/bg-blue-700/g' \
  -e 's/hover:bg-indigo-700/hover:bg-blue-800/g' \
  -e 's/hover:bg-indigo-500/hover:bg-blue-800/g' \
  -e 's/text-indigo-500/text-blue-700/g' \
  -e 's/text-indigo-600/text-blue-700/g' \
  -e 's/border-indigo-500/border-blue-700/g' \
  -e 's/shadow-indigo-500\/40/shadow-blue-700\/40/g' \
  -e 's/shadow-indigo-500\/30/shadow-blue-700\/30/g' \
  -e 's/#667eea/#1e40af/g' \
  -e 's/#764ba2/#0f172a/g' \
  -e 's/#4c51bf/#1d4ed8/g' \
  -e 's/#5568d3/#1e3a8a/g'
echo "Colores actualizados"
