## Session Three

The focus of this session is on using [XQuery](https://www.w3.org/TR/xquery-31/) to explore [JSON](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf). We'll explore the array and map datatypes introduced in XQuery 3.1 along with related functions.

### Learning Outcomes

* Interact with a JSON Application Programming Interface with XQuery;
* Encode and retrieve data using XQuery arrays and maps;
* Convert JSON to XML (and vice versa).

### Introduction

### Maps and arrays

XQuery 3.1 introduced two new datatypes: [Maps](https://www.w3.org/TR/xquery-31/#id-maps) and [Arrays](https://www.w3.org/TR/xquery-31/#id-arrays). While there is no intrinsic connection between maps, arrays, and JSON, making XQuery able to handle JSON was among the key motivating factors for adding maps and arrays.

#### Arrays

XQuery programmers are familiar with [sequences](https://www.w3.org/TR/xquery-31/#dt-sequence), which are "ordered collection[s] of zero or more items." We deal with sequences routinely since values are always sequences, even if they're one item. Superficially, arrays resemble sequences. Like sequences, arrays hold ordered lists of items. You can build an array of items by using square brackets to surround a list of comma-delimited values.

```xquery
[1,2,3]
```

You can also build an array by using the keyword `array` and enclosing the comma-delimited values with curly braces.

```xquery
array { 1,2,3 }
```

Why arrays when we already have sequences? Arrays differ from sequences because they do not automatically "flatten." See what happens when you combine two sequences in XQuery.

```xquery
xquery version "3.1";

let $nums1 := (1,2,3)
let $nums2 := (4,5,6)
return ($nums1, $nums2)
```

This expression evaluates to the sequence: `1, 2, 3, 4, 5, 6`. The two subsequences are now a single sequence. By contrast, an array retains its subarrays.

```xquery
xquery version "3.1";

let $nums1 := array {1,2,3}
let $nums2 := array {4,5,6}
return array {$nums1, $nums2}
```

This expression produces an array with two subarrays: [[1, 2, 3], [4, 5, 6]]. This difference is crucial when working with JSON since JSON allows nested arrays.

How do you access information in arrays? Here's we come across a bigger, more fundamental difference between arrays and sequences. An array is actually a function. That is, an array is a function that returns take an integer and returns the value in that position in the array (counting from one).

```xquery
let $nums := [ 1,2,3 ]
return $nums(3)
```

Perhaps confusingly, XQuery 3.1 also added a different syntax called the lookup syntax, which uses a question mark `?` in place of the functional call parentheses.

```xquery
let $nums := [ 1,2,3 ]
return $nums?3
```

Since functions can return functions as values (i.e. XQuery has [higher-order functions](https://www.w3.org/TR/xpath-functions-31/#higher-order-functions), you can chain these look ups. Here's two examples, one using the function call syntax and the other the lookup syntax.

```xquery
array {array {1,2,3}, array {4,5,6}}(2)(3)
```

```xquery
array {array {1,2,3}, array {4,5,6}}?2?3
```

The lookup syntax may lead you to regard the `?` operator as akin to the `/` in XPath. But be careful! The resemblance is skin deep. It's not possible to use a `??` operator, for example, to search for items at any depth in arrays.

#### Maps

XQuery 3.1 also added support for maps, which are other programming languages call associative arrays or dictionaries. The basic idea of a map is that you associate a key with a value. A map can have any number of these key-value pairs. You create maps with the keyword `map` and a set of curly braces surrounding any number key-value pairs (separating the keys and the values with a colon).

```xquery
map {"Hello":"World"}
```

Unlike an array, maps are not ordered–you don't need ordering because you lookup items by the key, not by their position.

```xquery
xquery version "3.1";

let $dh := map {2016: "Krakow", 2017: "Montreal", 2018: "Mexico City" }
return $dh(2016)
```

This expression returns `"Krakow"`.

```xquery
xquery version "3.1";

let $nums1 := (1,2,3)
let $nums2 := (4,5,6)
return ($nums1, $nums2)
```

### Open Library API

Let's apply these concepts by retrieving a JSON document from a web service. We'll rely on the Internet Archive's [Open Library API](https://openlibrary.org/developers/api) in the next set of expressions. The book we want to search for is Jeremias Gotthelf's *The Black Spider*. You can send the title information to the Open Library API using this HTTP GET request: `http://openlibrary.org/search.json?title=black%20spider`. Try it in your browser.

Now let's get the same JSON document using XQuery. Let's try two approaches. The first uses a function called `fn:unparsed-text` to retrieve the JSON.

```xquery
xquery version "3.1";

fn:unparsed-text("http://openlibrary.org/search.json?title=black%20spider")
```

The second uses a function called `fn:json-doc` to get the document.

```xquery
xquery version "3.1";

fn:unparsed-text("http://openlibrary.org/search.json?title=black%20spider")
```

Try them out and take notice of the difference between the two. As you'll note, the first returns the JSON document as a text document. The second converts the JSON into XQuery maps and arrays.

### Oxford English Dictionary API

```xquery
 declare function local:title($book as xs:string, $key as xs:string) {
  let $uri := "http://openlibrary.org/search.json?title="
  let $json := fn:json-doc($uri || $book)
  return element results {
    for $item in array:flatten(map:find($json, $key))
    return element result {$item}
  }
};
```

```xquery
xquery version "3.1";

let $word := "person"
let $request :=
  <http:request href="https://od-api.oxforddictionaries.com/api/v1/entries/en/{$word}"  method="get">
    <http:header name="app_key" value="###"/>
    <http:header name="app_id" value="###"/>
  </http:request>
return http:send-request($request)
```

```xquery
xquery version "3.1";

let $word := "person"
let $request :=
  <http:request href="https://od-api.oxforddictionaries.com/api/v1/entries/en/{$word}/synonyms"  method="get">
    <http:header name="app_key" value="###"/>
    <http:header name="app_id" value="###"/>
  </http:request>
return http:send-request($request)
```

```xquery
xquery version "3.1";

declare function local:get-synonym($word as xs:string) as xs:string?
{
 let $request :=
  <http:request href="https://od-api.oxforddictionaries.com/api/v1/entries/en/{$word}/synonyms"  method="get">
    <http:header name="app_key" value="###"/>
    <http:header name="app_id" value="###"/>
  </http:request>
let $synonyms := http:send-request($request)[2]
where $synonyms/json
return ($synonyms//_/synonyms/_/id/string())[1]
};

let $sentence := fn:tokenize("I sing of arms and woman", "\W+")
let $new-words :=
  for $word in $sentence
  return local:get-synonym($word)
return fn:string-join($new-words, " ") || "."
```

```xquery
xquery version "3.1";

declare function local:lookup-word($word as xs:string, $id as xs:string, $key as xs:string) {
  let $request :=
    <http:request href="https://od-api.oxforddictionaries.com/api/v1/entries/en/{$word}"  method="get">
      <http:header name="app_key" value="{$key}"/>
      <http:header name="app_id" value="{$id}"/>
    </http:request>
  return http:send-request($request)
};

let $word := "person"
let $id := "###"
let $key := "###"
let $lookup-word := local:lookup-word(?, $id, $key)
for $definition at $num in $lookup-word($word)//definitions/_/fn:data()
return $num || ". " || $definition
```

```xquery
xquery version "3.1";

declare function local:lookup-word($word as xs:string, $id as xs:string, $key as xs:string) {
  let $request :=
    <http:request href="https://od-api.oxforddictionaries.com/api/v1/wordlist/en/registers=Rare;domains=Art"  method="get">
      <http:header name="app_key" value="{$key}"/>
      <http:header name="app_id" value="{$id}"/>
    </http:request>
  return http:send-request($request)
};

let $word := "person"
let $id := "###"
let $key := "###"
let $lookup-word := local:lookup-word(?, $id, $key)
return $lookup-word("person")
```
