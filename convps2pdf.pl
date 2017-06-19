#! /usr/bin/env perl
use strict;
use warnings;

use Scalar::Util qw(looks_like_number);


sub ps2pdf;
sub get_ps_headers;
sub get_media_size;
sub main;

# Run the program
main();


# Function: main
#
# Program's entry point.
#
sub main {
   for (@ARGV) {

      # check input file
      if(not -r) {
         print "WARN: Cannot read input file: $_\n";
         next;
      }

      # build PDF file name
      my $pdf = $_;
      $pdf =~ s/(\.e?ps)?$/.pdf/i;

      ps2pdf($_, $pdf);
   }
}


# Function: ps2pdf
#
# Converts a PostScript file to PDF format using GhostScript,
# keeping the medium size.
#
# Params:
#
#     $ps_file  - (string) Input [E]PS file name
#     $pdf_file - (string) Output PDF file name
#
sub ps2pdf {
   my ($ps_file, $pdf_file) = @_;
   my $cmd = "gs -q -sDEVICE=pdfwrite -dPDFFitPage -dAutoRotatePages=/All ";

   # try to find the media size
   my ($width, $height) = get_media_size(get_ps_header($ps_file));

   # keep media size
   if(defined $height) {
      $cmd .= "-g${width}x${height} ";
   }

   # set input/output
   $cmd .= "-sOutputFile=$pdf_file $ps_file";

   print "Running: $cmd\n";

   system($cmd);
}


# Function: get_media_size
#
# Computes the size of a PostScript document in pixels,
# from the headers in the PS file.
#
# Params:
#
#     $hdr  - (hash ref) Parsed PS header values
#
# Returns:
#
#     On success: Two-element array holding the document's width and height
#     On failure: undef
#
sub get_media_size {
   my ($hdr) = @_;

   # we need the DocumentMedia header
   return undef if not defined $hdr->{DocumentMedia};

   # look for valid values
   my @values = split(/\s+/, $hdr->{DocumentMedia});
   return undef if scalar @values < 3;
   my ($width, $height) = @values[1, 2];

   return undef if not all { looks_like_number($_) } ($width, $height);

   # Ghostscript uses a default resolution of 720 pixels/inch,
   # there are 72 PostScript points/inch.
   return ($width*10, $height*10);
}


# Function: get_ps_header
#
#  Parses a PostScript file looking for headers.
#
# Params:
#
#     $ps_file - (string) Path of the input file
#
# Returns:
#
#     (hash ref) - As expected, keys are header names,
#     values are corresponding header values. A special key
#     named `version' is included for headers of the type
#     `PS-Adobe-3.0'
#
sub get_ps_header {
   my ($ps_file) = @_;
   my %head;

   open my $fh, "<$ps_file" or die "Failed to open $ps_file\n";
   while(<$fh>) {
      # look for end of header
      last if /^%%EndComments\b/;

      # look for PS version
      if(/^%!(\w+)/) {
         $head{version} = $1;
      }

      # look for any other field
      # Ex: %%BoundingBox: 0 0 1008 612
      elsif(/^%%(\w+)\s*:\s*(.*\S)/) {
         $head{$1} = $2;
      }

      # discard regular comments and blank lines
      elsif(/^\s*(%.*)?$/) {
         next;
      }

      # any other thing will finish the header
      else {
         last;
      }
   }

   return \%head;
}
