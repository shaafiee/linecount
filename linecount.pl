#!/usr/bin/perl

use strict;

my $start_dir = `pwd`;
#my $sed_command = "sed -i'.sed_orig' -E 's/^\s*EM_ASM/\\\/\\\/EM_ASM/g'"
my %lineCountByFileType;
my %spaceCountByFileType;
my $totalCodeLines;
my $totalSpaceLines;
my @excludes;
my @excludeExtensions;
chomp $start_dir;

print $start_dir;

if ($#ARGV >= 0 && length($ARGV[0]) > 0) {
	$start_dir = $ARGV[0];
}
&process_excludes($start_dir);
&process_dir($start_dir);
&display_results();

exit;

sub display_results {
	my @extensions = keys %lineCountByFileType;
	foreach my $extension (@extensions) {
		print $extension."\t\t".$lineCountByFileType{$extension}."\t\t".$spaceCountByFileType{$extension}."\n";
	}
	print "-------\n";
	print "TOTAL LINES: ".$totalCodeLines."\n";
	print "TOTAL EMPTY LINES: ".$totalSpaceLines."\n";
}

sub process_excludes {
	my $predefined = shift;

	open (FILE, "<exclude.list");
	while (my $currentLine = <FILE>) {
		chomp $currentLine;
		if ($currentLine =~ /\.{1}.*/g) {
			$excludeExtensions[$#excludeExtensions + 1] = $predefined."/".$currentLine;
		} else {
			$excludes[$#excludes + 1] = $predefined."/".$currentLine;
		}
		print $predefined."/".$currentLine."\n";
	}
	close (FILE);
}

sub process_dir {
	my $dir = shift;
	opendir DIR, $dir;
	my @dir = readdir(DIR);
	close DIR;
	foreach(@dir) {
		if ($_ eq '.' || $_ eq '..') {
			next;
		}
		if (-f $dir."/". $_) {
			my $complete_filename = $dir."/".$_;
			#if ($_ =~ /(\.cpp)$/) {
				#my $returned = `$sed_command $complete_filename`;
				&process_file($complete_filename);
				#print "[PROCESSED] ",$_,"   : file\n";
			#}
		} elsif (-d $dir."/".$_) {
			#print $_,"--------------   : folder\n";
			my $found = 0;
			foreach my $exclude (@excludes) {
				chomp $exclude;
				if ($exclude eq $dir."/".$_) {
					$found = 1;
				}
			}
			if ($_ =~ /^\.{1}.*/g) {
				$found = 1;
			}
			if ($found == 0) {
				&process_dir($dir."/".$_);
			}
		} else {
			#print $_,"   : other\n";
		}
	}
}

sub process_file {
	my $file = shift;
	open (FILE, $file);
	my $hasExtension;

	if ($file =~ /.*\.{1}(.+)$/) {
		$hasExtension = $1;
	} else {
		$hasExtension = '';
	}

	chomp $hasExtension;
	foreach my $excludeExtension (@excludeExtensions) {
		chomp $excludeExtension;
		if ($excludeExtension =~ /.*\.{1}$hasExtension$/g) {
			return;
		}
	}

	my $lineCount = 0;
	my $spaceLineCount = 0;
	while (my $line = <FILE>) {
		if ($line =~ /^\s*$/g) {
			$spaceLineCount++;
		} else {
			$lineCount++;
		}
	}

	$totalCodeLines = $totalCodeLines + $lineCount;
	$totalSpaceLines = $totalSpaceLines + $spaceLineCount;
	if (length($hasExtension) > 0) {
		$lineCountByFileType{$hasExtension} = $lineCountByFileType{$hasExtension} + $lineCount;
		$spaceCountByFileType{$hasExtension} = $spaceCountByFileType{$hasExtension} + $spaceLineCount;
	} else {
	}

	close (FILE);
}

