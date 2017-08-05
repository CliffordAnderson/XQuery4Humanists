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
[1, 2, 3]
```

You can also build an array by using the keyword `array` and enclosing the comma-delimited values with curly braces.

```xquery
array { 1, 2, 3 }
```

Why arrays when we already have sequences? Arrays differ from sequences because they do not automatically "flatten." See what happens when you combine two sequences in XQuery.

```xquery
xquery version "3.1";

let $nums1 := (1, 2, 3)
let $nums2 := (4, 5, 6)
return ($nums1, $nums2)
```

This expression evaluates to the sequence: `1, 2, 3, 4, 5, 6`. The two subsequences are now a single sequence. By contrast, an array retains its subarrays.

```xquery
xquery version "3.1";

let $nums1 := array {1, 2, 3}
let $nums2 := array {4, 5, 6}
return array { $nums1, $nums2 }
```

This expression produces an array with two subarrays: [[1, 2, 3], [4, 5, 6]]. This difference is crucial when working with JSON since JSON allows nested arrays.

How do you access information in arrays? Here's we come across a bigger, more fundamental difference between arrays and sequences. An array is actually a function. That is, an array is a function that returns take an integer and returns the value in that position in the array (counting from one).

```xquery
let $nums := [ 4, 5, 6 ]
return $nums(3)
```

Perhaps confusingly, XQuery 3.1 also added a different syntax called the lookup syntax, which uses a question mark `?` in place of the functional call parentheses.

```xquery
let $nums := [ 4, 5, 6 ]
return $nums?3
```

Since functions can return functions as values (i.e. XQuery has [higher-order functions](https://www.w3.org/TR/xpath-functions-31/#higher-order-functions), you can chain these look ups. Here's two examples, one using the function call syntax and the other the lookup syntax.

```xquery
array { array { 1, 2, 3 }, array { 4, 5, 6 } }(2)(3)
```

```xquery
array { array { 1, 2, 3 }, array { 4, 5, 6 } }?2?3
```

#### Maps

XQuery 3.1 also added support for maps, which other programming languages call *associative arrays* or *dictionaries*. The basic idea of a map is that you associate a key with a value. A map can have any number of these key-value pairs. You create maps with the keyword `map` and a set of curly braces surrounding any number key-value pairs (separating the keys and the values with a colon).

```xquery
map { "Hello": "World" }
```

Unlike an array, maps are not ordered–you don't need ordering because you lookup items by the key, not by their position.

```xquery
xquery version "3.1";

let $dh := map { 2016: "Krakow", 2017: "Montreal", 2018: "Mexico City" }
return $dh(2016)
```

This expression returns `"Krakow"`. You could also accomplish the same thing with `$dh?2016`.

Now that you understand how to explore arrays and maps in XQuery, let's try something practical. Can you pull the lattitude and longitude from this expression? 

```xquery
[ map { "title": "Nashville", "location_type": "City", "woeid": 2457170, "latt_long": "36.167839,-86.778160" } ]
``` 

Try to do so using both syntaxes.

Here's something a bit harder and more practical. Can you pull out the weather prediction for Montreal on August 6th, 2017? (If you want to work ahead, try using the [MetaWeather API](https://www.metaweather.com/api/) to fetch the latest weather predication for [Montreal](https://www.metaweather.com/api/location/3534/).) Note that you should use an asterisk operator `*` to filter out irrelevant dates.

```xquery
map {
  "location_type": "City",
  "latt_long": "45.512402,-73.554680",
  "woeid": 3534,
  "parent": map {
    "location_type": "Country",
    "latt_long": "56.954681,-98.308968",
    "woeid": 2.3424775E7,
    "title": "Canada"
  },
  "time": "2017-08-01T17:32:55.148360-04:00",
  "sun_set": "2017-08-01T20:23:14.242979-04:00",
  "consolidated_weather": [map {
    "min_temp": 17.035,
    "the_temp": 25.456666666666667,
    "weather_state_name": "Clear",
    "wind_direction": 231.91433814959555,
    "created": "2017-08-01T20:31:42.679970Z",
    "weather_state_abbr": "c",
    "applicable_date": "2017-08-01",
    "max_temp": 27.201666666666668,
    "wind_speed": 2.9784527033736317,
    "predictability": 68,
    "visibility": 14.331615863357989,
    "humidity": 60,
    "air_pressure": 1020.87,
    "id": 5.843469427802112E15,
    "wind_direction_compass": "SW"
  }, map {
    "min_temp": 18.228333333333335,
    "the_temp": 27.570000000000004,
    "weather_state_name": "Light Rain",
    "wind_direction": 213.57215491748534,
    "created": "2017-08-01T20:31:44.861460Z",
    "weather_state_abbr": "lr",
    "applicable_date": "2017-08-02",
    "max_temp": 28.59,
    "wind_speed": 5.069522435536467,
    "predictability": 75,
    "visibility": 14.586688737771414,
    "humidity": 64,
    "air_pressure": 1018.7950000000001,
    "id": 6.241265003790336E15,
    "wind_direction_compass": "SSW"
  }, map {
    "min_temp": 19.21666666666667,
    "the_temp": 26.396666666666665,
    "weather_state_name": "Heavy Rain",
    "wind_direction": 222.66886823871724,
    "created": "2017-08-01T20:31:47.821430Z",
    "weather_state_abbr": "hr",
    "applicable_date": "2017-08-03",
    "max_temp": 27.584999999999997,
    "wind_speed": 4.738741884273177,
    "predictability": 77,
    "visibility": 10.970929770142368,
    "humidity": 73,
    "air_pressure": 1020.415,
    "id": 6.505014931488768E15,
    "wind_direction_compass": "SW"
  }, map {
    "min_temp": 18.593333333333334,
    "the_temp": 25.176666666666666,
    "weather_state_name": "Heavy Rain",
    "wind_direction": 151.74995077654145,
    "created": "2017-08-01T20:31:50.779730Z",
    "weather_state_abbr": "hr",
    "applicable_date": "2017-08-04",
    "max_temp": 27.485,
    "wind_speed": 7.570432420933748,
    "predictability": 77,
    "visibility": 13.030153901216893,
    "humidity": 68,
    "air_pressure": 1006.935,
    "id": 5.8900021772288E15,
    "wind_direction_compass": "SSE"
  }, map {
    "min_temp": 16.363333333333333,
    "the_temp": 22.643333333333334,
    "weather_state_name": "Light Rain",
    "wind_direction": 221.906937590431,
    "created": "2017-08-01T20:31:53.661730Z",
    "weather_state_abbr": "lr",
    "applicable_date": "2017-08-05",
    "max_temp": 22.628333333333334,
    "wind_speed": 12.004989874707706,
    "predictability": 75,
    "visibility": 13.905665911079296,
    "humidity": 70,
    "air_pressure": 1001.025,
    "id": 5.746887705493504E15,
    "wind_direction_compass": "SW"
  }, map {
    "min_temp": 14.505,
    "the_temp": 17.994999999999997,
    "weather_state_name": "Heavy Cloud",
    "wind_direction": 245.85415735440387,
    "created": "2017-08-01T20:31:57.572460Z",
    "weather_state_abbr": "hc",
    "applicable_date": "2017-08-06",
    "max_temp": 21.528333333333336,
    "wind_speed": 7.64771709218166,
    "predictability": 71,
    "visibility": (),
    "humidity": 61,
    "air_pressure": 990.66,
    "id": 5.717722449051648E15,
    "wind_direction_compass": "WSW"
  }],
  "timezone_name": "LMT",
  "title": "Montréal",
  "sources": [map {
    "slug": "bbc",
    "url": "http://www.bbc.co.uk/weather/",
    "crawl_rate": 180,
    "title": "BBC"
  }, map {
    "slug": "forecast-io",
    "url": "http://forecast.io/",
    "crawl_rate": 480,
    "title": "Forecast.io"
  }, map {
    "slug": "hamweather",
    "url": "http://www.hamweather.com/",
    "crawl_rate": 360,
    "title": "HAMweather"
  }, map {
    "slug": "met-office",
    "url": "http://www.metoffice.gov.uk/",
    "crawl_rate": 180,
    "title": "Met Office"
  }, map {
    "slug": "openweathermap",
    "url": "http://openweathermap.org/",
    "crawl_rate": 360,
    "title": "OpenWeatherMap"
  }, map {
    "slug": "wunderground",
    "url": "https://www.wunderground.com/?apiref=fc30dc3cd224e19b",
    "crawl_rate": 720,
    "title": "Weather Underground"
  }, map {
    "slug": "world-weather-online",
    "url": "http://www.worldweatheronline.com/",
    "crawl_rate": 360,
    "title": "World Weather Online"
  }, map {
    "slug": "yahoo",
    "url": "http://weather.yahoo.com/",
    "crawl_rate": 180,
    "title": "Yahoo"
  }],
  "timezone": "America/Montreal",
  "sun_rise": "2017-08-01T05:38:23.221323-04:00"
}
```

Assuming we've bound this map to a variable `$weather`, the solution is `$weather("consolidated_weather")?*[.("applicable_date") eq "2017-08-06"]("weather_state_name")`. The use of the lookup operator may lead you to regard the `?` operator as akin to the `/` in XPath. But be careful! The resemblance is skin deep. It's not possible to use a `??` operator, for example, to search for items at any depth in arrays (along the lines of XPath's `//` operator). There is, however, a function call `map:find()` that will find keys that match at any arbitrary position in a map/array data structure. Can you use it to rewrite the solution above?

> Note for eXist users: As of eXist 3.4.0, the `map:find()` function has not yet been implemented. 

### Open Library API

Let's apply these concepts by retrieving a JSON document from a web service. We'll rely on the Internet Archive's [Open Library API](https://openlibrary.org/developers/api) in the next set of expressions. The book we want to search for is Jeremias Gotthelf's *The Black Spider*. You can send the title information to the Open Library API using this HTTP GET request: `http://openlibrary.org/search.json?title=black%20spider`. Try it in your browser.

Now let's get the same JSON document using XQuery. Let's try two approaches. The first is to use a function called `fn:unparsed-text()` to retrieve the JSON as plain text.

```xquery
xquery version "3.1";

fn:unparsed-text("http://openlibrary.org/search.json?title=black%20spider")
```

> Note for eXist users: As of eXist 3.4.0, the `fn:unparsed-text()` function has not yet been implemented. See [this gist](https://gist.github.com/joewiz/5c72163bf647f3fda7a945ae96a94deb) for an eXist-compatible implementation of this function and its variants, `fn:unparsed-text-lines()` and `fn:unparsed-text-available()`. Luckily, eXist 3.4.0 supports the function introduced next, which is the best way to retrieve JSON!

The second approach is to use a function called `fn:json-doc()` to get the document.

```xquery
xquery version "3.1";

fn:json-doc("http://openlibrary.org/search.json?title=black%20spider")
```

Try these two approaches out and take notice of the difference between the two. As you'll note, the first returns the JSON document as a text document. The second converts the JSON into XQuery maps and arrays. What if you want to convert your JSON into XML? You could write XQuery code to parse the string returned from the first expression or to convert the maps and array structure of the second expression in XML. But I'm glad to report there is an easier way: `fn:json-to-xml()`. 

```xquery
version "3.1";

fn:unparsed-text("http://openlibrary.org/search.json?title=black%20spider") => fn:json-to-xml()
```

> Note for eXist users: As of eXist 3.4.0, this function and its close cousin `fn:xml-to-json()` have not yet been implemented. See [this gist](https://gist.github.com/joewiz/d986da715facaad633db) for an eXist-compatible implementation of these functions.

If you need to serialize JSON to XML, there's a function for that too: `fn:xml-to-json()`. Howevever, you cannot pass arbitrary XML to this function; doing so would return an error:

```xquery
xquery version "3.1";

let $doc :=
  <workshops>
    <xquery>
      <leader institution="Vanderbilt">Cliff</leader>
      <leader institution="State">Joe</leader>
    </xquery>
  </workshops>
return fn:xml-to-json($doc)
```

To convert this document into JSON, you'll need to apply the [template rules](https://www.w3.org/TR/xslt-30/#json-to-xml-mapping) for writing convertible XML. As an exercise, try writing an XQuery to convert the XML document above to JSON. Here's [my answer](https://gist.github.com/CliffordAnderson/c174928e43e7d4ab9115a4dadd68c74e) when you're ready to check.

If you want to convert maps/arrays to JSON, then you'll need to wrote a more complex query. For an example of a function that does this, see [this gist](https://gist.github.com/joewiz/d986da715facaad633db) by Joe.

### Oxford English Dictionary API

Our final project today will be to read an entry from the [Oxford English Dictionary API](https://developer.oxforddictionaries.com/) and convert it from JSON to XML. To try out these exercises, you'll need to sign up for an account to get an API ID & Key. Register for the free plan via the URL above, click on "Credentials," and create a new app. Make a note of the "Application ID" and the "Application Key" for use in the examples below. 

We're going to need a different technique to access this API, because we need to authenticate our requests. Specifically, we need a way to supply authentication "headers" with each request we make to the API. To do this we'll be using the [EXPath HTTP Client Module](http://expath.org/spec/http-client), one of the many modules created by the EXPath community to supplement the built-in functions in the XQuery (and XPath) specification and foster cross-implementation-compatible code. (Most XQuery implementations, including BaseX and eXist, have their own native modules for making HTTP requests, but the code for one wouldn't work in the other without modifications. The EXPath HTTP Client module makes your code compatible in both.) 

The following simple demonstration of the HTTP Client Module sends our application key and ID along with a request for a word (in this case, "person").

```xquery
xquery version "3.1";

import module namespace http = "http://expath.org/ns/http-client";

let $word := "person"
let $url := "https://od-api.oxforddictionaries.com/api/v1/entries/en/" || $word
let $request :=
  <http:request href="{$url}" override-media-type="text/plain" method="get">
    <http:header name="app_id" value="####"/>
    <http:header name="app_key" value="####"/>
  </http:request>
return http:send-request($request)
```

We get back a JSON document in textual form.

```json
{
    "metadata": {"provider": "Oxford University Press"},
    "results": [{
        "id": "person",
        "language": "en",
        "lexicalEntries": [{
            "entries": [{
                "etymologies": ["Middle English: from Old French persone, from Latin persona \u2018actor's mask, character in a play\u2019, later \u2018human being\u2019"],
                "grammaticalFeatures": [{
                    "text": "Singular",
                    "type": "Number"
                }],
                "homographNumber": "000",
                "notes": [{
                    "text": "The words people and persons can both be used as the plural of person, but they have slightly different connotations. People is by far the commoner of the two words and is used in most ordinary contexts: a group of people; there were only about ten people; several thousand people have been rehoused. Persons, on the other hand, tends now to be restricted to official or formal contexts, as in this vehicle is authorized to carry twenty persons; no persons admitted without a pass",
                    "type": "editorialNote"
                }],
                "senses": [
                    {
                        "definitions": ["a human being regarded as an individual"],
                        "examples": [
                            {"text": "she is a person of astonishing energy"},
                            {"text": "the porter was the last person to see her prior to her disappearance"}
                        ],
                        "id": "m_en_gbus0768650.009",
                        "subsenses": [
                            {
                                "definitions": ["(in legal or formal contexts) an unspecified individual"],
                                "examples": [
                                    {"text": "each of the persons using unlawful violence is guilty of riot"},
                                    {"text": "the entrance fee is £2.00 per person"}
                                ],
                                "id": "m_en_gbus0768650.013"
                            },
                            {
                                "definitions": ["an individual characterized by a preference or liking for a specified thing"],
                                "examples": [{"text": "she's not a cat person"}],
                                "id": "m_en_gbus0768650.018",
                                "notes": [{
                                    "text": "with modifier",
                                    "type": "grammaticalNote"
                                }]
                            },
                            {
                                "definitions": ["a character in a play or story"],
                                "examples": [{"text": "his previous roles in the person of a fallible cop"}],
                                "id": "m_en_gbus0768650.021"
                            },
                            {
                                "definitions": ["an individual's body"],
                                "examples": [{"text": "I would have publicity photographs on my person at all times"}],
                                "id": "m_en_gbus0768650.022"
                            },
                            {
                                "definitions": ["(especially in legal contexts) used euphemistically to refer to a man's genitals."],
                                "id": "m_en_gbus0768650.023",
                                "registers": ["dated"]
                            }
                        ]
                    },
                    {
                        "definitions": ["a category used in the classification of pronouns, possessive determiners, and verb forms, according to whether they indicate the speaker (first person), the addressee (second person), or a third party (third person)."],
                        "domains": ["Grammar"],
                        "id": "m_en_gbus0768650.025"
                    },
                    {
                        "definitions": ["each of the three modes of being of God, namely the Father, the Son, or the Holy Ghost, who together constitute the Trinity."],
                        "domains": ["Theology"],
                        "id": "m_en_gbus0768650.031"
                    }
                ]
            }],
            "language": "en",
            "lexicalCategory": "Noun",
            "pronunciations": [{
                "audioFile": "http://audio.oxforddictionaries.com/en/mp3/person_gb_1_8.mp3",
                "dialects": ["British English"],
                "phoneticNotation": "IPA",
                "phoneticSpelling": "ˈpəːs(ə)n"
            }],
            "text": "person"
        }],
        "type": "headword",
        "word": "person"
    }]
}
```

As an exercise, can you parse the result of this API call into XQuery maps and arrays and then return only the part of the data structure containing the senses? Check your work [against my expression](code/senses.xqy). Let's build on this example to produce a formatted list of definitions. In this case, we'll find all the values of "definition" keys and then iterate through the resulting array to format the result. 

```xquery
xquery version "3.1";

declare namespace http = "http://expath.org/ns/http-client";

declare function local:lookup-word($word as xs:string, $id as xs:string, $key as xs:string) as map(*) {
  let $url := "https://od-api.oxforddictionaries.com/api/v1/entries/en/" || $word
  let $request :=
    <http:request href="{$url}" override-media-type="text/plain" method="get">
      <http:header name="app_id" value="{$id}"/>
      <http:header name="app_key" value="{$key}"/>
    </http:request>
  return http:send-request($request)[2] => fn:parse-json()
};

let $word := "person"
let $id := "####"
let $key := "####"
let $lookup-word := local:lookup-word(?, $id, $key)
let $definitions := map:find($lookup-word($word), "definitions")
for $definition at $num in 1 to array:size($definitions)
return $num || ". " || $definitions($definition)
```

This expression produces a nice list of definitions of "person".

```txt
1. a human being regarded as an individual
2. (in legal or formal contexts) an unspecified individual
3. an individual characterized by a preference or liking for a specified thing
4. a character in a play or story
5. an individual's body
6. (especially in legal contexts) used euphemistically to refer to a man's genitals.
7. a category used in the classification of pronouns, possessive determiners, and verb forms, according to whether they indicate the speaker (first person), the addressee (second person), or a third party (third person).
8. each of the three modes of being of God, namely the Father, the Son, or the Holy Ghost, who together constitute the Trinity.
```

The extra work of finding the size of the array and iterating through its members is actually not necessary when we use the alternative lookup syntax. Can you rewrite this example with the lookup syntax?

In this final set of examples, we will find synonyms for every word in a sentence. We'll make the result into an XML document with the original sentence plus the converted sentence. First, let's call the OED API for synonyms. We'll then use `map:find()` to drill down to the synonyms and a lookup expression to pull out the values of the `text` map.

```xquery
xquery version "3.1";

declare namespace http = "http://expath.org/ns/http-client";

let $word := "person"
let $request :=
  <http:request href="https://od-api.oxforddictionaries.com/api/v1/entries/en/{$word}/synonyms" override-media-type="text/plain" method="get">
    <http:header name="app_key" value="####"/>
    <http:header name="app_id" value="####"/>
  </http:request>
let $synonyms := 
   http:send-request($request)[2]
   => fn:parse-json()
   => map:find("synonyms")
return $synonyms?1?*?text
```

This query produces a list of the possible synonyms. 

```txt
human being
individual
man
woman
human
being
living soul
soul
mortal
creature
fellow
```

Now we'll use a random number generator (`fn:random-number-generator()`) to generate a random number. We should pause here to look at this function carefully since it's a higher-order function, meaning in this case that it returns a function that returns a function that then returns a value: `fn:head(fn:random-number-generator()("permute")(1 to $count))`. Got it? We also need to check the HTTP headers to see whether we receive a 404 or a 200. If we receive a 404, we'll return the original word. If not, we'll return a random synonym.

> Note for eXist users: As of version 3.4.0, the `fn:random-number-generator()` function is not yet implemented. eXist's native `util:random()` can serve a similar purpose.

```xquery
xquery version "3.1";

declare namespace http = "http://expath.org/ns/http-client";

declare function local:get-synonym($word as xs:string) as xs:string?
{
let $request :=
  <http:request href="https://od-api.oxforddictionaries.com/api/v1/entries/en/{$word}/synonyms" override-media-type="text/plain" method="get">
    <http:header name="app_key" value="####"/>
    <http:header name="app_id" value="####"/>
  </http:request>
return
  if (http:send-request($request)[1]/@status/fn:data() = "404") then $word
  else 
    let $synonyms := 
    http:send-request($request)[2]
    => fn:parse-json()
    => map:find("synonyms")
   let $words := $synonyms?1?*?text
   let $count := fn:count($words)
   let $random := fn:head(fn:random-number-generator()("permute")(1 to $count))
   return $words[$random]
};

let $sentence := fn:tokenize("I sing of arms and the man", "\W+")
let $new-words :=
  for $word in $sentence
  return local:get-synonym($word)
return fn:string-join($new-words, " ") || "."
```

Try it out! I generated `I quaver of armaments in addition to the male`, but you'll receive a different random sentence every time.

Now let's just present the sentences together as an XML document. This is the easy part. We'll use direct element constructors to package up our results. Assuming the function remains the same, our free expression now reads:

```xquery
let $sentence := fn:tokenize("I sing of arms and the man", "\W+")
let $new-words :=
  for $word in $sentence
  return local:get-synonym($word)
return 
  <sentence>
    <original>{fn:string-join($sentence, " ") || "."}</original>
    <synonym>{fn:string-join($new-words, " ") || "."}</synonym>
  </sentence>
```

The result is a tidy XML document showing the original and the synonym sentences:

```xml
<sentence>
  <original>I sing of arms and the man.</original>
  <synonym>I quaver of instruments of war including the youth.</synonym>
</sentence>
```

That's it for this session! We'll pick up next time with a demonstration of how to combine CSV and JSON using XQuery.
