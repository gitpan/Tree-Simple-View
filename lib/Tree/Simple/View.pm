
package Tree::Simple::View;

use strict;
use warnings;

our $VERSION = '0.11';

use Scalar::Util qw(blessed);

sub new {
    my ($_class, $tree, %configuration) = @_;
    my $class = ref($_class) || $_class;
    my $tree_view = {
        tree => undef,
        config => {}
        };
    bless($tree_view, $class);
    $tree_view->_init($tree, %configuration);
    return $tree_view;
}

sub _init {
    my ($self, $tree, %config) = @_;
    (blessed($tree) && $tree->isa("Tree::Simple"))
        || die "Insufficient Arguments : tree argument must be a Tree::Simple object";
    $self->{tree} = $tree;
    $self->{config} = \%config if %config;
    $self->{include_trunk} = 0; 
    $self->{path_comparison_func} = undef;
}

sub getTree {
    my ($self) = @_;
    return $self->{tree};
}

sub getConfig {
    my ($self) = @_;
    return $self->{config};
}

sub includeTrunk {
    my ($self, $boolean) = @_;
    $self->{include_trunk} = ($boolean ? 1 : 0) if defined $boolean;
    return $self->{include_trunk};
}

sub setPathComparisonFunction {
    my ($self, $code) = @_;
    (defined($code) && ref($code) eq "CODE") 
        || die "Insufficient Arguments : Path comparison must be a function"; 
    $self->{path_comparison_func} = $code;
}

sub expandPath {
    my ($self, @path) = @_;
    return $self->expandPathComplex($self->{tree}, $self->{config}, @path) if (keys %{$self->{config}});
    return $self->expandPathSimple($self->{tree}, @path);    
}

# override these method
sub expandPathSimple  { die "Method Not Implemented" }
sub expandPathComplex { die "Method Not Implemented" }

sub expandAll {
    my ($self) = @_;
    return $self->expandAllComplex($self->{config}) if (keys %{$self->{config}});
    return $self->expandAllSimple();    
}

# override these method
sub expandAllSimple  { die "Method Not Implemented" }
sub expandAllComplex { die "Method Not Implemented" }

## private methods

sub _compareNodeToPath {
    my ($self, $current_path, $current_tree) = @_;
    # default to normal node-path comparison ...
    return $current_path eq $current_tree->getNodeValue() 
        unless defined $self->{path_comparison_func};
    # unless we have a path_comparison_func in place
    # in which case we use that
    return $self->{path_comparison_func}->($current_path, $current_tree);    
}

1;

__END__

=head1 NAME

Tree::Simple::View - A set of classes for viewing Tree::Simple hierarchies

=head1 SYNOPSIS

  # create a custom Tree View class
  package MyCustomTreeView;
  
  use strict;
  use warnings; 
  
  # inherit from this class
  our @ISA = qw(Tree::Simple::View);
  
  # define (at a minimum) these methods
  sub expandPathSimple { ... }
  sub expandPathComplex { ... }
  
  sub expandAllSimple { ... }
  sub expandAllComplex { ... }    
  
  1;

=head1 DESCRIPTION

This serves as an abstract base class to the Tree::Simple::View::* classes. There are two implementing classes included here; Tree::Simple::View::HTML and Tree::Simple::View::DHTML. Other Tree::Simple::View::* classes are also being planned, see the L<TO DO> section for more information.

These modules are pretty close to being complete at this point. The API is stable and should not change, although some more configuration options may get added, none will be deleted. We are currently using the Tree::Simple::DHTML module on a project which will soon go through QA and into production, which will help us find lingering any bugs and/or browser issues. The plan is to release this as 1.0 once we move this site into production.

I have run some I<rough> benchmarks on my Powerbook (500 mHz G4 w/ 512MB of RAM) running OS X (10.3.4). I used a 1200+ node Tree::Simple hierarchy and tested it with range of configuration options. For simple (no configuration) rendering it was able to render approx. 15 times a second. For more complex renderings (with a configuration), it was able to render approx. 10 times a second. Interestingly enough, no matter home complex the configuration, the render time remained pretty much constant. I expect these numbers would be much higher if I had run them our webserver (usually Linux running on P3 or P4 and min. 1 GB of RAM), and I will include more thorough benchmark stats in the 1.0 release documentation. 

=head1 METHODS

=over 4

=item B<new ($tree, %configuration)>

Accepts a C<$tree> argument of a Tree::Simple object (or one derived from Tree::Simple), if C<$tree> is not a Tree::Simple object, and exception is thrown. This C<$tree> object does not need to be a ROOT, you can start at any level of the tree you desire. The options in the C<%config> argument are determined by the implementing subclass, and you should refer to that documentation for details.

=item B<getTree>

A basic accessor to reach the underlying tree object. 

=item B<getConfig>

A basic accessor to reach the underlying configuration hash. 

=item B<includeTrunk ($boolean)>

This controls the getting and setting (through the optional C<$boolean> argument) of the option to include the tree's trunk in the output. Many times, the trunk is not actually part of the tree, but simply a root from which all the branches spring. However, on occasion, it might be nessecary to view a sub-tree, in which case, the trunk is likely intended to be part of the output. This option defaults to off.

=item B<setPathComparisonFunction ($CODE)>

This takes a C<$CODE> reference, which can be used to add custom path comparison features to Tree::Simple::View. The function will get two arguments, the first is the C<$current_path>, the second is the C<$current_tree>. When using C<expandPath>, it may sometimes be nessecary to be able to control the comparison of the path values. For instance, your node may be an object and need a specific method called to match the path against. 

=item B<expandPath (@path)>

This method will return a string which will represent your tree expanded along the given C<@path>. This is best shown visually. Given this tree:

  Tree-Simple-View
      lib
          Tree
              Simple
                  View.pm
                  View
                      HTML.pm
                      DHTML.pm
      Makefile.PL
      MANIFEST
      README 
      Changes
      t
          10_Tree_Simple_View_test.t
          20_Tree_Simple_View_HTML_test.t
          30_Tree_Simple_View_DHTML_test.t
          
And given this path:

  Tree-Simple-View, lib, Tree, Simple

Your display would like something like this:

  Tree-Simple-View
      lib
          Tree
              Simple
                  View.pm
                  View
      Makefile.PL
      MANIFEST
      README 
      Changes
      t

As you can see, the given path has been expanded, but no other sub-trees are shown. The details of this are subject to the implementating subclass, and their documentation should be consulted.

It should be noted that this method actually calls either the C<expandPathSimple> or C<expandPathComplex> method depending upon the C<%config> argument in the constructor. 

=item B<expandPathSimple ($tree, @path)>

Within this base package, this is an abstract method, it will throw an exception if called.

If no C<%config> argument is given in the constructor, then this method is called by C<expandPath>. This method is optimized since it does not need to process any configuration, but just as the name implies, it's output is simple.

This method can also be used for another purpose, which is to bypass a previously specified configuration and use the base "simple" configuration instead.

=item B<expandPathComplex ($tree, $config, @path)>

Within this base package, this is an abstract method, it will throw an exception if called.

If a C<%config> argument is given in the constructor, then this method is called by C<expandPath>. This method has been optimized to be used with configurations, and will actually custom compile code (using C<eval>) to speed up the generation of the output.

This method can also be used for another purpose, which is to bypass a previously specified configuration and use the configuration specified (as a HASH reference) in the C<$config> parameter.

=item B<expandAll>

This method will return a string of HTML which will represent your tree completely expanded. The details of this are subject to the implementating subclass, and their documentation should be consulted.

It should be noted that this method actually calls either the C<expandAllSimple> or C<expandAllComplex> method depending upon the C<%config> argument in the constructor.   

=item B<expandAllSimple>

Within this base package, this is an abstract method, it will throw an exception if called.

If no C<%config> argument is given in the constructor, then this method is called by C<expandAll>. This method too is optimized since it does not need to process any configuration.

This method as well can also be used to bypass a previously specified configuration and use the base "simple" configuration instead.

=item B<expandAllComplex ($config)>

Within this base package, this is an abstract method, it will throw an exception if called.

If a C<%config> argument is given in the constructor, then this method is called by C<expandAll>. This method too has been optimized to be used with configurations, and will also custom compile code (using C<eval>) to speed up the generation of the output.

Just as with C<expandPathComplex>, this method can be to bypass a previously specified configuration and use the configuration specified (as a HASH reference) in the C<$config> parameter.

=back

=head1 DEMO

To view a demo of the Tree::Simple::View::DHTML functionality, look in the C<examples/> directory.

=head1 TO DO

=over 5

=item B<Test improvement>

Right now the tests really are not as well designed as they could be. There are a number of odd corners and edge cases which are not being tested well enough (this release (0.08) actually lost some coverage since I don't have time to properly design these tests). I am thinking when I do a 1.0 release I will sit down and really plan out a good set of test that will execise all interactions/interminglings/dark-corners/etc of the code.

=item B<Adding new Tree::Simple::View::* classes>

I<NOTE: In thinking more about some of these items, I have decided they are not "Views" in the MVC sense of the word. And since that is somewhat what I was going for, I am reconsidering including them in this module.>

I have been fiddling around with a class which outputs GraphViz .dot files. I am not sure what to call it though; Tree::Simple::View::GraphViz or Tree::Simple::View::Dot.

I have an Tree::Simple::View::ASCII class in the works, which will output Trees in plain text, and optionally support ANSI colors for terminal output. (NOTE: This may end up being just a thin wrapper around Data::TreeDumper's output, see L<SEE ALSO> section below).

I am considering a Tree::Simple::View::PS or Tree::Simple::View::PDF class which could output either Postscript or PDF trees. 

I have thought about Tree::Simple::View::XML, but I am not sure it would be useful really.

I suppose that Tree::Simple::View::* classes could be made for various GUI toolkits like Tk, etc. But to tell the truth, I am not that familiar with non-web GUIs, so that is likely a long way off. 

=item B<Different Tree display formats>

I have been experimenting with an algorithm to draw a tree from the top-down in ASCII, the GraphViz output will already do this format, and I have no idea currently how to even code it in HTML/DHTML much less write the code to generate it. I am not sure how useful this will be since it can very quickly get very wide.

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, below is the B<Devel::Cover> report on this module test suite.

 --------------------------------- ------ ------ ------ ------ ------ ------ ------
 File                                stmt branch   cond    sub    pod   time  total
 --------------------------------- ------ ------ ------ ------ ------ ------ ------
 /Tree/Simple/View.pm               100.0   87.5   75.0  100.0  100.0    3.3   94.8
 /Tree/Simple/View/DHTML.pm         100.0   77.3  100.0  100.0  100.0   19.6   95.2
 /Tree/Simple/View/HTML.pm           98.5   75.0   62.5  100.0  100.0   65.2   89.8
 t/10_Tree_Simple_View_test.t       100.0    n/a    n/a  100.0    n/a    1.7  100.0
 t/20_Tree_Simple_View_HTML_test.t  100.0    n/a    n/a  100.0    n/a    1.4  100.0
 t/30_Tree_Simple_View_DHTML_test.t 100.0    n/a    n/a  100.0    n/a    2.3  100.0
 t/pod.t                            100.0   50.0    n/a  100.0    n/a    5.6   95.2
 t/pod_coverage.t                   100.0   50.0    n/a  100.0    n/a    0.8   95.2 
 --------------------------------- ------ ------ ------ ------ ------ ------ ------
 Total                               99.7   76.7   71.4  100.0  100.0  100.0   95.9
 --------------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 SEE ALSO

This is just an abstract base class, I suggest you read the documentation in the implementing subclasses:

=over 4

=item B<Tree::Simple::View::HTML>

=item B<Tree::Simple::View::DHTML>

=back

There are a few modules out there that I have seen which do similar things to these modules. I have attempted to describe them here, but not being a user of these modules myself, I can not do them justice. If you think I have mis-represented or just under-represented these modules, please let me know. Also, if I have not included a module which should be here, let me know and I will add it.

=over 4

=item B<Data::TreeDumper>

This module is an alternative to Data::Dumper for dumping out any type of data structures. As the author points out, the output of Data::Dumper when dealing with tree structures can be difficult to read at best. This module solves that problem by dumping a much more readable and understandable output specially for tree structures. Data::TreeDumper has many options for output, including custom filtersand coloring. I have been working with this modules author  and we have been sharing code. Data::TreeDumper can
output Tree::Simple objects (L<http://search.cpan.org/~nkh/Data-TreeDumper-0.15/TreeDumper.pm#Structure_replacement>). This givesTree::Simple the ability to utilize the ASCII/ANSI output  styles of Data::TreeDumper. Nadim has used some of the code from  Tree::Simple::View to add DHTML output to Data::TreeDumper. The DHTML output can be without tree-lines as for Tree::Simple:View or with 
tree-lines as with Data::TreeDumper.

=item B<HTML::PopupTreeSelect>

This module implements a DHTML "pop-up" dialog which contains an expand-collapse tree, which can be used for selecting an item from a hierarchy. It looks to me to be very configurable and have all its bases covered, right down to handling some of the uglies of cross-browser/cross-platform DHTML. However it is really for a very specific purpose, and not for general tree display like this module. 

=item B<HTML::TreeStructured>

This module actually seems to do something very similar to these modules, but to be honest, the documentation is very, very sparse, and so I am not really sure how to go about using it. From a quick read of the code it seems to use HTML::Template as its base, but after that I am not sure. 

=item B<CGI::Explorer>

This module is similar to the HTML::PopupTreeSelect, in that it is intended for a more singular purpose. This module implements a Windows-style explorer tree.

=back

=head1 ACKNOWLEDGEMENTS

=over 4

=item Thanks to Neyuki for the idea of the C<setPathComparisonFunction> method.

=back

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

