
package Tree::Simple::View::HTML;

use strict;
use warnings;

use Tree::Simple::View::Base;

our $VERSION = '0.03';

our @ISA = qw(Tree::Simple::View::Base);

use constant OPEN_TAG => 1;
use constant CLOSE_TAG => 2;

use constant EXPANDED => 3;

## public methods

sub expandPathSimple  { 
    my ($self, $tree, $current_path, @path) = @_;
    my @results = ("<UL>");
    foreach my $child ($tree->getAllChildren()) {
        if (defined $current_path && $child->getNodeValue() eq $current_path) {
            push @results => ("<LI>" . $child->getNodeValue() . "</LI>");
            push @results => ($self->expandPathSimple($child, @path));
        }
        else {
            push @results => ("<LI>" . $child->getNodeValue() . "</LI>");
        }
    }
    push @results => "</UL>";
    return (join "\n" => @results);    
}

sub expandPathComplex {
    my ($self, $tree, $config, @path) = @_;
    # get the config
    my ($list_func, $list_item_func) = $self->_processConfig($config);  
    
    # use the helper function to recurse
    my $_expandPathComplex = sub {
        my ($self, $list_func, $list_item_func, $tree, $current_path, @path) = @_;
        my @results = ($list_func->(OPEN_TAG));
        foreach my $child ($tree->getAllChildren()) {
            if (defined $current_path && $child->getNodeValue() eq $current_path) {
                unless ($child->isLeaf()) {
                    push @results => ($list_item_func->($child, EXPANDED));
                    push @results => ($self->($self, $list_func, $list_item_func, $child, @path));
                }
                else {
                    push @results => ($list_item_func->($child));
                }
            }
            else {
                push @results => ($list_item_func->($child));
            }
        }
        push @results => ($list_func->(CLOSE_TAG));
        return (join "\n" => @results);   
    };

    return $_expandPathComplex->($_expandPathComplex, $list_func, $list_item_func, $tree, @path);
}

sub expandAllSimple  {
    my ($self) = @_;   
    my @results = ("<UL>");
    my $root_depth = $self->{tree}->getDepth() + 1;    
    my $last_depth = -1;
    $self->{tree}->traverse(sub {
        my ($t) = @_;
        my $current_depth = $t->getDepth();
        push @results => ("</UL>" x ($last_depth - $current_depth)) if ($last_depth > $current_depth);
        push @results => ("<LI>" . $t->getNodeValue() . "</LI>");
        push @results => "<UL>" unless $t->isLeaf();
        $last_depth = $current_depth;
    });
    $last_depth -= $root_depth;    
    push @results => ("</UL>" x ($last_depth + 1)); 
    return (join "\n" => @results);
}

sub expandAllComplex {
    my ($self, $config) = @_;
    
    my ($list_func, $list_item_func) = $self->_processConfig($config);   
    
    my @results = $list_func->(OPEN_TAG);
    my $root_depth = $self->{tree}->getDepth() + 1;    
    my $last_depth = -1;
    $self->{tree}->traverse(sub {
        my ($t) = @_;
        my $current_depth = $t->getDepth();
        push @results => ($list_func->(CLOSE_TAG) x ($last_depth - $current_depth)) if ($last_depth > $current_depth);
        if ($t->isLeaf()) {
            push @results => ($list_item_func->($t));
        }
        else {
            push @results => ($list_item_func->($t, EXPANDED));
        }
        push @results => $list_func->(OPEN_TAG) unless $t->isLeaf();
        $last_depth = $current_depth;
    });
    $last_depth -= $root_depth;    
    push @results => ($list_func->(CLOSE_TAG) x ($last_depth + 1)); 
    return (join "\n" => @results);
}

# process configurations

sub _processConfig {
    my ($self, $config) = @_;
    my %config = %{$config};
        
    my $list_func = $self->_buildListFunction(%config) || die "list function didnt compile : $@";
    my $list_item_func  = $self->_buildListItemFunction(%config) || die "list item function didnt compile : $@";

    return ($list_func, $list_item_func);
}

## code strings to be evaluated

use constant LIST_FUNCTION_CODE_STRING => q|
    sub {
        my ($tag_type) = @_;
        return "<${list_type}L${list_css}>" if ($tag_type == OPEN_TAG);
        return "</${list_type}L>" if ($tag_type == CLOSE_TAG);
    }
|;

use constant LIST_ITEM_FUNCTION_CODE_STRING  => q|;
    sub {
        my ($t, $is_expanded) = @_;
        my $item_css = $list_item_css;
        $item_css = $expanded_item_css if ($is_expanded && $expanded_item_css);
        return "<LI${item_css}>" . (($node_formatter) ? $node_formatter->($t) : $t->getNodeValue()) . "</LI>";
    }
|;

## list config processing
sub _processListConfig {
    my ($self, %config) = @_;
    
    my $list_type = "U";
    $list_type = (($config{list_type} eq "unordered") ? "U" : "O") if exists $config{list_type};

    my $list_css = "";
    if (exists $config{list_css}) {
        my $_list_css = $config{list_css};
        $_list_css .= ";" unless ($_list_css =~ /\;$/);        
        $list_css = " STYLE='${_list_css}'";
    }
    elsif (exists $config{list_css_class}) {
        $list_css = " CLASS='" . $config{list_css_class} . "'";
    }
    # otherwise do nothing and stick with default
    
    return ($list_type, $list_css);
}

sub _buildListFunction {
    my ($self, %config) = @_;
    # process the configuration directives
    my ($list_type, $list_css) = $self->_processListConfig(%config);
    # now compile the subroutine in the current environment
    return eval $self->LIST_FUNCTION_CODE_STRING;
}

## list item config processing

sub _processListItemConfig {
    my ($self, %config) = @_;
    
    my $list_item_css = "";
    if (exists $config{list_item_css}) {
        my $_list_item_css = $config{list_item_css};
        $_list_item_css .= ";" unless ($_list_item_css =~ /\;$/);
        $list_item_css = " STYLE='${_list_item_css}'";
    }
    elsif (exists $config{list_item_css_class}) {
        $list_item_css = " CLASS='" . $config{list_item_css_class} . "'";
    }
    # otherwise do nothing and stick with default    

    my $expanded_item_css = "";
    if (exists $config{expanded_item_css}) {
        my $_expanded_item_css = $config{expanded_item_css};
        $_expanded_item_css .= ";" unless ($_expanded_item_css =~ /\;$/);    
        $expanded_item_css = " STYLE='${_expanded_item_css}'";
    }
    elsif (exists $config{expanded_item_css_class}) {
        $expanded_item_css = " CLASS='" . $config{expanded_item_css_class} . "'";
    }
    # otherwise do nothing and stick with default    
    
    my $node_formatter;
    $node_formatter = $config{node_formatter} 
        if (exists $config{node_formatter} && ref($config{node_formatter}) eq "CODE");
        
    return ($list_item_css, $expanded_item_css, $node_formatter);
}

sub _buildListItemFunction {
    my ($self, %config) = @_;
    # process the configuration directives
    my ($list_item_css, $expanded_item_css, $node_formatter) = $self->_processListItemConfig(%config);
    # now compile the subroutine in the current environment    
    return eval $self->LIST_ITEM_FUNCTION_CODE_STRING;
}

1;

__END__

=head1 NAME

Tree::Simple::View::HTML - A class for viewing Tree::Simple hierarchies in HTML

=head1 SYNOPSIS

  use Tree::Simple::View::HTML;
  
  ## a simple example
  # use the defaults (an unordered list with no CSS)
  my $tree_view = Tree::Simple::View::HTML->new($tree);

  ## more complex examples
                                        
  # an ordered list with CSS properties specified for 
  # the list element, the CSS properties specified for 
  # the list item elements, and the CSS properties 
  # specified for any "expanded" items                                    
  my $tree_view = Tree::Simple::View::HTML->new($tree => (
                                list_type  => "ordered",
                                list_css => "list-style: circle;",
                                list_item_css => "font-family: courier;",
                                expanded_item_css => "font-family: courier; font-weight: bold",                               
                                ));  
                                
  # an unordered list (default) with CSS class specified 
  # for the list element, with the CSS class specified for 
  # the list item elements, and the CSS class specified
  # for any "expanded" items                                    
  my $tree_view = Tree::Simple::View::HTML->new($tree => (
                                list_css_class => "myListClass",
                                list_item_css_class => "myListItemClass",
                                expanded_item_css_class => "myExpandedListItemClass",                                
                                ));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
                                   
  # an unordered list (default) and a mixture of CSS property
  # strings and CSS classes, along with the node_formatter option
  # so all the nodes will be formatted by this subroutine 
  my $tree_view = Tree::Simple::View::HTML->new($tree => (
                                list_css => "list-style: circle;",
                                list_item_css => "font-family: courier;",
                                expanded_item_css_class => "myExpandedListItemClass",                                                         
                                node_formatter => sub {
                                    my ($node) = @_;
                                    return "<B>" . $node->description() . "</B>";
                                    }
                                ));  
                              
  
  # print out the tree fully expanded
  print $tree_view->expandAll();
  
  # print out the tree expanded along a given path (see below for details)
  print $tree_view->expandPath("Root", "Child", "GrandChild");                                                           

=head1 DESCRIPTION

This is a class for use with Tree::Simple object hierarchies to serve as a means of displaying them in HTML. It is the "View", while the Tree::Simple object hierarchy would be the "Model" in your standard Model-View-Controller paradigm. 

This class outputs fairly vanilla HTML in its simpliest configuration, suitable for both legacy browsers and text-based browsers. Through the use of various configuration options, CSS can be applied to support more advanced browsers but still degrade gracefully to legacy browsers. 

=head1 METHODS

=over 4

=item B<new ($tree, %configuration)>

Accepts a C<$tree> argument of a Tree::Simple object (or one derived from Tree::Simple). This C<$tree> object does not need to be a ROOT, you can start at any level of the tree you desire. The options in the C<%config> argument are as follows:

=over 4

=item I<list_type>

This can be either 'ordered' or 'unordered', which will produce ordered and unordered lists respectively. The default is 'unordered'.

=item I<list_css>

This can be a string of CSS to be applied to the list tag (C<UL> or C<OL> depending upon the I<list_type> option). This option and the I<list_css_class> are mutually exclusive, and this option will override in a conflict.

=item I<list_css_class>

This can be a CSS class name which is applied to the list tag (C<UL> or C<OL> depending upon the I<list_type> option). This option and the I<list_css> are mutually exclusive, and the I<list_css> option will override in a conflict.

=item I<list_item_css>

This can be a string of CSS to be applied to the list item tag (C<LI>). This option and the I<list_item_css_class> are mutually exclusive, and this option will override in a conflict.

=item I<list_item_css_class>

This can be a CSS class name which is applied to the list item tag (C<LI>). This option and the I<list_item_css> are mutually exclusive, and the I<list_item_css> option will override in a conflict.

=item I<expanded_item_css>

This can be a string of CSS to be applied to the list item tag (C<LI>) if it has an expanded set of children. This option and the I<expanded_item_css_class> are mutually exclusive, and this option will override in a conflict.

=item I<expanded_item_css_class>

This can be a CSS class name which is applied to the list item tag (C<LI>) if it has an expanded set of children. This option and the I<expanded_item_css> are mutually exclusive, and the I<expanded_item_css> option will override in a conflict.

=item I<node_formatter>

This can be a CODE reference which will be given the current tree object as its only argument. The output of this subroutine will be placed within the list item tags (C<LI>). This option can be used to implement; custom formatting of the node, handling of complex node objects or implementing any type of handler code to drive your interface (using link tags or form submissions, etc). 

=back

=item B<getTree>

A basic accessor to reach the underlying tree object. 

=item B<getConfig>

A basic accessor to reach the underlying configuration hash. 

=item B<expandPath (@path)>

This method will return a string of HTML which will represent your tree expanded along the given C<@path>. This is best shown visually. Given this tree:

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

As you can see, the given path has been expanded, but no other sub-trees are shown (nor is the HTML of the un-expanded nodes to be found in the output). 

It should be noted that this method actually calls either the C<expandPathSimple> or C<expandPathComplex> method depending upon the C<%config> argument in the constructor. See their documenation for details.

=item B<expandPathSimple ($tree, @path)>

If no C<%config> argument is given in the constructor, then this method is called by C<expandPath>. This method is optimized since it does not need to process any configuration, but just as the name implies, it's output is simple.

This method can also be used for another purpose, which is to bypass a previously specified configuration and use the base "simple" configuration instead.

=item B<expandPathComplex ($tree, $config, @path)>

If a C<%config> argument is given in the constructor, then this method is called by C<expandPath>. This method has been optimized to be used with configurations, and will actually custom compile code (using C<eval>) to speed up the generation of the output.

This method can also be used for another purpose, which is to bypass a previously specified configuration and use the configuration specified (as a HASH reference) in the C<$config> parameter.

=item B<expandAll>

This method will return a string of HTML which will represent your tree completely expanded.

It should be noted that this method actually calls either the C<expandAllSimple> or C<expandAllComplex> method depending upon the C<%config> argument in the constructor.   

=item B<expandAllSimple>

If no C<%config> argument is given in the constructor, then this method is called by C<expandAll>. This method too is optimized since it does not need to process any configuration.

This method as well can also be used to bypass a previously specified configuration and use the base "simple" configuration instead.

=item B<expandAllComplex ($config)>

If a C<%config> argument is given in the constructor, then this method is called by C<expandAll>. This method too has been optimized to be used with configurations, and will also custom compile code (using C<eval>) to speed up the generation of the output.

Just as with C<expandPathComplex>, this method can be to bypass a previously specified configuration and use the configuration specified (as a HASH reference) in the C<$config> parameter.

=back

=head1 TO DO

=over 4

=item B<depth-based css>

I would like to be able to set any of my css properties as an array, which would essentially allow for depth-based css values. For instance, something like this:

  list_css => [
      "font-size: 14pt;",
      "font-size: 12pt;",
      "font-size: 10pt;"      
      ];

This would result in the first level of the tree having a font-size of 14 points, the second level would have a font-size of 12 points, then all other levels past the second level (third and beyond) would have a font-size of 10 points. Of course if a fourth element were added to this array (ex: "font-size: 8pt;"), then the third level would have a font-size of 10 points, and all others past that level would have the font-size of 8 points. 

Ideally this option would be available for all I<*_css> and I<*_css_class> options. I have not yet figured out the best way to do this though, so ideas/suggestions are welcome, of course, patches are even better.

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

See the CODE COVERAGE section of Tree::Simple::View for details.

=head1 SEE ALSO

If a DHTML based tree is what you are after, then look at the Tree::Simple::View::DHTML class.

A great CSS reference can be found at:

    http://www.htmlhelp.com/reference/css/

Information specifically about CSS for HTML lists is at:

    http://www.htmlhelp.com/reference/css/classification/list-style.html

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
