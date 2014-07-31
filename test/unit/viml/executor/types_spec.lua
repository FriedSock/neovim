-- This file contains tests for value creation and various kinds of 
-- subscripting. Need a better name I guess.

local ito, itoe, f
do
  local _obj_0 = require('test.unit.viml.executor.helpers')
  ito = _obj_0.ito
  itoe = _obj_0.itoe
  f = _obj_0.f
end

describe('Dictionaries', function()
  ito('Generates dictionaries', [[
    echo string({})
    echo string({'a': 1})
    echo string({"A": 2})
    echo string({1 : 2})
    echo string({1:2})
    echo string({1:{1:{1:2}}})
  ]], {
    '{}',
    '{\'a\': 1}',
    '{\'A\': 2}',
    '{\'1\': 2}',
    '{\'1\': 2}',
    '{\'1\': {\'1\': {\'1\': 2}}}',
  })
  ito('Accepts dictionary subscripts', [[
    echo {'a': 1}['a']
    echo {'a': 2}.a
    echo {0x10 : 3}[16]
    echo {0x10 : 4}[0x10]
    echo {0x10 : 5}['16']
  ]], {
    1, 2, 3, 4, 5,
  })
  itoe('Raises an error when trying to check missing key', {
    'echo {}[\'a\']',
    'echo {}.a',
    'echo {"0x10": 1}.16',
    'echo {"0x10": 1}[0x10]',
    'echo {"0x10": 1}["16"]',
  }, {
    'Vim(echo):E716: Key not present in Dictionary: a',
    'Vim(echo):E716: Key not present in Dictionary: a',
    'Vim(echo):E716: Key not present in Dictionary: 16',
    'Vim(echo):E716: Key not present in Dictionary: 16',
    'Vim(echo):E716: Key not present in Dictionary: 16',
  })
  itoe('Raises an error when trying to slice dictionary', {
    'echo {}[:]',
    'echo {}[0:]',
    'echo {}[:0]',
    'echo {}[0:0]',
  }, {
    'Vim(echo):E719: Cannot use [:] with a Dictionary',
    'Vim(echo):E719: Cannot use [:] with a Dictionary',
    'Vim(echo):E719: Cannot use [:] with a Dictionary',
    'Vim(echo):E719: Cannot use [:] with a Dictionary',
  })
end)

describe('Lists', function()
  ito('Generates lists', [[
    echo string([])
    echo string([ [ [ ] ] ])
    echo string([1, 2])
  ]], {
    '[]',
    '[[[]]]',
    '[1, 2]',
  })
  ito('Accepts list subscripts', [[
    echo [1][0]
    echo [2, 3][1]
    echo [4, 5]['0x0']
    echo [6, 7]['0x1']
  ]], {1, 3, 4, 7})
  ito('Accepts empty slices', [[
    echo [][:]
    echo [1][:]
    echo [2, 3][:]
  ]], {
    {_t='list'}, {1}, {2, 3},
  })
  ito('Accepts slices only with start', [[
    echo [4, 5, 6][1:]
    echo [7, 8, 9][-1:]
    echo [10, 11, 12][-4:]
    echo [13, 14, 15][3:]
  ]], {
    {5, 6}, {9}, {_t='list'}, {_t='list'},
  })
  ito('Accepts slices only with end', [[
    echo [16, 17, 18][:0]
    echo [19, 20, 21][:1]
    echo [22, 23, 24][:-1]
    echo [25, 26, 27][:3]
    echo [28, 29, 30][:100]
    echo [31, 32, 33][:-4]
    echo [34, 35, 36][:-100]
  ]], {
    {16}, {19, 20}, {22, 23, 24}, {25, 26, 27}, {28, 29, 30},
    {_t='list'}, {_t='list'},
  })
  ito('Accepts slices with both ends', [[
    echo [16, 17, 18][0:0]
    echo [19, 20, 21][0:1]
    echo [22, 23, 24][0:-1]
    echo [25, 26, 27][0:3]
    echo [28, 29, 30][0:100]

    echo [31, 32, 33][0:-4]
    echo [34, 35, 36][0:-100]

    echo [4, 5, 6][1:-1]
    echo [7, 8, 9][-1:-1]
    echo [10, 11, 12][-4:-1]
    echo [13, 14, 15][3:-1]

    echo [4, 5, 6][1:100]
    echo [7, 8, 9][-1:100]
    echo [10, 11, 12][-4:100]
    echo [13, 14, 15][3:100]

    echo [1, 2, 3][1:0]
    echo [1, 2, 3][-2:1]
    echo [1, 2, 3][-2:0]
  ]], {
    {16}, {19, 20}, {22, 23, 24}, {25, 26, 27}, {28, 29, 30},
    {_t='list'}, {_t='list'},
    {5, 6}, {9}, {_t='list'}, {_t='list'},
    {5, 6}, {9}, {_t='list'}, {_t='list'},
    {_t='list'}, {2}, {_t='list'},
  })
  ito('Accepts strings in slices', [[
    echo [1, 2, 3]['-1':]
    echo [1, 2, 3]['-0x0':]

    echo [1, 2, 3][:'-1']
    echo [1, 2, 3][:'0x0']

    echo [1, 2, 3]['1':'-1']
    echo [1, 2, 3]['0x1':'0x2']
  ]], {
    {3}, {1, 2, 3},
    {1, 2, 3}, {1},
    {2, 3}, {2, 3},
  })
end)

-- TODO string, number, float and funcref tests
