#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;

BEGIN { 
    use_ok('Tree::Simple::View');
}

use Tree::Simple;
my $tree = Tree::Simple->new(Tree::Simple->ROOT);
isa_ok($tree, 'Tree::Simple');

can_ok("Tree::Simple::View", 'new');

my $tree_view = Tree::Simple::View->new($tree);
isa_ok($tree_view, 'Tree::Simple::View::HTML');

Tree::Simple::View->import("DHTML");

my $dhtml_tree_view = Tree::Simple::View->new($tree);
isa_ok($dhtml_tree_view, 'Tree::Simple::View::DHTML');
