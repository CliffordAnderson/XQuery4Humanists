# XQuery4Humanists

We're going to explore some fundamental concepts of XQuery and then try out some applications.

* [01-Introduction](01-introduction.md) covers some fundamentals of XQuery.
* [02-Exploring-TEI-with-XQuery](02-Exploring-TEI-with-XQuery.md) applies what we've learned about XQuery so far to the analysis of poetry and drama.
* [03-Accessing-JSON-with-XQuery](03-Accessing-JSON-with-XQuery.md) illustrates the basics of accessing JSON with XQuery maps and arrays.
* [04-Integrating-CSV-and-JSON](04-Integrating-CSV-and-JSON.md) demonstrates how to convert between different formats like CSV, JSON, and XML.
* [05-Generating-JSON-and-CSV](05-Generating-JSON-and-CSV.md) demonstrates how to generate formats like CSV and JSON from XML.
* [06-OPDS-OpenRefine-and-IIIF](06-OPDS-OpenRefine-and-IIIF.md) demonstrates opportunities for serving data into OPDS, OpenRefine, and IIIF.

## Installation Instructions

You've got several options for an XQuery processor.

### BaseX

[BaseX](http://basex.org/) is an open source XML database. I recommend downloading the [Windows installer](http://basex.org/products/download/all-downloads/) if you're using Windows and using [Homebrew](http://brew.sh/) if you're on a Mac. The installation command is ```brew install basex```.

> Note: Installing BaseX may require that you update to Java 7. If so, install the [Java Runtime Environment (JRE)](https://java.com/en/download/) and try again.

![Screenshot of BaseX GUI](http://i.imgur.com/0HWtHdy.png)

### eXist

[eXist](http://exist-db.org/exist/apps/homepage/index.html) is another open source XML database. The latest release is [3.4.0](http://exist-db.org/exist/apps/homepage/index.html#downloads). If you are on a Mac, you can also install with Homebrew: `brew cask install exist-db`. When you run for eXist for the first time, you'll need to set configuration settings. We recommend that you accept the defaults for now. After eXist starts, navigate to eXide, its browser-based query executive engine.

![Screenshot of eXide](http://i.imgur.com/BH4kCSa.png)

### oXygen XML Editor

 If you're using the oXygen XML editor, we're assuming that you're using Saxon PE (professional edition) v. 9.7.0.15 or later and that you've turned on support for XQuery 3.0. Check your settings to make sure we'll all on the same page.

![Screenshot of oXygen Settings for XQuery](http://i.imgur.com/dsGKvOl.png)
