local ito
do
  local _obj_0 = require('test.unit.viml.executor.helpers')
  ito = _obj_0.ito
end

describe(':if block', function()
  ito('Runs if 1', [[
    echo 1
    if 1
      echo 2
    end
    echo 3
  ]], {1, 2, 3})
  ito('Does not run if 0', [[
    echo 1
    if 0
      echo 2
    end
    echo 3
  ]], {1, 3})
  ito('Runs if 0 ... else', [[
    echo 1
    if 0
      echo 2
    else
      echo 3
    end
    echo 4
  ]], {1, 3, 4})
  ito('Runs if 0 ... elseif 1', [[
    echo 1
    if 0
      echo 2
    elseif 1
      echo 3
    end
    echo 4
  ]], {1, 3, 4})
  ito('Runs if 0 ... elseif 1, but not else', [[
    echo 1
    if 0
      echo 2
    elseif 1
      echo 3
    else
      echo 4
    end
    echo 5
  ]], {1, 3, 5})
  ito('Runs if 0 ... second elseif 1', [[
    echo 1
    if 0
      echo 2
    elseif 0
      echo 3
    elseif 1
      echo 4
    end
    echo 5
  ]], {1, 4, 5})
  ito('Runs if 0 ... second elseif 1, but not else', [[
    echo 1
    if 0
      echo 2
    elseif 0
      echo 3
    elseif 1
      echo 4
    else
      echo 5
    end
    echo 6
  ]], {1, 4, 6})
  ito('Handles empty :if 0', [[
    echo 1
    if 0
    end
    echo 2
  ]], {1, 2})
  ito('Handles empty :if 1', [[
    echo 1
    if 1
    end
    echo 2
  ]], {1, 2})
  ito('Handles empty :if 0 ... else', [[
    echo 1
    if 0
    else
    end
    echo 2
  ]], {1, 2})
  ito('Handles empty :if 1 ... else', [[
    echo 1
    if 1
    else
    end
    echo 2
  ]], {1, 2})
  ito('Handles empty :if 0 ... elseif 1 ... else', [[
    echo 1
    if 0
    elseif 1
    else
    end
    echo 2
  ]], {1, 2})
  ito('Handles empty :if 0 ... elseif 1', [[
    echo 1
    if 0
    elseif 1
    end
    echo 2
  ]], {1, 2})
end)

describe(':try block', function()
  ito('Handles empty :try', [[
    echo 1
    try
    endtry
    echo 2
  ]], {1, 2})
  ito('Handles empty :try .. catch', [[
    echo 1
    try
    catch
    endtry
    echo 2
  ]], {1, 2})
  ito('Handles empty :try .. finally', [[
    echo 1
    try
    finally
    endtry
    echo 2
  ]], {1, 2})
  ito('Handles empty :try .. catch .. finally', [[
    echo 1
    try
    catch
    finally
    endtry
    echo 2
  ]], {1, 2})
  ito('Handles empty :try .. catch .. catch .. finally', [[
    echo 1
    try
    catch
    catch
    finally
    endtry
    echo 2
  ]], {1, 2})
  ito(':catch shows correct v:exception', [[
    try
      echo a
    catch
      echo v:exception
    endtry
  ]], {'Vim(echo):E121: Undefined variable: a'})
  ito('v:exception is empty outside of the :catch if there was no exception', [[
    try
    catch
    endtry
    echo v:exception
  ]], {''})
  ito('v:exception is empty outside of the :catch if there was exception', [[
    try
      echo a
    catch
    endtry
    echo v:exception
  ]], {''})
  ito('v:exception is empty before :try', [[
    echo v:exception
    try
    catch
    endtry
  ]], {''})
  ito('v:exception before :try, inside it, :catch, :finally and at the end', [[
    echo v:exception
    try
      echo v:exception
      echo a
    catch
      echo v:exception
    finally
      echo v:exception
    endtry
    echo v:exception
  ]], {'', '', 'Vim(echo):E121: Undefined variable: a', '', ''})
end)

describe(':function definition', function()
  ito('Calls user-defined function with default return value', [[
    function Abc()
      echo 'Abc'
    endfunction
    echo Abc()
    delfunction Abc
  ]], {'Abc', 0})
  ito('Does not add `self` for regular call', [[
    function Abc()
      echo self
    endfunction
    try
      echo Abc()
    catch
      echo v:exception
    endtry
    delfunction Abc
  ]], {
    'Vim(echo):E121: Undefined variable: self'
  })
  ito('Function accepts arguments', [[
    function Abc(a, b, c)
      echo a:a
      echo a:b
      echo a:c
    endfunction
    echo Abc(1, 2, 3)
    delfunction Abc
  ]], {1, 2, 3, 0})
  ito('Varargs function', [[
    function Abc(...)
      echo a:0
      echo a:000
    endfunction
    echo Abc(1, 2, 3)
    echo Abc()
    delfunction Abc
  ]], {
    3, {1, 2, 3}, 0,
    0, {_t='list'}, 0,
  })
  ito('Normal args + varargs function', [[
    function Abc(a, b, c, ...)
      echo a:a
      echo a:b
      echo a:c
      echo a:0
      echo a:000
    endfunction
    echo Abc(1, 2, 3)
    echo Abc(1, 2, 3, 4, 5)
    delfunction Abc
  ]], {
    1, 2, 3, 0, {_t='list'}, 0,
    1, 2, 3, 2, {4, 5}, 0,
  })
end)

describe(':for loops', function()
  ito('Iterates over a list', [[
    for i in [1, 2, 3]
      echo i
    endfor
    echo i
    unlet i
  ]], {1, 2, 3, 3})
  for _, v in ipairs({{'dictionary', '{}'},
                      {'string', '""'},
                      {'number', '0'},
                      {'funcref', 'function("string")'},
                      {'float', '0.0'}}) do
    ito('Fails to iterate over a ' .. v[1], string.format([[
      try
        for i in %s
          echo i
        endfor
        echo i
      catch
        echo v:exception
      endtry
    ]], v[2]), {'Vim(for):E714: List required'})
  end
end)
