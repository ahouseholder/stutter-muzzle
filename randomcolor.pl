#!/usr/bin/perl 

use strict;

my @RGBFILE = qw(/usr/lib/X11/rgb.txt /usr/X11R6/lib/X11/rgb.txt);

# open the first file on the list that works...
RGB_FILE: foreach my $filename (@RGBFILE) {
  if((-e $filename)&&(-s $filename)&&(-r $filename)&&(-T $filename)) {
  # file exists, has nonzero size, is readable, and is a text file
    open(RGBVALS,"<$filename");
    last RGB_FILE;
  } else {
    next RGB_FILE;
  }
}

my @color_names;
my %colors_seen;

my $limit = 300;

COLOR: while() {

  next COLOR unless ($_ =~ /^\s*(\d+\s+){3}[a-zA-Z]+$/);
  #remove leading whitespace
  $_ =~ s/^\s+//;

  my ($r,$g,$b,$name) = split(/\s+/,$_,4);
  
  my $lcname = $name;
  $lcname =~ tr/A-Z/a-z/;

  # skip colors that aren't very readable
  next COLOR if $lcname =~ /gr[ae]y/;
  next COLOR if $lcname =~ /black/;
  next COLOR if $lcname =~ /^dark$/;

  # skip gray-ish colors
  my $rg = ($r - $g)**2;
  my $rb = ($r - $b)**2;
  my $gb = ($g - $b)**2;
  next COLOR if (($rg < $limit) && ($rb < $limit) && ($gb < $limit));
  
  # skip duplicates
  my $key = join(":",$r,$g,$b);
  next COLOR if $colors_seen{$key};
  $colors_seen{$key}++;

  # add the name to the array to select from
  push(@color_names,$name);

}

close RGBVALS;

# put something in there if no colors were found
push(@color_names,"white") if ($#color_names < 0);

my $random_seed = (time() ^ ($$ + ($$ << 15))) ;
srand($random_seed);

# pick a random color for output
print "$color_names[int(rand($#color_names))]";
