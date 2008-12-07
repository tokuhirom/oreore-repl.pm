use inc::Module::Install;
name 'OreOre-Tokuhirom-REPL';
all_from 'lib/OreOre/Tokuhirom/REPL.pm';

requires 'Class::Component';
requires 'FindBin::libs';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'YAML';
author_tests 'xt';
use_test_base;
auto_include;
WriteAll;
