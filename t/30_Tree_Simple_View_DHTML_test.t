#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 22;

BEGIN { 
    use_ok('Tree::Simple::View::DHTML');
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

can_ok("Tree::Simple::View::DHTML", 'new');
can_ok("Tree::Simple::View::DHTML", 'expandAll');


{
    my $tree_view = Tree::Simple::View::DHTML->new($tree);
    isa_ok($tree_view, 'Tree::Simple::View::DHTML');
    
    my $output = $tree_view->expandAll();
    ok($output, '... make sure we got some output');

    my ($view_id) = ($tree_view =~ /\((.*?)\)$/);
    my $expected = <<EXPECTED;
<UL>
<LI><A HREF=# onClick='toggleList("${view_id}_1")'>1</A></LI>
<UL ID='${view_id}_1'>
<LI>1.1</LI>
<LI><A HREF=# onClick='toggleList("${view_id}_2")'>1.2</A></LI>
<UL ID='${view_id}_2'>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</UL>
<LI>1.3</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_3")'>2</A></LI>
<UL ID='${view_id}_3'>
<LI>2.1</LI>
<LI>2.2</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_4")'>3</A></LI>
<UL ID='${view_id}_4'>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_5")'>4</A></LI>
<UL ID='${view_id}_5'>
<LI>4.1</LI>
</UL></UL>
EXPECTED

    chomp $expected;
    is($output, $expected, '... got what we expected');
}


{
    my $tree_view = Tree::Simple::View::DHTML->new($tree);
    isa_ok($tree_view, 'Tree::Simple::View::DHTML');
    
    my $output = $tree_view->expandPath(qw(1 1.2));
    ok($output, '... make sure we got some output');

    my ($view_id) = ($tree_view =~ /\((.*?)\)$/);
    my $expected = <<EXPECTED;
<UL>
<LI><A HREF=# onClick='toggleList("${view_id}_1")'>1</A></LI>
<UL ID='${view_id}_1' STYLE='display: block;'>
<LI>1.1</LI>
<LI><A HREF=# onClick='toggleList("${view_id}_2")'>1.2</A></LI>
<UL ID='${view_id}_2' STYLE='display: block;'>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</UL>
<LI>1.3</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_3")'>2</A></LI>
<UL ID='${view_id}_3' STYLE='display: none;'>
<LI>2.1</LI>
<LI>2.2</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_4")'>3</A></LI>
<UL ID='${view_id}_4' STYLE='display: none;'>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_5")'>4</A></LI>
<UL ID='${view_id}_5' STYLE='display: none;'>
<LI>4.1</LI>
</UL></UL>
EXPECTED

    chomp $expected;
    is($output, $expected, '... got what we expected');
}


{
    my $tree_view = Tree::Simple::View::DHTML->new($tree, (list_type => "ordered"));
    isa_ok($tree_view, 'Tree::Simple::View::DHTML');
    
    my $output = $tree_view->expandAll();
    ok($output, '... make sure we got some output');
    
    my ($view_id) = ($tree_view =~ /\((.*?)\)$/);
    my $expected = <<EXPECTED;
<OL>
<LI><A HREF=# onClick='toggleList("${view_id}_1")'>1</A></LI>
<OL ID='${view_id}_1'>
<LI>1.1</LI>
<LI><A HREF=# onClick='toggleList("${view_id}_2")'>1.2</A></LI>
<OL ID='${view_id}_2'>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</OL>
<LI>1.3</LI>
</OL>
<LI><A HREF=# onClick='toggleList("${view_id}_3")'>2</A></LI>
<OL ID='${view_id}_3'>
<LI>2.1</LI>
<LI>2.2</LI>
</OL>
<LI><A HREF=# onClick='toggleList("${view_id}_4")'>3</A></LI>
<OL ID='${view_id}_4'>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</OL>
<LI><A HREF=# onClick='toggleList("${view_id}_5")'>4</A></LI>
<OL ID='${view_id}_5'>
<LI>4.1</LI>
</OL></OL>
EXPECTED

    chomp $expected;
    is($output, $expected, '... got what we expected');
}

{
    my $tree_view = Tree::Simple::View::DHTML->new($tree, (list_type => "ordered"));
    isa_ok($tree_view, 'Tree::Simple::View::DHTML');
    
    my $output = $tree_view->expandPath(2);
    ok($output, '... make sure we got some output');
    
    my ($view_id) = ($tree_view =~ /\((.*?)\)$/);
    my $expected = <<EXPECTED;
<OL>
<LI><A HREF=# onClick='toggleList("${view_id}_1")'>1</A></LI>
<OL STYLE='display: none;' ID='${view_id}_1'>
<LI>1.1</LI>
<LI><A HREF=# onClick='toggleList("${view_id}_2")'>1.2</A></LI>
<OL STYLE='display: none;' ID='${view_id}_2'>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</OL>
<LI>1.3</LI>
</OL>
<LI><A HREF=# onClick='toggleList("${view_id}_3")'>2</A></LI>
<OL STYLE='display: block;' ID='${view_id}_3'>
<LI>2.1</LI>
<LI>2.2</LI>
</OL>
<LI><A HREF=# onClick='toggleList("${view_id}_4")'>3</A></LI>
<OL STYLE='display: none;' ID='${view_id}_4'>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</OL>
<LI><A HREF=# onClick='toggleList("${view_id}_5")'>4</A></LI>
<OL STYLE='display: none;' ID='${view_id}_5'>
<LI>4.1</LI>
</OL></OL>
EXPECTED

    chomp $expected;
    is($output, $expected, '... got what we expected');
}

{
    my $tree_view = Tree::Simple::View::DHTML->new($tree, 
                                list_type => "unordered",
                                list_css => "list-style: circle;",
                                );
    isa_ok($tree_view, 'Tree::Simple::View::DHTML');
    
    my $output = $tree_view->expandAll();
    ok($output, '... make sure we got some output');
    
    my ($view_id) = ($tree_view =~ /\((.*?)\)$/);    
    my $expected = <<EXPECTED;
<UL STYLE='list-style: circle;'>
<LI><A HREF=# onClick='toggleList("${view_id}_1")'>1</A></LI>
<UL STYLE='list-style: circle;' ID='${view_id}_1'>
<LI>1.1</LI>
<LI><A HREF=# onClick='toggleList("${view_id}_2")'>1.2</A></LI>
<UL STYLE='list-style: circle;' ID='${view_id}_2'>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</UL>
<LI>1.3</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_3")'>2</A></LI>
<UL STYLE='list-style: circle;' ID='${view_id}_3'>
<LI>2.1</LI>
<LI>2.2</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_4")'>3</A></LI>
<UL STYLE='list-style: circle;' ID='${view_id}_4'>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_5")'>4</A></LI>
<UL STYLE='list-style: circle;' ID='${view_id}_5'>
<LI>4.1</LI>
</UL></UL>
EXPECTED

    chomp $expected;
    
    is($output, $expected, '... got what we expected');
}

{
    my $tree_view = Tree::Simple::View::DHTML->new($tree, 
                                list_type => "unordered",
                                list_css => "list-style: circle;",
                                );
    isa_ok($tree_view, 'Tree::Simple::View::DHTML');
    
    my $output = $tree_view->expandPath(qw(1 1.2));
    ok($output, '... make sure we got some output');
    
    my ($view_id) = ($tree_view =~ /\((.*?)\)$/);    
    my $expected = <<EXPECTED;
<UL STYLE='list-style: circle;'>
<LI><A HREF=# onClick='toggleList("${view_id}_1")'>1</A></LI>
<UL STYLE='list-style: circle; display: block;' ID='${view_id}_1'>
<LI>1.1</LI>
<LI><A HREF=# onClick='toggleList("${view_id}_2")'>1.2</A></LI>
<UL STYLE='list-style: circle; display: block;' ID='${view_id}_2'>
<LI>1.2.1</LI>
<LI>1.2.2</LI>
</UL>
<LI>1.3</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_3")'>2</A></LI>
<UL STYLE='list-style: circle; display: none;' ID='${view_id}_3'>
<LI>2.1</LI>
<LI>2.2</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_4")'>3</A></LI>
<UL STYLE='list-style: circle; display: none;' ID='${view_id}_4'>
<LI>3.1</LI>
<LI>3.2</LI>
<LI>3.3</LI>
</UL>
<LI><A HREF=# onClick='toggleList("${view_id}_5")'>4</A></LI>
<UL STYLE='list-style: circle; display: none;' ID='${view_id}_5'>
<LI>4.1</LI>
</UL></UL>
EXPECTED

    chomp $expected;
    
    is($output, $expected, '... got what we expected');
}

