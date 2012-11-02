This directory contains generally useful scripts for the Thesis, although these
scripts are **not** strictly used in the build process.

# Scripts
- **spell_check.sh**: Locates all LaTeX source files and runs a spell check on
    each file.
- **strip_comments.pl**: Removes C-style and C++-style comments from a file.
- **texcount.sh**: Provides a word count for the LaTeX document, using
    [texcount](https://github.com/joshuaspence/Thesis/tree/master/lib/texcount).
- **todos.sh**: Searches for LaTeX source files that contain TODO comments.
- **unique_from_csv.pl**: A script to output unique values from a specified
    column of a CSV file.
- **util.pl**: A common file containing some useful functions which are reused
    through the repository. Cannot be executed directly.
- **wordcount.sh**: Provides a word count for the LaTeX document from the output
    PDF.

# Dependencies
- **spell_check.sh**:
    + aspell
    + bash
- **strip_comments.pl**:
    + Perl
- **todos.sh**:
    + grep
- **unique_from_csv.pl**:
    + Perl
    + Text::CSV (Perl module)
    + List::MoreUtils (Perl module)
- **util.pl**:
    + Perl
    + Text::CSV (Perl module)
- **wordcount.sh**:
    + pdftotext