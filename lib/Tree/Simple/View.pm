
package Tree::Simple::View;

use strict;
use warnings;

our $VERSION = '0.01';

my $VIEW_TYPE = "HTML";

sub import {
    shift;
    $VIEW_TYPE = shift if @_;
}

sub new {
    shift;
    die "no Tree::Simple::View type selected" unless $VIEW_TYPE;
    my $view_type = "Tree::Simple::View::${VIEW_TYPE}";
    eval "use $view_type";
    die "$view_type is not a valid view type : $@" if $@;
    return $view_type->new(@_);
}

1;

__END__

=head1 NAME

Tree::Simple::View - A class for viewing Tree::Simple heirarchies in various formats

=head1 SYNOPSIS

  use Tree::Simple::View;
  # the default uses Tree::Simple::View::HTML 
  
  use Tree::Simple::View qw(DHTML);
  # now uses the Tree::Simple::View::DHTML class

=head1 DESCRIPTION

This serves as a proxy front end to the Tree::Simple::View::* classes. For now all that are included are; Tree::Simple::View::HTML and Tree::Simple::View::DHTML. Eventually I will be adding more Tree::Simple::View::* classes for it to proxy, see the L<TO DO> section for more information.

This is the first release of this set of modules, and therefore it is not totally "complete". That is not to say it isn't usable. It is based on some older tree formatting code I had lying around but had never properly modularized. However, I will be using these modules in a production system in the upcoming months, so you can expect many updates which should provide increases in both performance and reliability.

=head1 METHODS

=over 4

=item B<new ($tree, %config)>

Depending upon the value given in the C<use> statement, this will return an instance of Tree::Simple::View::* class. It is just a proxy to the C<Tree::Simple::View::*::new> methods.

=back

=head1 TO DO

=over 5

=item B<More Tests>

We could use some more tests, to help increase the coverage (which is only at 70.9% right now). Normally I would not release a module with coverage this low, but I need to get back to working on a project for a client (for which this module was created). But because I will be using this module in this project, I know I will be able to improve the test suite as I go.

=item B<Adding new Tree::Simple::View::* classes>

I have an Tree::Simple::View::ASCII class in the works, which will output Trees in plain text, and optionally support ANSI colors for terminal output.

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
 /Tree/Simple/View.pm                100.0   66.7    n/a  100.0  100.0    0.4   93.9
 /Tree/Simple/View/Base.pm            71.4   62.5   33.3   50.0  100.0   24.7   64.5
 /Tree/Simple/View/DHTML.pm           60.5   25.0    0.0   78.9  100.0    9.1   56.4
 /Tree/Simple/View/HTML.pm            71.3   41.7   20.0   85.0  100.0   11.0   63.7
 t/10_Tree_Simple_View_test.t        100.0    n/a    n/a  100.0    n/a    4.2  100.0
 t/20_Tree_Simple_View_HTML_test.t   100.0    n/a    n/a  100.0    n/a   19.7  100.0
 t/30_Tree_Simple_View_DHTML_test.t  100.0    n/a    n/a  100.0    n/a   30.9  100.0
 ---------------------------------- ------ ------ ------ ------ ------ ------ ------
 Total                                77.3   40.5   20.0   82.9  100.0  100.0   70.9
 ---------------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 SEE ALSO

There are a few modules out there that I have seen which do similar things to these modules. I have attempted to describe them here, but not being a user of these modules myself, I can not do them justice. If you think I have mis-represented or just under-represented these modules, please let me know. Also, if I have not included a module which should be here, let me know and I will add it.

=over 4

=item B<HTML::PopupTreeSelect>

This module implements a DHTML "pop-up" dialog which contains an expand-collapse tree, which can be used for selecting an item from a heirarchy. It looks to me to be very configurable and have all its bases covered, right down to handling some of the uglies of cross-browser/cross-platform DHTML. However it is really for a very specific purpose, and not for general tree display like this module. 

=item B<HTML-TreeStructured>

This module actually seems to do something very similar to these modules, but to be honest, the documentation is very, very sparse, and so I am not really sure how to go about using it. From a quick read of the code it seems to use HTML::Template as its base, but after that I am not sure. 

=item B<CGI::Explorer>

This module is similar to the HTML::PopupTreeSelect, in that it is intended for a more singular purpose. This module implements a Windows-style explorer tree.

=back

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

