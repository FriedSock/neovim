local cimport, internalize, eq, ffi, lib, cstr, to_cstr, vim_init
do
  local _obj_0 = require('test.unit.helpers')
  cimport, internalize, eq, ffi, lib, cstr, to_cstr, vim_init = _obj_0.cimport, _obj_0.internalize, _obj_0.eq, _obj_0.ffi, _obj_0.lib, _obj_0.cstr, _obj_0.to_cstr, _obj_0.vim_init
  vim_init = _obj_0.vim_init
end
vim_init()
local libnvim = cimport('./src/nvim/viml/testhelpers/parser.h')
local p0
p0 = function(str)
  local s = to_cstr(str)
  local parsed = libnvim.srepresent_parse0(s, false)
  if parsed == nil then
    error('srepresent_parse0 returned nil')
  end
  return ffi.string(parsed)
end
local eqn
eqn = function(expected_result, expr, expected_offset)
  if expected_offset == nil then
    expected_offset = nil
  end
  if not expected_offset then
    expected_offset = expr:len()
  end
  local result = p0(expr)
  expected_result = string.format('%X:%s', expected_offset, expected_result)
  return eq(expected_result, result)
end
describe('parse0', function()
  it('parses number 0', function()
    return eqn('N[+0+]', '0')
  end)
  it('parses number 10', function()
    return eqn('N[+10+]', '10')
  end)
  it('parses number 110', function()
    return eqn('N[+110+]', '110')
  end)
  it('parses number 01900', function()
    return eqn('N[+01900+]', '01900')
  end)
  it('parses octal number 010', function()
    return eqn('O[+010+]', '010')
  end)
  it('parses octal number 0000015', function()
    return eqn('O[+0000015+]', '0000015')
  end)
  it('parses negative octal number -0000015', function()
    return eqn('-!(O[+0000015+])', '-0000015')
  end)
  it('parses hex number 0x1C', function()
    return eqn('X[+0x1C+]', '0x1C')
  end)
  it('parses hex number 0X1C', function()
    return eqn('X[+0X1C+]', '0X1C')
  end)
  it('parses hex number 0X1c', function()
    return eqn('X[+0X1c+]', '0X1c')
  end)
  it('parses hex number 0x1c', function()
    return eqn('X[+0x1c+]', '0x1c')
  end)
  it('parses float 0.0', function()
    return eqn('F[+0.0+]', '0.0')
  end)
  it('parses float 0.0e0', function()
    return eqn('F[+0.0e0+]', '0.0e0')
  end)
  it('parses float 0.1e+1', function()
    return eqn('F[+0.1e+1+]', '0.1e+1')
  end)
  it('parses float 0.1e-1', function()
    return eqn('F[+0.1e-1+]', '0.1e-1')
  end)
  it('parses "abc"', function()
    return eqn('"[+"abc"+]', '"abc"')
  end)
  it('parses "a\\"bc"', function()
    return eqn('"[+"a\\"bc"+]', '"a\\"bc"')
  end)
  it('parses \'abc\'', function()
    return eqn('\'[+\'abc\'+]', '\'abc\'')
  end)
  it('parses \'ab\'\'c\'', function()
    return eqn('\'[+\'ab\'\'c\'+]', '\'ab\'\'c\'')
  end)
  it('parses \'ab\'\'\'', function()
    return eqn('\'[+\'ab\'\'\'+]', '\'ab\'\'\'')
  end)
  it('parses \'\'\'c\'', function()
    return eqn('\'[+\'\'\'c\'+]', '\'\'\'c\'')
  end)
  it('parses option', function()
    return eqn('&[+abc+]', '&abc')
  end)
  it('parses local option', function()
    return eqn('&[+l:abc+]', '&l:abc')
  end)
  it('parses global option', function()
    return eqn('&[+g:abc+]', '&g:abc')
  end)
  it('parses register r', function()
    return eqn('@[+@r+]', '@r')
  end)
  it('parses register NUL', function()
    return eqn('@[+@+]', '@')
  end)
  it('parses environment variable', function()
    return eqn('$[+abc+]', '$abc')
  end)
  it('parses varname', function()
    return eqn('var[+varname+]', 'varname')
  end)
  it('parses g:varname', function()
    return eqn('var[+g:varname+]', 'g:varname')
  end)
  it('parses abc:func', function()
    return eqn('var[+abc:func+]', 'abc:func')
  end)
  it('parses s:v', function()
    return eqn('var[+s:v+]', 's:v')
  end)
  it('parses s:', function()
    return eqn('var[+s:+]', 's:')
  end)
  it('parses <SID>v', function()
    return eqn('var[+<SID>v+]', '<SID>v')
  end)
  it('parses abc#def', function()
    return eqn('var[+abc#def+]', 'abc#def')
  end)
  it('parses g:abc#def', function()
    return eqn('var[+g:abc#def+]', 'g:abc#def')
  end)
  it('parses <SNR>12_v', function()
    return eqn('var[+<SNR>12_v+]', '<SNR>12_v')
  end)
  it('parses curly braces name: v{a}', function()
    return eqn('cvar(id[+v+], curly[!{!](var[+a+]))', 'v{a}')
  end)
  it('parses curly braces name: {a}', function()
    return eqn('cvar(curly[!{!](var[+a+]))', '{a}')
  end)
  it('parses curly braces name: {a}b', function()
    return eqn('cvar(curly[!{!](var[+a+]), id[+b+])', '{a}b')
  end)
  it('parses curly braces name: x{a}b', function()
    return eqn('cvar(id[+x+], curly[!{!](var[+a+]), id[+b+])', 'x{a}b')
  end)
  it('parses curly braces name: x{a}1', function()
    return eqn('cvar(id[+x+], curly[!{!](var[+a+]), id[+1+])', 'x{a}1')
  end)
  it('parses abc.key', function()
    return eqn('.[+key+](var[+abc+])', 'abc.key')
  end)
  it('parses abc.key.2', function()
    return eqn('.[+2+](.[+key+](var[+abc+]))', 'abc.key.2')
  end)
  it('parses abc.g:v', function()
    return eqn('..(var[+abc+], var[+g:v+])', 'abc.g:v')
  end)
  it('parses abc.autoload#var', function()
    return eqn('..(var[+abc+], var[+autoload#var+])', 'abc.autoload#var')
  end)
  it('parses 1.2.3.4', function()
    return eqn('..(N[+1+], N[+2+], N[+3+], N[+4+])', '1.2.3.4')
  end)
  it('parses "abc".def', function()
    return eqn('..("[+"abc"+], var[+def+])', '"abc".def')
  end)
  it('parses 1 . 2 . 3 . 4', function()
    return eqn('..(N[+1+], N[+2+], N[+3+], N[+4+])', '1 . 2 . 3 . 4')
  end)
  it('parses 1. 2. 3. 4', function()
    return eqn('..(N[+1+], N[+2+], N[+3+], N[+4+])', '1. 2. 3. 4')
  end)
  it('parses 1 .2 .3 .4', function()
    return eqn('..(N[+1+], N[+2+], N[+3+], N[+4+])', '1 .2 .3 .4')
  end)
  it('parses a && b && c', function()
    return eqn('&&(var[+a+], var[+b+], var[+c+])', 'a && b && c')
  end)
  it('parses a || b || c', function()
    return eqn('||(var[+a+], var[+b+], var[+c+])', 'a || b || c')
  end)
  it('parses a || b && c || d', function()
    return eqn('||(var[+a+], &&(var[+b+], var[+c+]), var[+d+])', 'a || b && c || d')
  end)
  it('parses a && b || c && d', function()
    return eqn('||(&&(var[+a+], var[+b+]), &&(var[+c+], var[+d+]))', 'a && b || c && d')
  end)
  it('parses a && (b || c) && d', function()
    return eqn('&&(var[+a+], expr[!(!](||(var[+b+], var[+c+])), var[+d+])', 'a && (b || c) && d')
  end)
  it('parses a + b + c*d/e/f  - g % h .i', function()
    local str = '..(-(+(var[+a+], '
    str = str .. 'var[+b+], '
    str = str .. '/(*(var[+c+], '
    str = str .. 'var[+d+]), '
    str = str .. 'var[+e+], '
    str = str .. 'var[+f+])), '
    str = str .. '%(var[+g+], var[+h+])), '
    str = str .. 'var[+i+])'
    return eqn(str, 'a + b + c*d/e/f  - g % h .i')
  end)
  it('parses !+-!!++a', function()
    return eqn('!(+!(-!(!(!(+!(+!(var[+a+])))))))', '!+-!!++a')
  end)
  it('parses (abc)', function()
    return eqn('expr[!(!](var[+abc+])', '(abc)')
  end)
  it('parses [1, 2 , 3 ,4]', function()
    return eqn('[][![!](N[+1+], N[+2+], N[+3+], N[+4+])', '[1, 2 , 3 ,4]')
  end)
  it('parses {1:2, v : c, (10): abc}', function()
    local str = '{}[!{!](N[+1+], N[+2+], '
    str = str .. 'var[+v+], var[+c+], '
    str = str .. 'expr[!(!](N[+10+]), var[+abc+])'
    return eqn(str, '{1:2, v : c, (10): abc}')
  end)
  it('parses 1 == 2 && 3 != 4 && 5 > 6 && 7 < 8', function()
    local str = '&&(==(N[+1+], N[+2+]), !=(N[+3+], N[+4+]), >(N[+5+], N[+6+]), '
    str = str .. '<(N[+7+], N[+8+]))'
    return eqn(str, '1 == 2 && 3 != 4 && 5 > 6 && 7 < 8')
  end)
  it('parses "" ># "a" || "" <? "b" || "" is "c"', function()
    local str = '||(>#("[+""+], "[+"a"+]), <?("[+""+], "[+"b"+]), '
    str = str .. 'is("[+""+], "[+"c"+]))'
    return eqn(str, '"" ># "a" || "" <? "b" || "" is "c"')
  end)
  it('parses 1== 2 &&  1 ==#2 && 1==?2', function()
    return eqn(('&&(==(N[+1+], N[+2+]), ==#(N[+1+], N[+2+]), ==?(N[+1+], N[+2+]))'), '1== 2 &&  1 ==#2 && 1==?2')
  end)
  it('parses 1!= 2 &&  1 !=#2 && 1!=?2', function()
    return eqn(('&&(!=(N[+1+], N[+2+]), !=#(N[+1+], N[+2+]), !=?(N[+1+], N[+2+]))'), '1!= 2 &&  1 !=#2 && 1!=?2')
  end)
  it('parses 1> 2 &&  1 >#2 && 1>?2', function()
    return eqn(('&&(>(N[+1+], N[+2+]), >#(N[+1+], N[+2+]), >?(N[+1+], N[+2+]))'), '1> 2 &&  1 >#2 && 1>?2')
  end)
  it('parses 1< 2 &&  1 <#2 && 1<?2', function()
    return eqn(('&&(<(N[+1+], N[+2+]), <#(N[+1+], N[+2+]), <?(N[+1+], N[+2+]))'), '1< 2 &&  1 <#2 && 1<?2')
  end)
  it('parses 1<= 2 &&  1 <=#2 && 1<=?2', function()
    return eqn(('&&(<=(N[+1+], N[+2+]), <=#(N[+1+], N[+2+]), <=?(N[+1+], N[+2+]))'), '1<= 2 &&  1 <=#2 && 1<=?2')
  end)
  it('parses 1>= 2 &&  1 >=#2 && 1>=?2', function()
    return eqn(('&&(>=(N[+1+], N[+2+]), >=#(N[+1+], N[+2+]), >=?(N[+1+], N[+2+]))'), '1>= 2 &&  1 >=#2 && 1>=?2')
  end)
  it('parses 1is 2 &&  1 is#2 && 1is?2', function()
    return eqn(('&&(is(N[+1+], N[+2+]), is#(N[+1+], N[+2+]), is?(N[+1+], N[+2+]))'), '1is 2 &&  1 is#2 && 1is?2')
  end)
  it('parses 1isnot 2 &&  1 isnot#2 && 1isnot?2', function()
    local str = '&&(isnot(N[+1+], N[+2+]), isnot#(N[+1+], N[+2+]), '
    str = str .. 'isnot?(N[+1+], N[+2+]))'
    return eqn(str, '1isnot 2 &&  1 isnot#2 && 1isnot?2')
  end)
  it('parses 1=~ 2 &&  1 =~#2 && 1=~?2', function()
    return eqn(('&&(=~(N[+1+], N[+2+]), =~#(N[+1+], N[+2+]), =~?(N[+1+], N[+2+]))'), '1=~ 2 &&  1 =~#2 && 1=~?2')
  end)
  it('parses 1!~ 2 &&  1 !~#2 && 1!~?2', function()
    return eqn(('&&(!~(N[+1+], N[+2+]), !~#(N[+1+], N[+2+]), !~?(N[+1+], N[+2+]))'), '1!~ 2 &&  1 !~#2 && 1!~?2')
  end)
  it('parses call(1, 2, 3, 4, 5)', function()
    return eqn(('call(var[+call+], N[+1+], N[+2+], N[+3+], N[+4+], N[+5+])'), 'call(1, 2, 3, 4, 5)')
  end)
  it('parses (1)(2)', function()
    return eqn('call(expr[!(!](N[+1+]), N[+2+])', '(1)(2)')
  end)
  it('parses [][1]', function()
    return eqn('index([][![!], N[+1+])', '[][1]')
  end)
  it('parses [][1:]', function()
    return eqn('index([][![!], N[+1+], empty[!]!])', '[][1:]')
  end)
  it('parses [][:1]', function()
    return eqn('index([][![!], empty[!:!], N[+1+])', '[][:1]')
  end)
  it('parses [][:]', function()
    return eqn('index([][![!], empty[!:!], empty[!]!])', '[][:]')
  end)
  it('parses [][i1 : i2]', function()
    return eqn('index([][![!], var[+i1+], var[+i2+])', '[][i1 : i2]')
  end)
  it('partially parses (abc)(def) (ghi)', function()
    return eqn('call(expr[!(!](var[+abc+]), var[+def+])', '(abc)(def) (ghi)', 11)
  end)
  it('fully parses tr>--(1, 2, 3)', function()
    return eqn('call(var[+tr+], N[+1+], N[+2+], N[+3+])', 'tr\t(1, 2, 3)')
  end)
  it('parses s:pls[plid].runtimepath is# pltrp', function()
    return eqn('is#(.[+runtimepath+](index(var[+s:pls+], var[+plid+])), var[+pltrp+])', 's:pls[plid].runtimepath is# pltrp')
  end)
  return it('parses abc[def] is# 123', function()
    return eqn('is#(index(var[+abc+], var[+def+]), N[+123+])', 'abc[def] is# 123')
  end)
end)
return describe('parse0, failures', function()
  it('fails to parse [1;2]', function()
    return eqn('error:E696: Missing comma in List', '[1;2]', 2)
  end)
  return it('fails to parse <', function()
    return eqn('error:E15: expected expr7 (value)', '<', 0)
  end)
end)