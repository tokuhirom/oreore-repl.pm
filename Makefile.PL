use inc::Module::Install;
name 'OreOre-REPL';
all_from 'lib/OreOre/REPL.pm';

requires 'Class::Component' => 0.17;
requires 'FindBin::libs';
requires 'Class::Accessor::Lite';
requires 'Lexical::Persistence';
requires 'UNIVERSAL::require' => 0.11;

install_script 'oreore-repl.pl';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'YAML';
author_tests 'xt';
use_test_base;
auto_include;
WriteAll;
