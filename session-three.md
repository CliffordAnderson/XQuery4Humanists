## Session Three

### Mashups and XML Databases

XQuery is a powerful language for exploring and drawing results from individual XML documents. However, its real power comes to the fore when you combine it with XML databases. In this session, we're going to explore how to use XQuery in BaseX, an open source XML database. 

### Loading CSV

A common challenge when loading data into an XML database is turning it from some other format into XML. For example, you might have data stored in Excel or perhaps a relational database like Access or MySQL. Consider, for example, the tabular data shown below.

![A CSV file on Github](http://i.imgur.com/tYLvWJ2.png)

How would we load the information in this file into BaseX? Fortunately, BaseX has you covered. There are two functions in BaseX that you can use in combination to load a CSV file and convert it to XML.  Let's try them out!

The CSV file shown above is available on [Github](https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv). First, we'll write a function to grab the text from Github and display it as a CSV. To do this, we'll use a BaseX function called [fetch:text](http://docs.basex.org/wiki/Fetch_Module#fetch:text), which just grabs the content of websites and returns them as a big string of text. So we can get the CSV with this code:
```xquery
xquery version "3.1";

let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
return $csv
```
The only complicated part of this expression is the crazy long URL for the CSV file. Otherwise, it's simple and straightforward, right? Our next step is to convert the CSV into XML. In this case, there's a function called [csv:parse](http://docs.basex.org/wiki/CSV_Module) that converts CSV files into XML files. Here's how it works.
```xquery
xquery version "3.1";

let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
let $books := csv:parse($csv)
return $books
```

Nice, right? The only problem with the output is that it's pretty generic. In particular, the entries do not differentiate between authors, titles, ISBNs, binding, and publication dates. So it would be easy to get lost when query this document, mistakenly asking for the ISBN when you actually wanted a date, for instance. 

```xml
<csv>
  <record>
    <entry>Author</entry>
    <entry>Title</entry>
    <entry>ISBN</entry>
    <entry>Binding</entry>
    <entry>Year Published</entry>
  </record>
  <record>
    <entry>Jeannette Walls</entry>
    <entry>The Glass Castle</entry>
    <entry>074324754X</entry>
    <entry>Paperback</entry>
    <entry>2006</entry>
  </record>
</csv>
```

Fixing the problem is also relatively straightforward, though you'll notice a new syntax. What's up with that strange ```map``` syntax?

```xquery
xquery version "3.1";

let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
let $books := csv:parse($csv, map {'header':'true'} )
return $books
```
The ```map {'header':'true'}``` is an [XQuery Map](http://docs.basex.org/wiki/XQuery_3.1#Maps). Maps and arrays are being introduced into XQuery primarily to handle a widely used format called JSON. (While there's more to XQuery maps than JSON compatibility, we don't need to worry about other uses here.)  JSON stands for JavaScript Object Notation. It's a lightweight format originally designed for use with JavaScript but now frequently employed to transmit information back and forth on the Internet. We'll see that kind of use in a moment. Here, however, we're using this XQuery map to provide some configuration information. The map is essentially acting like a config file for the function, telling it that the CSV has defined headers. After calling the expression with the configuration information provided by the map, we get a much more articulate result.

```xml
<csv>
  <record>
    <Author>Jeannette Walls</Author>
    <Title>The Glass Castle</Title>
    <ISBN>074324754X</ISBN>
    <Binding>Paperback</Binding>
    <Year_Published>2006</Year_Published>
  </record>
  <record>
    <Author>James Surowiecki</Author>
    <Title>The Wisdom of Crowds</Title>
    <ISBN>385721706</ISBN>
    <Binding>Paperback</Binding>
    <Year_Published>2005</Year_Published>
  </record>
</csv>
```


Not bad for a few lines of code, right? But, wait, there's more! Let's not just leave our data as is. Let's combine it with another source of data on the internet. In our next section, we'll learn a little more about JSON and how to interact with APIs that only provide JSON data.

For this example, we'll be drawing on an API (Application Programming Interface) provided by the Open Library: the [Open Library Read API](https://openlibrary.org/dev/docs/api/read). We will use this API to enrich our book information with additional details. The API allows us to pass in an ISBN and receive a whole bunch of additional information in JSON format. To do so, we just concatenate this base URL (http://openlibrary.org/api/volumes/brief/isbn/) with an ISBN and add .json to the end. For example, the ISBN of Jeannette Walls' *The Glass Castle* is 074324754X. So the URL to retrieve the JSON is http://openlibrary.org/api/volumes/brief/isbn/074324754X.json. [Try it](http://openlibrary.org/api/volumes/brief/isbn/074324754X.json) and see what you get back! Looks a little complicated right? You can actually use oXygen to 'pretty print' or format JSON. Suitably cleaned up, the JSON looks like this:

```javascript
{
    "records": {"/books/OL7928299M": {
        "recordURL": "http://openlibrary.org/books/OL7928299M/The_Glass_Castle",
        "oclcs": [],
        "publishDates": ["January 9, 2006"],
        "lccns": [],
        "details": {
            "info_url": "http://openlibrary.org/books/OL7928299M/The_Glass_Castle",
            "bib_key": "isbn:074324754X",
            "preview_url": "http://openlibrary.org/books/OL7928299M/The_Glass_Castle",
            "thumbnail_url": "https://covers.openlibrary.org/b/id/473601-S.jpg",
            "details": {
                "number_of_pages": 288,
                "subtitle": "A Memoir",
                "weight": "8.8 ounces",
                "covers": [473601],
                "latest_revision": 7,
                "first_sentence": {
                    "type": "/type/text",
                    "value": "I WAS SITTING IN a taxi, wondering if I had overdressed for the evening, when I looked out the window and saw Mom rooting through a Dumpster."
                },
                "source_records": ["amazon:074324754X:cp:4147739557:267382"],
                "title": "The Glass Castle",
                "languages": [{"key": "/languages/eng"}],
                "subjects": [
                    "Entertainment & Performing Arts - Television Personalities",
                    "Women",
                    "Personal Memoirs",
                    "Childhood Memoir",
                    "Alcohol Abuse",
                    "Family Development",
                    "United States",
                    "Biography & Autobiography",
                    "Biography / Autobiography",
                    "Literary",
                    "Biography/Autobiography",
                    "Children of alcoholics",
                    "Biography & Autobiography / Personal Memoirs",
                    "Problem families",
                    "Welch",
                    "West Virginia",
                    "Biography",
                    "Case studies"
                ],
                "type": {"key": "/type/edition"},
                "physical_dimensions": "7.9 x 5.2 x 0.8 inches",
                "revision": 7,
                "publishers": ["Scribner"],
                "physical_format": "Paperback",
                "last_modified": {
                    "type": "/type/datetime",
                    "value": "2011-08-11T17:47:59.304270"
                },
                "key": "/books/OL7928299M",
                "authors": [{
                    "name": "Jeannette Walls",
                    "key": "/authors/OL34287A"
                }],
                "classifications": {},
                "created": {
                    "type": "/type/datetime",
                    "value": "2008-04-29T15:03:11.581851"
                },
                "identifiers": {
                    "librarything": ["7903"],
                    "goodreads": ["7445"]
                },
                "isbn_13": ["9780743247542"],
                "isbn_10": ["074324754X"],
                "publish_date": "January 9, 2006",
                "works": [{"key": "/works/OL46760W"}]
            },
            "preview": "noview"
        },
        "isbns": [
            "074324754X",
            "9780743247542"
        ],
        "olids": ["OL7928299M"],
        "issns": [],
        "data": {
            "publishers": [{"name": "Scribner"}],
            "number_of_pages": 288,
            "subtitle": "A Memoir",
            "weight": "8.8 ounces",
            "title": "The Glass Castle",
            "url": "http://openlibrary.org/books/OL7928299M/The_Glass_Castle",
            "identifiers": {
                "isbn_13": ["9780743247542"],
                "openlibrary": ["OL7928299M"],
                "isbn_10": ["074324754X"],
                "goodreads": ["7445"],
                "librarything": ["7903"]
            },
            "cover": {
                "small": "https://covers.openlibrary.org/b/id/473601-S.jpg",
                "large": "https://covers.openlibrary.org/b/id/473601-L.jpg",
                "medium": "https://covers.openlibrary.org/b/id/473601-M.jpg"
            },
            "subject_places": [
                {
                    "url": "https://openlibrary.org/subjects/place:welch",
                    "name": "Welch"
                },
                {
                    "url": "https://openlibrary.org/subjects/place:west_virginia",
                    "name": "West Virginia"
                },
                {
                    "url": "https://openlibrary.org/subjects/place:united_states",
                    "name": "United States"
                },
                {
                    "url": "https://openlibrary.org/subjects/place:new_york_(state)",
                    "name": "New York (State)"
                },
                {
                    "url": "https://openlibrary.org/subjects/place:new_york",
                    "name": "New York"
                }
            ],
            "subjects": [
                {
                    "url": "https://openlibrary.org/subjects/biography",
                    "name": "Biography"
                },
                {
                    "url": "https://openlibrary.org/subjects/case_studies",
                    "name": "Case studies"
                },
                {
                    "url": "https://openlibrary.org/subjects/children_of_alcoholics",
                    "name": "Children of alcoholics"
                },
                {
                    "url": "https://openlibrary.org/subjects/problem_families",
                    "name": "Problem families"
                },
                {
                    "url": "https://openlibrary.org/subjects/poor",
                    "name": "Poor"
                },
                {
                    "url": "https://openlibrary.org/subjects/homeless_persons",
                    "name": "Homeless persons"
                },
                {
                    "url": "https://openlibrary.org/subjects/family_relationships",
                    "name": "Family relationships"
                },
                {
                    "url": "https://openlibrary.org/subjects/dysfunctional_families",
                    "name": "Dysfunctional families"
                },
                {
                    "url": "https://openlibrary.org/subjects/accessible_book",
                    "name": "Accessible book"
                },
                {
                    "url": "https://openlibrary.org/subjects/protected_daisy",
                    "name": "Protected DAISY"
                },
                {
                    "url": "https://openlibrary.org/subjects/new_york_times_bestseller",
                    "name": "New York Times bestseller"
                },
                {
                    "url": "https://openlibrary.org/subjects/nyt:paperback_nonfiction=2007-03-03",
                    "name": "nyt:paperback_nonfiction=2007-03-03"
                }
            ],
            "subject_people": [{
                "url": "https://openlibrary.org/subjects/person:jeannette_walls",
                "name": "Jeannette Walls"
            }],
            "key": "/books/OL7928299M",
            "authors": [{
                "url": "http://openlibrary.org/authors/OL34287A/Jeannette_Walls",
                "name": "Jeannette Walls"
            }],
            "publish_date": "January 9, 2006",
            "excerpts": [{
                "comment": "",
                "text": "I WAS SITTING IN a taxi, wondering if I had overdressed for the evening, when I looked out the window and saw Mom rooting through a Dumpster.",
                "first_sentence": true
            }]
        }
    }},
    "items": []
}
```

Just a short (and terminologically free) note about the syntax. The square brackets represent arrays, meaning that they contain zero to many ordered values. The curly brackets represent objects, which contain keys on the left side of the colon and values on the right side. If you are using a string as a key or value, then you must put it in quotation marks. You can read the [whole JSON specification](http://www.json.org/) in less than ten minutes.

To fetch the JSON with XQuery, we write an expression very similar to our initial expression to fetch a CSV document.

```xquery
xquery version "3.1";

let $url := "http://openlibrary.org/api/volumes/brief/isbn/074324754X.json"
let $json := fetch:text($url)
return $json
```
We can treat JSON as text but it would be easier to convert it to XML so that we can work with it in a more familiar format. XQuery 3.1 introduces a new built-in function to produce this conversion: [fn:json-to-xml](http://docs.basex.org/wiki/XQuery_3.1#fn:json-to-xml). As you see, the usage of this function is very similar to ```csv:parse```.

```xquery
xquery version "3.1";

let $url := "http://openlibrary.org/api/volumes/brief/isbn/074324754X.json"
let $json := fetch:text($url)
let $book := fn:json-to-xml($json)
return $book
````
Our next step is to join these two sources of information together. Let's write a query that converts our CSV of book data to XML, collects all the ISBNs, queries the Open Library for the subject information, and adds that information back to the XML document . Whew! Sounds complicated, right? Let's give it a shot!

We start by modifying our initial expression to get and convert the CSV of book data. But this time we won't return the data. Instead, we'll pass the ISBNs into a function that queries the Open Library for more information. 

Let's proceed step-by-step. We will build a function first that takes an ISBN and returns ```<subject>``` elements with the respective subjects as child text nodes.

```xquery

declare function local:get-subjects-by-isbn($isbn as xs:string) as element()*
{
  let $url := "http://openlibrary.org/api/volumes/brief/isbn/" || $isbn || ".json"
  let $json := fetch:text($url)
  let $book-data := fn:json-to-xml($json)
  for $subject in $book-data//xf:array[@key="subjects"]/xf:string/text()
  return element subject {$subject}
};
```

The final line converts the text nodes into elements using something called a [computed element constructor](http://www.w3.org/TR/xquery/#id-computedElements). Basically, we take a bunch of strings and wrap them into subject elements in order to include them with the other elements in our book records.

The body of the query expression looks like this:

```xquery
let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
let $books := csv:parse($csv, map {'header':'true'} )
let $records :=
  for $book in $books/csv/record
  let $subjects := local:get-subjects-by-isbn($book/ISBN/text())
  let $record := element record {($book/*, $subjects)}
return element csv {$records}
```
This expression is basically the same as our previous expression, apart from iterating through the list of books to gather the subjects for each book individually. Perhaps the only tricky thing about this expression appears in this sub-expression ```element record {($book/*, $subjects)}```. Here we are creating a new record element by combining the entry elements from the previous book element with the new subject elements we've retrieved from the Internet Archive. If you look closely at the last two lines, you'll realize that we're not actually changing the original $book document; we are just creating a copy with more information added. As we mentioned at the outset, functional languages generally avoid changing state; once you define a variable, you can't change it. Here, we get around that problem (or feature!) by generating a new CSV element combining information from both sources.

Here's the full XQuery expression:

```xquery
xquery version "3.1";

declare namespace xf = "http://www.w3.org/2005/xpath-functions";

declare function local:get-subjects-by-isbn($isbn as xs:string) as element()*
{
  let $url := "http://openlibrary.org/api/volumes/brief/isbn/" || $isbn || ".json"
  let $json := fetch:text($url)
  let $book-data := fn:json-to-xml($json)
  for $subject in $book-data//xf:array[@key="subjects"]/xf:string/text()
  return element subject {$subject}
};

let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
let $books := csv:parse($csv, map {'header':'true'} )
let $records :=
  for $book in $books/csv/record
  let $subjects := local:get-subjects-by-isbn($book/ISBN/text())
  let $record := element record {($book/*, $subjects)}
  return $record
return element csv {$records}
```
and also a resulting record with the added subject information:

```xml
 <record>
    <Author>Stefan Zweig</Author>
    <Title>Beware of Pity</Title>
    <ISBN>1590172000</ISBN>
    <Binding>Paperback</Binding>
    <Year_Published>2006</Year_Published>
    <subject>Austro-Hungarian Monarchy. Heer -- Officers -- Fiction</subject>
    <subject>World War, 1914-1918 -- Fiction</subject>
    <subject>Sympathy -- Fiction</subject>
  </record>
```

## Storing XML documents in BaseX

Our final project today will be to store our enriched bibliographic records in an XML database.

First, we need to create the database. To do this, click on "Database --> New" from the BaseX menu. When creating your database, name it "books" and leave the "Input file or directory" field empty.

![Imgur](http://i.imgur.com/JAaIPje.png)

We'll also create some indexes that we'll use a bit later in this session.

![Imgur](http://i.imgur.com/leNEhKX.png)

Now we just need to write some code to populate our database. Let's adapt the code from our example above. The main difference is that we'll return a bunch of ```record``` documents instead of a single ```csv``` document.

```xquery
xquery version "3.1";

(: Enriches book metadata with subject information and stores in BaseX database :)

declare namespace xf = "http://www.w3.org/2005/xpath-functions";

declare function local:get-subjects-by-isbn($isbn as xs:string) as element()*
{
  let $url := "http://openlibrary.org/api/volumes/brief/isbn/" || $isbn || ".json"
  let $json := fetch:text($url)
  let $book-data := fn:json-to-xml($json)
  for $subject in $book-data//xf:array[@key="subjects"]/xf:string/text()
  return element subject {$subject}
};

let $database := "books" (: Change as necessary :)
let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
let $books := csv:parse($csv, map {'header':'true'} )
for $book in $books/csv/record
let $isbn := $book/ISBN/text()
let $subjects := local:get-subjects-by-isbn($isbn)
let $record := element record {($book/*, $subjects)}
(: See http://docs.basex.org/wiki/Database_Module#db:add for more information :)
return db:add($database, $record, $isbn || ".xml") 
```

Note that the final line does the work of adding each record to the database. The function ```db:add``` takes three arguments in this case: the name of the database, the actual XML document we want to add to the database, and a filename (or URI) for the document. We create the name of the document by concatenating the ISBN with ".xml" and hoping for the best–i.e., no collisions between ISBNs.

Let's just check to make sure that we created the database properly. To bring back all the records, we can write a simple expression (assuming that we've already opened the database).

```xquery
xquery version "3.1";

//record
```

We might also count the records with another simple expression.

```xquery
xquery version "3.1";

fn:count(//record)
```

What is we wanted to look up Jeanette Walls as an author? First, let's check that she's listed as an author in some record in our database.

```xquery
xquery version "3.1"

//Author[fn:contains(., "Walls")]
```

How can we retrieve her whole record? We might, for instance, rewrite our XPath expression.

```xquery
xquery version "3.1";

/record[Author[fn:contains(., "Walls")]]
```

Alternatively, we could rewrite this expression as a FLWOR expression, now iterating explicitly over all the documents in the collection by using the ```fn:collection()``` function.

```xquery
xquery version "3.1";

for $record in fn:collection()
where $record//Author[fn:contains(., "Walls")]
return $record
```

Finally, we could also use [XQuery Full-Text](http://www.w3.org/TR/xpath-full-text-10/) to rewrite our expression in a more natural style.

```xquery
xquery version "3.1";

//record[Author contains text "Walls"]
```
Finally, we can start writing some more complex queries using different options from the XQuery Full-Text Recommendation.

```xquery
xquery version "3.1";

for $record in fn:collection()
where $record//subject/text() contains text { "Austria", "Austro-Hungarian" } any 
return $record
```

If we have more time, we can try different examples. But, to wrap up, let's also discuss how to make changes to documents. First, let's remember that XQuery does not normally allow us to update documents. To get around this problem, we can just rebuild the document, adding (or subtracting) information. For example, here's how we can add a ```cover``` element to one of our record documents using the [Internet Archive's Cover API](https://openlibrary.org/dev/docs/api/covers)

```xquery
xquery version "3.1";

(: The URL for the book covers API is http://covers.openlibrary.org/b/$key/$value-$size.jpg :)

let $cover-api := "http://covers.openlibrary.org/b/ibsn/"
let $glass-castle := //record[Title[text()="The Glass Castle"]]
let $isbn := $glass-castle/ISBN/text()
let $cover := element cover {$cover-api || $isbn || "-M.jpg"}
let $fields := $glass-castle/*
return element record {$fields, $cover}
```
However, this approach just makes a copy of our document. If we want to save the change in our database, we'll need to draw on [XQuery Update Facility](http://www.w3.org/TR/xquery-update-10/) recommendation. 

```xquery
xquery version "3.1";

(: The URL for the book covers API is http://covers.openlibrary.org/b/$key/$value-$size.jpg :)

let $cover-api := "http://covers.openlibrary.org/b/ibsn/"
let $glass-castle := //record[Title[text()="The Glass Castle"]]
let $isbn := $glass-castle/ISBN/text()
let $cover := element cover {$cover-api || $isbn || "-M.jpg"}
return insert node $cover into $glass-castle
```
In this version, we don't make a copy, we actually add a node directly to the document in the database. XQuery Update is a powerful and important addition to the XQuery set of recommendations, but it should be used with some caution since it mutates, creates, and potentially deletes data.

## Wrapping Up

I hope that you've enjoyed this brief tour of XQuery. Please [be in touch](http://www.library.vanderbilt.edu/scholarly/) if you have any questions. I'm always glad to help whenever I can.

Feel free to improve on these examples and to share your work with everyone else. The easiest way to do that is to write your expression in [Zorba](try-zorba.28.io) and then tweet out the permalink to [#prog4humanists](https://twitter.com/hashtag/prog4humanists). I look forward to seeing how you improve on my work! :)

Many thanks to [Dr. Laura Mandell](http://idhmc.tamu.edu/the-director/) and her colleagues at the [Initiative for Digital Humanities, Media, and Culture](http://idhmc.tamu.edu/) for the opportunity to lead these three sessions of her [Programming4Humanists](http://www.programming4humanists.org/) series.
