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

This expression returns `"Krakow"`. You could also write `$dh?2016` to accomplish the same thing.

Now that you understand how to explore arrays and maps in XQuery, let's try something practical. Can you pull the lattitude and longitude from this expression? `[ map {"title":"Nashville","location_type":"City","woeid":2457170,"latt_long":"36.167839,-86.778160"} ]` Try to do so using both syntaxes.

Here's something a bit harder and more practical. Can you pull out the weather predication for Montreal on August 6th, 2017? (If you want to work ahead, try using the [MetaWeather API](https://www.metaweather.com/api/) to fetch the latest weather predication for [Montreal](https://www.metaweather.com/api/location/3534/).) Note that you should use an asterisk operator `*` to filter out irrelevant dates.

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

A solution is `("consolidated_weather")?*[.("applicable_date") eq "2017-08-06"]("weather_state_name")`. The use of the lookup operator may lead you to regard the `?` operator as akin to the `/` in XPath. But be careful! The resemblance is skin deep. It's not possible to use a `??` operator, for example, to search for items at any depth in arrays. There is, however, a function call `map:find` that will find keys that match at any arbitrary position in a map/array data structure. Can you use it to rewrite the solution above?

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
