##Session Three

###XML Databases

XQuery is a powerful language for exploring and drawing results from individual XML documents. However, its real power comes to the fore when you combine it with XML databases. In this session, we're going to explore how to use XQuery in BaseX, an open source XML database. 

###Loading CSV

A common challenge when loading data into an XML database is turning it from some other format into XML. For example, you might have data stored in Excel or perhaps a relational database like Access or MySQL. Consider, for example, the tabular data shown below.

[A CSV file on Github](http://i.imgur.com/tYLvWJ2.png)

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

![CSV without labelled entries](http://i.imgur.com/2k6fVoq.png)

Fixing the problem is also relatively straightforward, though you'll notice a new syntax. What's up with that strange ```map``` syntax?

```xquery
xquery version "3.1";

let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
let $books := csv:parse($csv, map {'header':'true'} )
return $books
```
The ```map {'header':'true'}``` is an [XQuery Map](http://docs.basex.org/wiki/XQuery_3.1#Maps). Maps and arrays are being introduced into XQuery primarily to handle a widely used format called JSON. (While there's more to XQuery maps than JSON compatibility, we don't need to worry about other uses here.)  JSON stands for JavaScript Object Notation. It's a lightweight format originally designed for use with JavaScript but now frequently employed to transmit information back and forth on the Internet. We'll see that kind of use in a moment. Here, however, we're using this XQuery map to provide some configuration information. The map is essentially acting like a config file for the function, telling it that the CSV has defined headers. After calling the expression with the configuration information provided by the map, we get a much more articulate result.

![CSV with headers as entries]http://i.imgur.com/jS8aNZm.png[/img]

Not bad for a few lines of code, right? But, wait, there's more! Let's not just leave our data as is. Let's combine it with another source of data on the internet. In our next section, we'll learn a little more about JSON and how to interact with APIs that only provide JSON data.

For this example, we'll be drawing on an API (Application Programming Interface) provided by the Open Library: the [Open Library Read API](https://openlibrary.org/dev/docs/api/read). We will use this API to enrich our book information with additional details. The API allows us to pass in an ISBN and receive a whole bunch of additional information in JSON format. To do so, we just concatenate this base URL (http://openlibrary.org/api/volumes/brief/isbn/) with an ISBN and add .json to the end. For example, the ISBN of Jeannette Walls' *The Glass Castle* is 074324754X. So the URL to retrieve the JSON is [http://openlibrary.org/api/volumes/brief/isbn/074324754X.json](http://openlibrary.org/api/volumes/brief/isbn/074324754X.json). Try it and see what you get back! Looks a little complicated right? You can actually use oXygen to 'pretty print' or format JSON. Suitably cleaned up, the JSON looks like this:

![JSON data about the Glass Castle](http://i.imgur.com/da92Xze.png)

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
return element csv {$records}
```
and also a resulting record with the added subject information:
![CSV record with added subject information](http://i.imgur.com/WklULX7.png)

##Wrapping Up

I hope that you've enjoyed this brief tour of XQuery. Please [be in touch](http://www.library.vanderbilt.edu/scholarly/) if you have any questions. I'm always glad to help whenever I can.

Feel free to improve on these examples and to share your work with everyone else. The easiest way to do that is to write your expression in [Zorba](try-zorba.28.io) and then tweet out the permalink to [#prog4humanists](https://twitter.com/hashtag/prog4humanists). I look forward to seeing how you improve on my work! :)

Many thanks to [Dr. Laura Mandell](http://idhmc.tamu.edu/the-director/) and her colleagues at the [Initiative for Digital Humanities, Media, and Culture](http://idhmc.tamu.edu/) for the opportunity to lead these three sessions of her [Programming4Humanists](http://www.programming4humanists.org/) series.
