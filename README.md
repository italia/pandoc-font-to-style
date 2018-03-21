
## pandoc-font-to-style

this command works as a [pandoc
filter](http://pandoc.org/filters.html) for Open XML (`.docx`)
documents enabling you to turn fonts into semantic
information. currently it can turn fonts into code with the
`--as-code` option as follows:

    $ pandoc-font-to-style --as-code "Courier New" < document.docx | pandoc ...

it's easy to extend the filter in order to support more options like
`--as-emph`, `--as-strong` etcetera.

### list fonts from the document

to help selecting values for the `--as-code` option, the filter
supports a `--list` option which produces a summary of the fonts found
in the document:

    $ pandoc-font-to-style --list < document.docx
    the document contains the following fonts:
    "Courier New", 2 occurrences

### format text as code before converting a document

when used with the `--as-code` option, the command produces the
modified document serialised as JSON so that it can be piped through
other filters or passed to pandoc again

    $ pandoc-font-to-style --as-code "Courier New" < doc.docx > doc.json
    $ pandoc doc.json -o doc.rst # for instance

see the doc for pandoc's `--filter` option for more details

##### license

Copyright (c) the respective contributors, as shown by the AUTHORS file.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
