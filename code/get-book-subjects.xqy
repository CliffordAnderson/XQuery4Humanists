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
return element csv {$record}
