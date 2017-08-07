## Session Six

### OPDS, OpenRefine, and IIIF

If all you want to do is copy and paste this CSV file into Microsoft Excel or a new OpenRefine project, you learned everything needed for this in the previous session. But you may wish to expose the data you've created to other applications you use on your computer, to other users on your network, or to the world wide web.

#### OPDS (and Atom)

The Open Publication Distribution System (OPDS) is a specification for a format focusing on book catalogs, especially ebook catalogs. Distributors of ebooks such as Project Gutenberg, publish their catalog in this format, as one way to facilitate access to their offerings. OPDS is supported by many ebook reader (or "ereader") apps, so if you have content in ebook format, exposing your offerings as an OPDS API endpoint is a great way to invite interested readers or researchers into your materials, particuarly on mobile devices where loading ebooks from sites besides the Kindle Store or the iBooks Store is difficult. 

OPDS is based on the Atom syndication format, so learning OPDS is 90% about Atom, and 10% about learning the OPDS extension vocabulary. Like the better known RSS format, Atom is the format used by many blogs and news sites to post their latest news. So if you don't have ebooks to publish, then you can ignore the OPDS-specific vocabulary and add Atom to your tool belt. Publishing an Atom feed of your project's latest announcements or releases is a good way to let people keep up. 

As an introduction to OPDS (and Atom), let's take a look at one OPDS API's documentation: https://history.state.gov/developer.

Interested to give OPDS a try? Search your device's app store for "OPDS", or look for apps that are popular with ebook lovers (ebibliophiles). On iOS, for example, you can choose from ShuBook, which has the Office of the Historian API pre-loaded, or other OPDS-compatible ereaders like Hyphen, Marvin. 

Now let's look at the XQuery module that produces the OPDS feeds: https://github.com/HistoryAtState/hsg-shell/blob/master/modules/opds-catalog.xql.

Exercises: 
- Copy just enough code from the module to create a basic Atom feed with a list of posts
- Extend the feed with OPDS-specific vocabulary
- Create an OPDS API endpoint that you can access with an OPDS client

#### OpenRefine Endpoint

OpenRefine is a free, open source tool for cleaning up messy data, for "data wrangling." It's perhaps most celebrated in the library & information sciences fields, but it really is useful to anyone. After all, humanities <=> messy data.

To get started creating an OpenRefine project, you'll need data in some tabular, spreadsheet-style form, like CSV or TSV. It claims to be able to load XML (and JSON) data, but in my experience, the XML loading function is not reliable. At best, the XML import function it only works for tabular-style XML records, and does not work with complexly nested XML. Thus, assuming you have some data in XML that you want to clean up, you're best served by learning how to export this data as CSV or TSV. In the last lesson, we learned how to do this with XQuery.

Once your data is in OpenRefine, you can use its tools for probing the data: faceted browsing of columns by unique values, clustering by similar values, normalizing values, batch transformations of columns. Once you've finished cleaning up your data, you'll want to get it back into XML. Various methods work, as you learned in earlier lessons you can do this with XQuery—parsing CSV into XML.

OpenRefine also can connect to remote services to augment these built-in tools and enrich your data. For example, if you have a list of authors, you might want to run these names through Library of Congress's names authority file and add a new column to your data with links to the LOC authority file entry.

OpenRefine has two methods of passing your data to remote servers:

1. Column > Add column by fetching URLs
2. Reconcile > Start Reconciling

Let's look at one website that offers an OpenRefine Reconciliation endpoint: https://history.state.gov/exist/apps/people.

Let's hook up OpenRefine to this endpoint and run it against a list of people.

Let's review the module at https://github.com/HistoryAtState/people/blob/master/modules/reconcile.xq.

Exercises:

- Install OpenRefine from openrefine.org. (On macOS, if you have [Homebrew](http://brew.sh) installed, you can install OpenRefine with `brew cask install openrefine`.
- Paste some CSV or tabular text into OpenRefine and watch the introductory videos about OpenRefine at openrefine.org
- Convert some of your XML to CSV, paste it into OpenRefine, and begin exploring. When you're done, convert the resulting TSV and back into XML.
- Create a basic web service that can respond to the "Add column by fetching URLs"; for example, your service could return the number of characters in the string passed to it, or it could look up some data in your database.
- Using reconcile.xq as a model, create a reconciliation service endpoint that exposes your data to OpenRefine clients.

#### IIIF

The International Image Interoperability Framework (IIIF) (http://iiif.io) is a collection of specifications for publishing, viewing, and annotating images on the web. It is backed by a consortium of universities and museums, stewards of vast stores of scanned images. 

What problem does IIIF solve? Until IIIF institutions had to create their own software and interface for browsing images. Users had to learn different interfaces for each site, many of which were clunky or over-engineered, and even worse for the goals of scholarship, these services did not interoperate. For example, there was no practical way for an art historian to pull up two works from different institutions in their browser for comparison, save zoom levels, annotate images, view the annotations that others created. IIIF enables projects and institutions to publish and expose their images to the internet in a much more interoperable way. 

Let's look at one site, scta.info, created by Jeffrey Witt (Loyola).

- [tbd]

Let's look at the code behind his site on GitHub:

- https://github.com/scta/scta-app/blob/master/folio-annotation-list.xq
- https://github.com/scta/scta-app/blob/master/iiif/iiifsearch-with-paging.xq

Publishing information about your images means producing a manifest in JSON LD format, a dialect of JSON for publishing Linked Data triples.

Exercises: 
- Using Jeffrey's code as a model, create a basic IIIF manifest
- Download the most recent release of Mirador (a IIIF viewer), install Cantaloupe (a IIIF image server), and create a dynamic manifest with XQuery that you can access with Mirador

Two useful sites for learning more about IIIF are:

- https://github.com/IIIF/awesome-iiif
- https://github.com/ProjectMirador/mirador-awesome