
package Tree::Simple::View;

use strict;
use warnings;

our $VERSION = '0.06';

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
    (defined($tree) && ref($tree) && UNIVERSAL::isa($tree, "Tree::Simple"))
        || die "Insufficient Arguments : tree argument must be a Tree::Simple object";
    $self->{tree} = $tree;
    $self->{config} = \%config if %config;
}

sub getTree {
    my ($self) = @_;
    return $self->{tree};
}

sub getConfig {
    my ($self) = @_;
    return $self->{config};
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

1;

__END__

=head1 NAME

Tree::Simple::View - A base for a set of classes used for viewing Tree::Simple hierarchies in various output formats

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

I have run some I<rough> benchmarks on my Powerbook (500 mHz G4 w/ 512K of RAM) running OS X (10.3.4). I used a 1200+ node Tree::Simple hierarchy and tested it with range of configuration options. For simple (no configuration) rendering it was able to render approx. 15 times a second. For more complex renderings (with a configuration), it was able to render approx. 10 times a second. Interestingly enough, no matter home complex the configuration, the render time remained pretty much constant. I expect these numbers would be much higher if I had run them our webserver (usually Linux running on P3 or P4 and min. 1 GB of RAM), and I will include more thorough benchmark stats in the 1.0 release documentation. 

=head1 METHODS

=over 4

=item B<new ($tree, %configuration)>

Accepts a C<$tree> argument of a Tree::Simple object (or one derived from Tree::Simple), if C<$tree> is not a Tree::Simple object, and exception is thrown. This C<$tree> object does not need to be a ROOT, you can start at any level of the tree you desire. The options in the C<%config> argument are determined by the implementing subclass, and you should refer to that documentation for details.

=item B<getTree>

A basic accessor to reach the underlying tree object. 

=item B<getConfig>

A basic accessor to reach the underlying configuration hash. 

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

=item B<Adding new Tree::Simple::View::* classes>

I have an Tree::Simple::View::ASCII class in the works, which will output Trees in plain text, and optionally support ANSI colors for terminal output. (NOTE: This may end up being just a thin wrapper around Data::TreeDumper's output, see L<SEE ALSO> section below).

I am considering a Tree::Simple::View::PS or Tree::Simple::View::PDF class which could output either Postscript or PDF trees. 

I have thought about Tree::Simple::View::XML, but I am not sure it would be useful really.

I suppose that Tree::Simple::View::* classes could be made for various GUI toolkits like Tk, etc. But to tell the truth, I am not that familiar with non-web GUIs, so that is likely a long way off. 

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, below is the B<Devel::Cover> report on this module test suite.

 ---------------------------------- ------ ------ ------ ------ ------ ------ ------
 File                                 stmt branch   cond    sub    pod   time  total
 ---------------------------------- ------ ------ ------ ------ ------ ------ ------
 /Tree/Simple/View.pm                100.0  100.0   77.8  100.0  100.0    0.8   97.1
 /Tree/Simple/View/DHTML.pm          100.0   57.7  100.0  100.0  100.0   31.3   93.8
 /Tree/Simple/View/HTML.pm            99.1   72.2   66.7  100.0  100.0   11.6   91.6
 t/10_Tree_Simple_View_test.t        100.0    n/a    n/a  100.0    n/a   16.3  100.0
 t/20_Tree_Simple_View_HTML_test.t   100.0    n/a    n/a  100.0    n/a   11.7  100.0
 t/30_Tree_Simple_View_DHTML_test.t  100.0    n/a    n/a  100.0    n/a   28.2  100.0
 ---------------------------------- ------ ------ ------ ------ ------ ------ ------
 Total                                99.8   70.0   76.7  100.0  100.0  100.0   96.0
 ---------------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 SEE ALSO

This is just an abstract base class, I suggest you read the documentation in the implementing subclasses:

=over 4

=item B<Tree::Simple::View::HTML>

=item B<Tree::Simple::View::DHTML>

=back

There are a few modules out there that I have seen which do similar things to these modules. I have attempted to describe them here, but not being a user of these modules myself, I can not do them justice. If you think I have mis-represented or just under-represented these modules, please let me know. Also, if I have not included a module which should be here, let me know and I will add it.

=over 4

=item B<HTML::PopupTreeSelect>

This module implements a DHTML "pop-up" dialog which contains an expand-collapse tree, which can be used for selecting an item from a hierarchy. It looks to me to be very configurable and have all its bases covered, right down to handling some of the uglies of cross-browser/cross-platform DHTML. However it is really for a very specific purpose, and not for general tree display like this module. 

=item B<HTML::TreeStructured>

This module actually seems to do something very similar to these modules, but to be honest, the documentation is very, very sparse, and so I am not really sure how to go about using it. From a quick read of the code it seems to use HTML::Template as its base, but after that I am not sure. 

=item B<CGI::Explorer>

This module is similar to the HTML::PopupTreeSelect, in that it is intended for a more singular purpose. This module implements a Windows-style explorer tree.

=item B<Data::TreeDumper>

This module is an alternative to Data::Dumper for dumping out various types of data structures. As the author points out, the output of Data::Dumper when dealing with tree structures can be difficult to read at best. This module solves that problem by dumping a much more readable and understandable output specialy for tree structres. Data::TreeDumper has many options for output, including custom filters, so it quite possible to produce similar output to these module's using Data::TreeDumper. I have actually been working with this modules author to ensure compatability between Data::TreeDumper and Tree::Simple, and we have been sharing code so that Data::TreeDumper's output can utilize some of Tree::Simple::View's capabilities. Ideally this will give Tree::Simple the ability to utilize the ASCII/ANSI output styles of Data::TreeDumper and Data::TreeDumper the ability to easily display output in HTML/DHTML.

=back

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

