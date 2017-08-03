xquery version "3.1";

 declare function local:title($book as xs:string, $key as xs:string) {
  let $uri := "http://openlibrary.org/search.json?title="
  let $json := fn:json-doc($uri || $book)
  return element results {
    for $item in array:flatten(map:find($json, $key))
    return element result {$item}
  }
};

local:title("Ubik", "title")
