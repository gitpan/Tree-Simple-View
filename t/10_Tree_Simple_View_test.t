#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 29;
use Test::Exception;

BEGIN { 
    use_ok('Tree::Simple::View');
}

use Tree::Simple;

# make a tree
my $tree = Tree::Simple->new(Tree::Simple->ROOT);
isa_ok($tree, 'Tree::Simple');

# make a configuration
my %config = ( test => "test" );

# create my tree view (base class so it will die alot)
can_ok("Tree::Simple::View", 'new');
my $tree_view = Tree::Simple::View->new($tree, %config);
isa_ok($tree_view, 'Tree::Simple::View');

# check the exceptions thrown in the constructor/initializer
throws_ok {
    Tree::Simple::View->new()
} qr/Insufficient Arguments/, '... this should die from bad input';

throws_ok {
    Tree::Simple::View->new("Fail")
} qr/Insufficient Arguments/, '... this should die from bad input';

throws_ok {
    Tree::Simple::View->new([])
} qr/Insufficient Arguments/, '... this should die from bad input';

throws_ok {
    Tree::Simple::View->new(bless({}, "Fail"))
} qr/Insufficient Arguments/, '... this should die from bad input';

# test my accessors

can_ok($tree_view, 'getTree');
is($tree_view->getTree(), $tree, '... our tree is the same');

can_ok($tree_view, 'getConfig');
is_deeply($tree_view->getConfig(), \%config, '... our configs are the same');

can_ok($tree_view, 'setPathComparisonFunction');

throws_ok {
    $tree_view->setPathComparisonFunction()
} qr/Insufficient Arguments/, '... this should die from bad input';

# test the expandAll

can_ok($tree_view, 'expandAll');
throws_ok {
    $tree_view->expandAll();
} qr/Method Not Implemented/, '... this should die because it calls an abstract method';

# test the *Simple and *Complex versions of it

can_ok($tree_view, 'expandAllSimple');
throws_ok {
    $tree_view->expandAllSimple();
} qr/Method Not Implemented/, '... this should die because it calls an abstract method';

can_ok($tree_view, 'expandAllComplex');
throws_ok {
    $tree_view->expandAllComplex();
} qr/Method Not Implemented/, '... this should die because it calls an abstract method';

# test expandPath

can_ok($tree_view, 'expandPath');
throws_ok {
    $tree_view->expandPath();
} qr/Method Not Implemented/, '... this should die because it calls an abstract method';

# test the *Simple and *Complex versions of it

can_ok($tree_view, 'expandPathSimple');
throws_ok {
    $tree_view->expandPathSimple();
} qr/Method Not Implemented/, '... this should die because it calls an abstract method';

can_ok($tree_view, 'expandPathComplex');
throws_ok {
    $tree_view->expandPathComplex();
} qr/Method Not Implemented/, '... this should die because it calls an abstract method';

# now we need to check that expandPath and expandAll 
# work as expected without a configuration present

my $tree_view2 = Tree::Simple::View->new($tree);
isa_ok($tree_view2, 'Tree::Simple::View');

throws_ok {
    $tree_view2->expandPath();
} qr/Method Not Implemented/, '... this should die because it calls an abstract method';

throws_ok {
    $tree_view2->expandAll();
} qr/Method Not Implemented/, '... this should die because it calls an abstract method';



