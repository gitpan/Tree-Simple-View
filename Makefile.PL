use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Tree::Simple::View',
    VERSION_FROM => 'lib/Tree/Simple/View.pm', 
    PREREQ_PM    => {
        'Test::More'   => 0.47,
        'Tree::Simple' => 1.05
    }
);
