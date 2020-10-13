# linecount

<b>Usage</b>
<br />
<br />
./linecount.pl <code_path>
<br />
<br />
If <code_path> is not supplied, then the execution path is used for code_path.
<br />
<br />
<br />
<b>To add exclusions</b>
<br />
<br />
Add the text file 'exclude.list' in the execution path (not always the <code_path>).
<br />
<br />
'exclude.list' can contain a list of paths to omit from the count, one per line. Each path should be relative to the code_path - if code_path is '/home/user/path', then the path 'nodejs' in 'exclude.list' would be interpreted as '/home/user/path/nodejs'.
<br />
<br />
If a line in 'exclude.list' starts with a period (.) then it is construed as an extension to be omitted from the count.
