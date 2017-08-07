## Session Five

### Generating JSON and CSV

In the last two sessions we learned how to access JSON and CSV, using the `fn:unparsed-text()` function to retrieve raw text files containing JSON and CSV data, as well as other functions, such as `fn:json-to-xml()` and the BaseX-specific `csv:parse()`, to parse these formats and convert them into an XML structure that can be traversed with XPath. We also learned about `fn:parse-json()` which converts a JSON string into XQuery map and array data structures that can be queried with map and array-specific functions and syntax. Lastly, recall the `fn:json-doc()` function, which conveniently combines the `fn:unparsed-text()` and `fn:parse-json()` functions, to retrieve and parse a JSON text file into the XQuery map and array structures. In this session we will learn how to generate JSON and CSV out of our data.

Having just learned how to convert JSON and CSV into formats that you can manipulate with XQuery, why would you want to convert your data back to JSON or CSV? The biggest reason is a practical one: communication. Many useful applications and web services speak these "light weight" formats, and you may want to get your data into an application for futher analysis, visualization, etc. You may also email colleagues an Excel spreadsheet with some of your data, or let them tap into your data with OpenRefine, exposing your data in a way that others can use.

### Learning Outcomes

* Learn about motivations for generating data in JSON and CSV;
* Use XQuery to generate JSON and CSV;
* Learn techniques for representing nested data in JSON and CSV;
* Learn to create queries for mock up web services that respond to requests for these formats and filter queries.

#### Generating JSON

While CSV is an older (and arguably messier) format, learning how to generate JSON will give you a very helpful foundation in the techniques needed for generating CSV.

Let's take a simple case, one of the book records we created in the last lessons and consider how we would generate a JSON representation of this file:

```xml
<record>
    <Author>Janna Levin</Author>
    <Title>A Madman Dreams of Turing Machines</Title>
    <ISBN>1400040302</ISBN>
    <Binding>Hardcover</Binding>
    <Year_Published>2006</Year_Published>
</record>
```

One way to represent this data in JSON is as follows:

```json
{
    "Author": "Janna Levin",
    "Title": "A Madman Dreams of Turing Machines",
    "ISBN": "1400040302",
    "Binding": "Hardcover",
    "Year_Published": "2006"
}
```

In other words, the `<record>` element becomes a (nameless) JSON object, which contains 5 entries—one per element, where the name of the entry is the name of the element, and the value of the entry is the string value of the element. To generate this JSON, we just need to iterate through the elements and create an XQuery map with one entry per element. Once we have a map that looks right, we'll apply the final touch—*serialization*—to turn the map into JSON.

```xquery
let $record :=
    <record>
        <Author>Janna Levin</Author>
        <Title>A Madman Dreams of Turing Machines</Title>
        <ISBN>1400040302</ISBN>
        <Binding>Hardcover</Binding>
        <Year_Published>2006</Year_Published>
    </record>
for $element in $record/*
let $name := $element/name()
let $value := $element/string()
return
    map { $name: $value }
```

Run this query, and you'll notice we have actually generated a sequence of 5 separate maps (one entry per map) instead of one map with 5 entries:

```xquery
(
    map {
        "Author": "Janna Levin"
    },
    map {
        "Title": "A Madman Dreams of Turing Machines"
    },
    map {
        "ISBN": "1400040302"
    },
    map {
        "Binding": "Hardcover"
    },
    map {
        "Year_Published": "2006"
    }
)
```

To merge these 5 entries into a single map, we will use the `map:merge()` function:

```xquery
let $record :=
    <record>
        <Author>Janna Levin</Author>
        <Title>A Madman Dreams of Turing Machines</Title>
        <ISBN>1400040302</ISBN>
        <Binding>Hardcover</Binding>
        <Year_Published>2006</Year_Published>
    </record>
return
    map:merge(
        for $element in $record/*
        let $name := $element/name()
        let $value := $element/string()
        return
            map { $name: $value }
    )
```

This returns the desired result:

```xquery
map {
    "Author": "Janna Levin",
    "Title": "A Madman Dreams of Turing Machines",
    "ISBN": "1400040302",
    "Binding": "Hardcover",
    "Year_Published": "2006"
}
```

(Did your results appear in a different order than these? This is because XQuery maps, like JSON objects, do not guarantee the order of their entries. XQuery arrays, like JSON arrays (and all XML nodes except attributes), do guarantee their order. But in a book database record, is it really critical to preserve the order of these entries? If you think so, try changing the query to generate an array instead.)

Once we've succeeded in generating an XQuery map/array representation of our data, then all we need to generate the JSON representation of this data is to *serialize* , or write out, the results as JSON. To do this we could use the `fn:serialize()` function (see https://www.w3.org/TR/xpath-functions-31/#func-serialize). This function takes two parameters: the data to serialize, and an optional set of serialization parameters, in the form of an `<output:serialization-parameters>` element.

```xquery
xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

let $record :=
    <record>
        <Author>Janna Levin</Author>
        <Title>A Madman Dreams of Turing Machines</Title>
        <ISBN>1400040302</ISBN>
        <Binding>Hardcover</Binding>
        <Year_Published>2006</Year_Published>
    </record>
let $pre-json
    map:merge(
        for $element in $record/*
        let $name := $element/name()
        let $value := $element/string()
        return
            map { $name: $value }
    )
let $serialization-parameters :=
    <output:serialization-parameters>
        <output:media-type>json</output:media-type>
    </output:serialization-parameters>
return
    fn:serialize($pre-json, $serialization-parameters)
```

This should return the desired JSON string, but depending on your XQuery implementation's serialization defaults, you may see a scrunched result:

```json
{"Binding":"Hardcover","Author":"Janna Levin","Year_Published":"2006","ISBN":"1400040302","Title":"A Madman Dreams of Turing Machines"}
```

To apply indentation to these results, add the following element as a child to your `<serialization-parameters>` element:

```xml
<output:indent>yes</output:indent>
```

If this serialization parameters syntax strikes you as excessively verbose, let's learn the other method for serializing your results: declaring the serialization options in your query's prolog. 

```xquery
xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";

let $record :=
    <record>
        <Author>Janna Levin</Author>
        <Title>A Madman Dreams of Turing Machines</Title>
        <ISBN>1400040302</ISBN>
        <Binding>Hardcover</Binding>
        <Year_Published>2006</Year_Published>
    </record>
return
    map:merge(
        for $element in $record/*
        let $name := $element/name()
        let $value := $element/string()
        return
            map { $name: $value }
    )
```

By declaring our serialization options in the prolog, as this version does, our query can now directly return the `map`. This feels more elegant and can make your code easier to read. But it also has an added benefit in the context of XQuery implementations that can perform the functions of a web server, as BaseX and eXist can do, serving their content to browsers and clients over the web: When you use `fn:serialize()`, your XQuery implementation has already applied a default media-type to the results of your query, typically `application/xml`. This means that even if your query generates JSON, your XQuery processor may be telling remote clients to expect something else, typically XML. (This is a natural default for an XQuery implementation the `output:media-type` declaration can tell browsers fetching this page to treat the your server's response as JSON, rather than simply text (or XML, since in the absence of such a declaration, many XQuery implementations default to emitting a media-type of `application/xml`—which can throw off clients that are looking for an indication that they are loading JSON). In other words, using this prolog-based approach to serialization is good when you begin to expose your data as a web service. 

As one last improvement to our query, let's add handling for the `<subject>` elements that we enriched our book data with in the last lesson:

```xml
<record>
    <Author>Janna Levin</Author>
    <Title>A Madman Dreams of Turing Machines</Title>
    <ISBN>1400040302</ISBN>
    <Binding>Hardcover</Binding>
    <Year_Published>2006</Year_Published>
    <subject>Gödel, Kurt.</subject>
    <subject>Turing, Alan Mathison, 1912-1954.</subject>
    <subject>Mathematicians -- Great Britain -- Biography.</subject>
    <subject>Mathematicians -- Austria -- Biography.</subject>
</record>
```

Our query will run just fine on this data, but you will notice that we only end up with one `subject` entry in the results—even before we've turned our map into a JSON object. Why? This is because a rule for XQuery maps (and JSON objects) is that entry names must be unique in a map (object). When we merge the entries together with `map:merge()`, XQuery does the best thing, short of emitting an error, and trims all but the first of the `subject` objects from the results. 

How should we account for this rule about entry name uniqueness? There are a few options, but let's make use of XQuery's support of arrays to join all of the subject values together in an array, and make this array the value of the `subject` object. 
That's a mouthful, but all we're saying is that we'd like our `subject` entry to look like this (with a little extra indentation added for readability):

```json
"subject": 
    [
        "Gödel, Kurt.",
        "Turing, Alan Mathison, 1912-1954.",
        "Mathematicians -- Great Britain -- Biography.",
        "Mathematicians -- Austria -- Biography."
    ]
```

Changing our query to produce arrays like this is not that hard. We'll just use the `group by` clause to group all of the elements by name (thereby gathering all of the `<subject>` elements together), and generate an array for the case of elements like `<subject>` that have multiple instances:

```xquery
xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";

let $record :=
    <record>
        <Author>Janna Levin</Author>
        <Title>A Madman Dreams of Turing Machines</Title>
        <ISBN>1400040302</ISBN>
        <Binding>Hardcover</Binding>
        <Year_Published>2006</Year_Published>
        <subject>Gödel, Kurt.</subject>
        <subject>Turing, Alan Mathison, 1912-1954.</subject>
        <subject>Mathematicians -- Great Britain -- Biography.</subject>
        <subject>Mathematicians -- Austria -- Biography.</subject>        
    </record>
return
    map:merge(
        for $element in $record/*
        let $name := $element/fn:name()
        let $value := $element/fn:string()
        group by $name
        return
            if (count($element) gt 1) then
                map { $name: array { $value } }
            else
                map { $name: $value }            
    )
```

This returns the desired record we're after:

```json
{
    "Binding": "Hardcover",
    "Author": "Janna Levin",
    "Year_Published": "2006",
    "subject": [
        "Gödel, Kurt.",
        "Turing, Alan Mathison, 1912-1954.",
        "Mathematicians -- Great Britain -- Biography.",
        "Mathematicians -- Austria -- Biography."
    ],
    "ISBN": "1400040302",
    "Title": "A Madman Dreams of Turing Machines"
}
```

Exercise: Strip the underscores back out of the entry names, replacing them with the original spaces.

Exercise: Using `let $books := collection("books")/record`, extend this query to generate an array of all book records.

#### Generating CSV

Now that we have learned about generating maps and arrays and serializing them as JSON, doing the same with CSV is actually quite straightforward. Instead of map entries, we'll be generating spreadsheet-style data, whose first row is an array of headers and whose body rows are also simple arrays. The biggest difference is that XQuery doesn't have a built-in serialization method for CSV, so we'll need to use string functions to format the CSV properly.

Let's start by gathering our header rows. Assuming we've already defined our `$records` variable as the collection of books, we can derive the headers from the first book as follows:

```xquery
let $books := collection("books")/record
let $header-row := array { $books[1]/*/fn:name() => fn:distinct-values() }
return
    $header-row
```

We apply `fn:distinct-values()` here to account for the multiple `<subject>` elements; we'll keep returning to this, since nested structures that XML handles so readily are inherently more difficult to stuff into tabular data. 

Our `$header-row` variable returns the following array:

```xquery
["Author", "Title", "ISBN", "Binding", "Year_Published", "subject"]
```

To generate our body rows, we need to slot the data from our records into the correct slot:

```xquery
let $books := collection("books")/record
let $headers-row := array { $books[1]/*/name() => fn:distinct-values() }
let $body-rows := 
    for $book in $books
    return
        array {
            for $header in $headers-row?*
            let $values := $book/*[fn:name() = $header]
            return
                if (count($values) gt 1) then 
                    array { $values ! ./string() }
                else
                    $values/string()
        }
return
    $body-rows
```

The row for Levin's book should appear in the same order as the header rows above:

```xquery
[
    "Janna Levin", 
    "A Madman Dreams of Turing Machines", 
    "1400040302", 
    "Hardcover", 
    "2006", 
    [
        "Gödel, Kurt.", 
        "Turing, Alan Mathison, 1912-1954.", 
        "Mathematicians -- Great Britain -- Biography.", 
        "Mathematicians -- Austria -- Biography."
    ]
]
```

Now we have our records in exactly the form we need to generate the CSV. We'll replace the `return` clause above with the following:

```xquery
let $all-rows := ($header-row, $body-rows)
return
    local:prepare-csv($all-rows)
```

We're going to put our CSV serialization routine into a new function, since we're confident we'll use it again for other projects:

```xquery
declare function local:prepare-csv($rows as array(*)*) as xs:string {
    let $row-separator := "&#10;"     (: we'll put each row on a new line :)
    let $cell-separator := ","        (: we'll separate our values into cells :)
    let $intra-cell-separator := ";"  (: we'll separate multi-valued cells :)
    let $quote-cells-containing-separator := 
        function($cell) { 
            if (fn:contains($cell, $intra-cell-separator)) then 
                fn:concat('"', $cell, '"') 
            else 
                $cell
        }                
    let $csv-rows :=
        for $row in $rows
        let $cells := 
            for $cell in $row?*
            return
                (
                    if ($cell instance of array(*)) then
                        fn:string-join($cell?*, $intra-cell-separator)
                    else
                        $cell
                )
                =>
                $quote-cells-containing-separator()
        return
            fn:string-join($cells, $cell-separator)
    return
        fn:string-join($csv-rows, $row-separator)
};
```

Let's peel this function's nested FLWOR expressions apart like an onion:

1. Starting from the last `return` clause, the function takes all of the rows and joins them together, each row separated by a newline character.
2. The `$csv-rows` variable generates the rows, consisting of a string of comma-separated cells
3. The `$cells` variable prepares the cells in the row, surrounding them with quotes if they contain a comma
4. Each `$cell` is examined for multi-value arrays; the values are joined with a semi-colon and returned as a string

Or you may prefer to read this in reverse order, from cell to cells to row to rows to document.

Finally, we need to think about how to declare our serialization options: Instead of the `json` method, we'll use the `text` method. With the `text` method, the `indent` option has no effect, but the `media-type` option will inform browsers to expect a CSV file instead of an XML, JSON, or other file. Placing these options in our prolog, our query will look like this:

```xquery
declare function local:prepare-csv($rows as array(*)*) as xs:string {
    let $row-separator := "&#10;"     (: we'll put each row on a new line :)
    let $cell-separator := ","        (: we'll separate our values into cells :)
    let $intra-cell-separator := ";"  (: we'll separate multi-valued cells :)
    let $quote-cells-containing-separator := 
        function($cell) { 
            if (fn:contains($cell, $intra-cell-separator)) then 
                fn:concat('"', $cell, '"') 
            else 
                $cell
        }                
    let $csv-rows :=
        for $row in $rows
        let $cells := 
            for $cell in $row?*
            return
                (
                    if ($cell instance of array(*)) then
                        fn:string-join($cell?*, $intra-cell-separator)
                    else
                        $cell
                )
                =>
                $quote-cells-containing-separator()
        return
            fn:string-join($cells, $cell-separator)
    return
        fn:string-join($csv-rows, $row-separator)
};

let $books := collection("books")/record
let $headers-row := array { $books[1]/*/name() => fn:distinct-values() }
let $body-rows := 
    for $book in $books
    return
        array {
            for $header in $headers-row?*
            let $values := $book/*[fn:name() = $header]
            return
                if (count($values) gt 1) then 
                    array { $values ! ./string() }
                else
                    $values/string()
        }
let $all-rows := ($headers-row, $body-rows)
return
    local:prepare-csv($all-rows)
```

Exercise: Add a parameter to your `prepare-csv()` function to take a different cell separator character, such as a tab character (`&#10`). Unlike commas, tabs are rarely used in the body of cells, so tab-separated value (TSV) files often cause less headaches than CSV files.

Exercise: Create a new function that can take a `$format` parameter that is either `csv`, `json`, or `xml` and serializes the results of the report accordingly.

Exercise: Add an `$author` parameter to the function that filters the books to return just those that contain the value passed to it.
