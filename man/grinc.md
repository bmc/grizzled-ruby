grinc(1) -- Process includes on a text file
===========================================

## SYNOPSIS

`grinc` [-o output | --output output] [-n maxnest | --maxnest maxnest] [files]

## DESCRIPTION

*grinc* runs an include file preprocessor on one or more files, writing the
result to an output file (or standard output).

If the output file isn't specified, output is written to standard output.

The *include* syntax is simple:

    %include "filespec"

*filespec* can be an absolute pathname, a relative pathname, a simple file
name, or a URL. For example:

    %include "/absolute/path/to/file"
    %include "../relative/path/to/file"
    %include "local_reference"
    %include "http://localhost/path/to/my.config"

Relative and local file references are relative to the including file or
URL. That, if *grinc* is processing file "/home/bmc/foo.txt" and encounters
an attempt to include file "bar.txt", it will assume "bar.txt" is to be
found in "/home/bmc".

Similarly, if *grinc* is processing URL "http://localhost/bmc/foo.txt" and
encounters an attempt to include file "bar.txt", it will assume "bar.txt"
is to be found at "http://localhost/bmc/bar.txt".

Nested includes are permitted; that is, an included file may, itself,
include other files. The maximum recursion level is configurable, via
a command line option, and defaults to 100.

Multiple input files are permitted; they are processed in turn, and their
expanded outputs are concatenated to the output file. If no input files
are specified, *grinc* reads standard input.

## OPTIONS

* `-n N`, `--nesting=N`, `--nesting N`:
  The maximum number of nested include files. Default: 100

* `-o file`, `--output=file`, `--output file`:
  Where to write the resulting expanded file. Default: standard output.
  
## SEE ALSO

m4(1)

## AUTHOR

Brian M. Clapper, [bmc@clapper.org](bmc@clapper.org)

## COPYRIGHT

Copyright &copy; 2011 Brian M. Clapper

## LICENSE

*grinc* is released under a BSD license.
