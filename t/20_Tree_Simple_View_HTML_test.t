#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 22;

BEGIN { 
    use_ok('Tree::Simple::View::HTML');
}

use Tree::Simple;
my $tree = Tree::Simple->new(Tree::Simple->ROOT)
                       ->addChildren(
                            Tree::Simple->new("1")
                                        ->addChildren(
                                            Tree::Simple->new("1.1"),
                                            Tree::Simple->new("1.2")
                                                        ->addChildren(
                                                            Tree::Simple->new("1.2.1"),
                                                            Tree::Simple->new("1.2.2")
                                                        ),
                                            Tree::Simple->new("1.3")                                                                                                
                                        ),
                            Tree::Simple->new("2")
                                        ->addChildren(
                                            Tree::Simple->new("2.1"),
                                            Tree::Simple->new("2.2")
                                        ),                            
                            Tree::Simple->new("3")
                                        ->addChildren(
                                            Tree::Simple->new("3.1"),
                                            Tree::Simple->new("3.2"),
                                            Tree::Simple->new("3.3")                                                                                                
                                        ),                            
                            Tree::Simple->new("4")                                                        
                                        ->addChildren(
                                            Tree::Simple->new("4.1")
                                        )                            
                       );
isa_ok($tree, 'Tree::Simple');

can_ok("Tree::Simple::View::HTML", 'new');
can_ok("Tree::Simple::View::HTML", 'expandAll');

{
    my $tree_view = Tree::Simple::View::HTML->new($tree);
    isa_ok($tree_view, 'Tree::Simple::View::HTML');
    
    my $output = $tree_view->expandAll();
    ok($output, '... make sure we got some output');
    
    my $expected = <<EXPECTED;
<UL>
<LI>1</LI>
<UL>
<LI>1.1</LI>
<LI>1.2</LI>
<UL>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</UL>
<LI>1.3</LI>
</UL>
<LI>2</LI>
<UL>
<LI>2.1</LI>
<LI>2.2</LI>
</UL>
<LI>3</LI>
<UL>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</UL>
<LI>4</LI>
<UL>
<LI>4.1</LI>
</UL></UL>
EXPECTED
    chomp $expected;
    
    is($output, $expected, '... got what we expected');
}

{
    my $tree_view = Tree::Simple::View::HTML->new($tree);
    isa_ok($tree_view, 'Tree::Simple::View::HTML');
    
    my $output = $tree_view->expandPath(qw(1 1.2));
    ok($output, '... make sure we got some output');
    
    my $expected = <<EXPECTED;
<UL>
<LI>1</LI>
<UL>
<LI>1.1</LI>
<LI>1.2</LI>
<UL>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</UL>
<LI>1.3</LI>
</UL>
<LI>2</LI>
<LI>3</LI>
<LI>4</LI>
</UL>
EXPECTED
    chomp $expected;
    
    is($output, $expected, '... got what we expected');
}


{
    my $tree_view = Tree::Simple::View::HTML->new($tree, (list_type => "ordered"));
    isa_ok($tree_view, 'Tree::Simple::View::HTML');
    
    my $output = $tree_view->expandAll();
    ok($output, '... make sure we got some output');
    
    my $expected = <<EXPECTED;
<OL>
<LI>1</LI>
<OL>
<LI>1.1</LI>
<LI>1.2</LI>
<OL>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</OL>
<LI>1.3</LI>
</OL>
<LI>2</LI>
<OL>
<LI>2.1</LI>
<LI>2.2</LI>
</OL>
<LI>3</LI>
<OL>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</OL>
<LI>4</LI>
<OL>
<LI>4.1</LI>
</OL></OL>
EXPECTED
    chomp $expected;
    
    is($output, $expected, '... got what we expected');
}

{
    my $tree_view = Tree::Simple::View::HTML->new($tree, (list_type => "ordered"));
    isa_ok($tree_view, 'Tree::Simple::View::HTML');
    
    my $output = $tree_view->expandPath(3);
    ok($output, '... make sure we got some output');
    
    my $expected = <<EXPECTED;
<OL>
<LI>1</LI>
<LI>2</LI>
<LI>3</LI>
<OL>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</OL>
<LI>4</LI>
</OL>
EXPECTED
    chomp $expected;
    
    is($output, $expected, '... got what we expected');
}

{
    my $tree_view = Tree::Simple::View::HTML->new($tree, 
                                list_type => "unordered",
                                list_css => "list-style: circle;",
                                );
    isa_ok($tree_view, 'Tree::Simple::View::HTML');
    
    my $output = $tree_view->expandAll();
    ok($output, '... make sure we got some output');
    
    my $expected = <<EXPECTED;
<UL STYLE='list-style: circle;'>
<LI>1</LI>
<UL STYLE='list-style: circle;'>
<LI>1.1</LI>
<LI>1.2</LI>
<UL STYLE='list-style: circle;'>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</UL>
<LI>1.3</LI>
</UL>
<LI>2</LI>
<UL STYLE='list-style: circle;'>
<LI>2.1</LI>
<LI>2.2</LI>
</UL>
<LI>3</LI>
<UL STYLE='list-style: circle;'>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</UL>
<LI>4</LI>
<UL STYLE='list-style: circle;'>
<LI>4.1</LI>
</UL></UL>
EXPECTED
    chomp $expected;
    
    is($output, $expected, '... got what we expected');
}

{
    my $tree_view = Tree::Simple::View::HTML->new($tree, 
                                list_type => "unordered",
                                list_css => "list-style: circle;",
                                );
    isa_ok($tree_view, 'Tree::Simple::View::HTML');
    
    my $output = $tree_view->expandPath(2);
    ok($output, '... make sure we got some output');
    
    my $expected = <<EXPECTED;
<UL STYLE='list-style: circle;'>
<LI>1</LI>
<LI>2</LI>
<UL STYLE='list-style: circle;'>
<LI>2.1</LI>
<LI>2.2</LI>
</UL>
<LI>3</LI>
<LI>4</LI>
</UL>
EXPECTED
    chomp $expected;
    
    is($output, $expected, '... got what we expected');
}

