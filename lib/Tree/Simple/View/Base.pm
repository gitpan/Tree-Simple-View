
package Tree::Simple::View::Base;

use strict;
use warnings;

our $VERSION = '0.01';

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

Tree::Simple::View::Base - An abstract base class for viewing Tree::Simple heirarchies

=head1 SYNOPSIS

  use Tree::Simple::View::Base;

=head1 DESCRIPTION

This is an abstract base class for the Tree::Simple::View::* classes. It sets up some of the common elements shared between the classes, and defines the base interface. This documentation will detail the code implemented within this pacakge, which will also be duplicated in the implementing classes as neseccary. So in reality this documentation serves little purpose.

=head1 METHODS

=over 4

=item B<new ($tree, %configuration)>

Accepts a C<$tree> argument of a Tree::Simple object (or one derived from Tree::Simple). This C<$tree> object does not need to be a ROOT, you can start at any level of the tree you desire. The options in the C<%config> argument are determined by the implementing subclass, and you should refer to that documentation for details.

=item B<expandPath (@path)>

This method will return a string which will represent your tree expanded along the given C<@path>. This is best shown visually. Given this tree:

  Tree-Simple-View
      lib
          Tree
              Simple
                  View.pm
                  View
                      Base.pm
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

If no C<%config> argument is given in the constructor, then this method is called by C<expandPath>. This method is optimized since it does not need to process any configuration, but just as the name implies, it's output is simple.

This method can also be used for another purpose, which is to bypass a previously specified configuration and use the base "simple" configuration instead.

=item B<expandPathComplex ($tree, $config, @path)>

If a C<%config> argument is given in the constructor, then this method is called by C<expandPath>. This method has been optimized to be used with configurations, and will actually custom compile code (using C<eval>) to speed up the generation of the output.

This method can also be used for another purpose, which is to bypass a previously specified configuration and use the configuration specified (as a HASH reference) in the C<$config> parameter.

=item B<expandAll>

This method will return a string of HTML which will represent your tree completely expanded. The details of this are subject to the implementating subclass, and their documentation should be consulted.

It should be noted that this method actually calls either the C<expandAllSimple> or C<expandAllComplex> method depending upon the C<%config> argument in the constructor.   

=item B<expandAllSimple>

If no C<%config> argument is given in the constructor, then this method is called by C<expandAll>. This method too is optimized since it does not need to process any configuration.

This method as well can also be used to bypass a previously specified configuration and use the base "simple" configuration instead.

=item B<expandAllComplex ($config)>

If a C<%config> argument is given in the constructor, then this method is called by C<expandAll>. This method too has been optimized to be used with configurations, and will also custom compile code (using C<eval>) to speed up the generation of the output.

Just as with C<expandPathComplex>, this method can be to bypass a previously specified configuration and use the configuration specified (as a HASH reference) in the C<$config> parameter.

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 SEE ALSO

This is just an abstract base class, I suggest you read the documentation in the implementing subclasses:

=over 4

=item B<Tree::Simple::View::HTML>

=item B<Tree::Simple::View::DHTML>

=back

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

