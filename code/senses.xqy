xquery version "3.1";

declare namespace http = "http://expath.org/ns/http-client";

let $word := "person"
let $request :=
  <http:request href="https://od-api.oxforddictionaries.com/api/v1/entries/en/{$word}"  override-media-type="text/plain" method="get" >
    <http:header name="app_key" value="59207f4f580f9f12ab271c206d7d9789"/>
    <http:header name="app_id" value="993be3e7"/>
  </http:request>
let $json := http:send-request($request)[2]
return fn:parse-json($json) => map:find("senses")
