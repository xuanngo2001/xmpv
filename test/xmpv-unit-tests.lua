luaunit = require('luaunit')







function run_unit_tests()

  os.exit( luaunit.LuaUnit.run() )
  
end

mp.add_key_binding("Alt+u", "run_unit_tests", run_unit_tests)