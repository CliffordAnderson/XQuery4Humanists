xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:get-play($url as xs:string) as document-node()
{
   fn:doc($url)
};

declare function local:get-person-ids($play as document-node()) as xs:string*
{
  let $persons := $play//tei:person/@xml:id ! fn:concat("#", .)
  for $person in $persons
  let $id := fn:translate($person, "#", "")
  return $id
  
};

declare function local:get-person-name-by-id($play as document-node(), $id as xs:string) as xs:string
{
  let $persName := $play//tei:person[@xml:id = $id]
  return fn:string-join($persName/tei:persName//text(), " ")
};

declare function local:get-scenes-by-id($play as document-node(), $id as xs:string) as xs:string*
{
 let $scenes :=
    for $act in $play//tei:div1[@type="act"]
    for $scene in $act/tei:div2
    let $act-scene := fn:concat("act ", $act/@n, ", ", "scene ", $scene/@n)
    where $id = $scene//tei:stage/@who ! fn:tokenize(., " ") ! fn:replace(., "#","")
    return $act-scene
  return fn:string-join($scenes, "; ")
};

declare function local:html($div as element(div)) as element(html)
{
  <html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Bootstrap 101 Template</title>

    <!-- Bootstrap -->
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" integrity="sha512-dTfge/zgoMYpP7QbHy4gWMEGsbsdZeCXz7irItjcC3sPUFtf0kuFbDz/ixG7ArTxmDjLXDmezHubeNikyKGVyQ==" crossorigin="anonymous"/>

    <!-- Optional theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css" integrity="sha384-aUGj/X2zp5rLCbBxumKTCw2Z50WgIr1vs/PFN4praOTvYXWlVyh2UtNUU0KAUhAX" crossorigin="anonymous"/>

    <!-- Latest compiled and minified JavaScript -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" integrity="sha512-K1qjQ+NcF2TYO/eI3M6v8EiNYZfA95pQumfvcVrTHtwQVDG+aHRqLi/ETn2uB+1JqwYqVG3LIvdm9lj6imS/pQ==" crossorigin="anonymous">&#x20;</script>
    
  </head>
  <body>
    <div class="container">
      <h1>When Do Characters Appear on Stage?</h1>
      {$div}
      <!-- jQuery (necessary for Bootstrap&aposs JavaScript plugins) -->
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
      <!-- Include all compiled plugins (below), or include individual files as needed -->
      <script src="js/bootstrap.min.js"></script>
    </div>
  </body>
</html>
  
};

declare function local:get-appearances($play as document-node()) as element(p)* 
{
  for $person-id in local:get-person-ids($play)
  let $name := local:get-person-name-by-id($play, $person-id)
  let $scenes := local:get-scenes-by-id($play, $person-id)
  where $name
  let $appearances :=  $name || " appears in " || $scenes || "."
  return element p { $appearances }
};

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
let $play := local:get-play($url)
let $appearances := element div {local:get-appearances($play)}
return local:html($appearances)