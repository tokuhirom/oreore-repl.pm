use inc::Module::Install;
name 'OreOre-REPL';
all_from 'lib/OreOre/REPL.pm';

requires 'Lexical::Persistence';
requires 'UNIVERSAL::require' => 0.11;
requires 'Module::Reload';

install_script 'oreore-repl.pl';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'YAML';
author_tests 'xt';
use_test_base;
auto_include;
WriteAll;
