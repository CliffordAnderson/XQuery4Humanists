## Session Four

The focus of this session is on using [XQuery](https://www.w3.org/TR/xquery-31/) to explore [JSON](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf). We'll explore the array and map datatypes introduced in XQuery 3.1 along with related functions.

### Learning Outcomes

* Interact with a JSON Application Programming Interface with XQuery;
* Encode and retrieve data using XQuery arrays and maps;
* Convert JSON to XML (and vice versa).

### Introduction

### Maps and arrays

XQuery introduced two key datatypes: [Maps](https://www.w3.org/TR/xquery-31/#id-maps) and [Arrays](https://www.w3.org/TR/xquery-31/#id-arrays). While there is no intrinsic connection between maps, arrays, and JSON, making XQuery able to handle JSON was among the key motivating factors.

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
