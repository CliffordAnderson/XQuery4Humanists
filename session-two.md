##Session Two

Today, we are going to tackle some textual analysis with XQuery. When you are working with real world data like documents encoded according to the [TEI](http://www.tei-c.org/index.xml), your query expressions will frequently become more complicated. Today, we'll try to consolidate what we've learned and use our new-found knowledge of XQuery to explore literary documents.

###Word Frequencies in XQuery

A good use case for XQuery is developing word frequency lists for digital texts. Among the first poems I learned as a child was "Eldorado" by Edgar Allen Poe. I recall being struck by the repetition of the word "shadow" in the poem. Why did Poe repeat the word so many times in so few lines? While this month's XQuery exercise won't sort out the answer to that question, it will help us find out how many times he used that and other words.

Let's start with a TEI edition of the poem:

```xml
<TEI xmlns="http://www.tei-c.org/ns/1.0">
   <teiHeader>
      <fileDesc>
         <titleStmt>
            <title>Eldorado</title>
            <author>Edgar Allen Poe</author>
         </titleStmt>
         <publicationStmt>
            <p>Originally published in <title>The Flag of Our Union</title> (<date>April 21, 1849</date>)</p>
         </publicationStmt>
         <sourceDesc>
            <p>Converted from the digital text provided by The Poetry Foundation.</p>
         </sourceDesc>
      </fileDesc>
   </teiHeader>
   <text>
      <body>
         <lg type="poem">
            <head>Eldorado</head>
            <lg type="stanza" n="1">
               <l n="1">Gaily bedight,</l>
               <l n="2">A gallant knight,</l>
               <l n="3">In sunshine and in shadow,</l>
               <l n="4">Had journeyed long,</l>
               <l n="5">Singing a song,</l>
               <l n="6">In search of Eldorado.</l>
            </lg>
            <lg type="stanza" n="2">
               <l n="7">But he grew old-</l>
               <l n="8">This knight so bold-</l>
               <l n="9">And o'er his heart a shadow-</l>
               <l n="10">Fell as he found</l>
               <l n="11">No spot of ground</l>
               <l n="12">That looked like Eldorado.</l>
            </lg>
            <lg type="stanza" n="3">
               <l n="13">And, as his strength</l>
               <l n="14">Failed him at length,</l>
               <l n="15">He met a pilgrim shadow.</l>
               <l n="16">'Shadow,' said he-</l>
               <l n="17">'Where can it be-</l>
               <l n="18">This land of Eldorado?'</l>
            </lg>
            <lg type="stanza" n="4">
               <l n="19">'Over the Mountains</l>
               <l n="20">Of the Moon,</l>
               <l n="21">Down the Valley of the Shadow,</l>
               <l n="22">Ride, boldly ride,'</l>
               <l n="23">The shade replied,</l>
               <l n="24">'If you seek for Eldorado!'</l>
            </lg>
         </lg>
      </body>
   </text>
</TEI>
```

I've also provided [a gist with the poem](https://gist.github.com/CliffordAnderson/2045cefaf2a687e5d078/), in case you'd like to use it. Here's an XQuery to retrieve it.

```xquery
xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

fn:doc("https://gist.githubusercontent.com/CliffordAnderson/2045cefaf2a687e5d078/raw/8b79a0ddbfd1dd85c88d478ea76e083a2d6718c8/eldorado.xml")
```

Obviously, we could simply count the words with such a short poem. But our goal is to write an XQuery expression to do the counting for us. Your mission, should you choose to accept it, is to write an XQuery expression that takes the text nodes from the l elements of the source poem and produces a dictionary of the unique words in the poem along with their frequency.

The output should look like this:

```xml
<dictionary>
  <word frequency="5">the</word>
  <word frequency="5">shadow</word>
  ...
  <word frequency="1">no</word>
  <word frequency="1">gaily</word>
  <word frequency="1">ground</word>
  <word frequency="1">that</word>
  <word frequency="1">looked</word>
  <word frequency="1">like</word>
  <word frequency="1">strength</word>
</dictionary>
```

To get you started, let's assume the expression body looks something like this
```xquery
let $phrases:= fn:doc("https://gist.githubusercontent.com/CliffordAnderson/2045cefaf2a687e5d078/raw/8b79a0ddbfd1dd85c88d478ea76e083a2d6718c8/eldorado.xml")//tei:l/text()
let $words := local:collect-words($phrases)
let $word-elements := local:determine-frequency($words)
return element dictionary {$word-elements}
```

To get this to work, we just have to write two functions: ```local:collect-words()```, which we will use to clean up the words by getting rid of capitalization, punctuation, and the like, and ```local:determine-frequency()```, which we will use to get the frequency of the various words.

> Hint: You'll probably need to use regular expressions in ```local:collect-words()``` to clean up the strings. If so, this function ```fn:replace($words, "[!?.',/-]", "")``` should do the trick nicely.

Give it a try yourself before checking out what I came up with... [Zorba](http://try-zorba.28.io/queries/xquery/ZZf2fGYOwtkBvN8sbzI4cX4plYw%3D) and [Gist](https://gist.github.com/CliffordAnderson/468e0b6a8ee6143676f9).  Ready to check your work?

Let's write the ```local:collect-words``` function first. This function accepts a sequence of text nodes, strips away punctuation and other non-essential differences, and returns a sequence of words.

```xquery
(:~
: This function accepts a sequence of text nodes and returns a sequence of normalized string tokens.
: @param  $words the text nodes from a given text
: @return  the sequence of normalized string tokens
:)
declare function local:collect-words($words as xs:string*) as xs:string*
{
    let $words := fn:string-join($words, " ")
    let $words := fn:replace($words, "[!?.',]", "")
    let $words := fn:lower-case($words)
    let $words := fn:tokenize($words, " ")
    return
        $words
};

local:collect-words("This is a test of the system.")
```

Writing a function in this style is perfectly OK in XQuery, but it's not especially good style. We're rebinding `$words` three times. (Technically, this is called "shadow binding." We're actually creating different variables behind the scenes.) From a functional perspective, it gets confusing since variables are not supposed to vary. We could rewrite FLWOR expression this as a sequence of nested sub-expressions, but doing so makes our expression hard to read: ```fn:tokenize(fn:lower-case(fn:replace(fn:string-join($words, " "), "[!?.',-]", "")), " ")```

The XQuery 3.1 Recommendation introduces the 'arrow operator' to avoid writing these kinds of expressions. The arrow operator pipes the value of a previous expression as the first argument to another expression. So, for example, we could rewrite the expression above like this:

```xquery
xquery version "3.1";

declare function local:collect-words($words as xs:string*) as xs:string*
{
    fn:string-join($words, " ") 
    => fn:replace("[!?.',]", "") 
    => fn:lower-case()
    => fn:tokenize (" ")
};

local:collect-words("This is a test of the system.")
```
The arrow operator allows us to keep our code clean and straightforward by removing any need for rebinding variables in a FLWOR expression or writing complexly nested subexpressions. Note that you'll need to try the expression above with a processor that supports XQuery 3.1. 

 OK, now let's write our next function: ```local:determine-frequency```. This function accepts a sequence of word tokens and then returns a sequence of ```word``` elements indicating the frequency of word types. So we need to write something like the following.
 ```xquery 
 (:~
: This function accepts a sequence of normalized string tokens and returns a sequence of word elements in frequency order.
: @param  $words a sequence of normalized string tokens
: @return  a sequence of word elements
:)
declare function local:determine-frequency($words as xs:string*) as element(word)*
{
    for $word in fn:distinct-values($words)
    let $item := 
        element word { 
        attribute frequency {fn:count($words[. = $word])},
        $word}
    order by $item/@frequency descending
    return $item 
};
```
So we iterate through the distinct values of words and build word elements for each of those word types. We then count the number of times that a token of that word type appears in our original sequence, assigning that count as the ```frequency``` attribute. Finally, we sort them into descending order according to their frequency and return them.

> A final note. Do you note the strange way we've formatted our XQuery comments? The use of (:~, @param, @return allows us to produce documentation from our code with a tool called [XQDoc](http://xqdoc.org). If you're writing anything beyond simple, one-off XQuery expressions, you should consider writing XQDoc comments to alert others (and remind yourself) about how your code works.

Extra Credit: Add an expression to the query to eliminate common stop-words—i.e. "of," "the," etc.—from your dictionary.

###Exploring Shakespeare

Let's tackle a few more complicated XQuery expressions using the [Folger Digital Texts](http://www.folgerdigitaltexts.org/) of William Shakespeare. To understand these expressions, you'll need to acquaint yourself a bit with the TEI markup used in this digital edition. The best way to do that with XQuery is just to write some simple exploratory expressions.

For instance, let's grab a whole document first and see what's there. I've put the edition of Julius Caesar up at an ungainly [url](https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"), which we will assign to a variable for easier use.

```xquery
xquery version "3.0";

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
return fn:doc($url)
```

OK, now let's take a look at some of its constituent parts. What's in the header, for instance? *Don't forget to add the TEI namespace!*

```xquery
xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
let $play := fn:doc($url)
return $play/tei:TEI/tei:teiHeader
```

As far as TEI documents go, there's a lot information here! So perhaps we ought to drill down to the encoding description. Let's do that.

```xquery
xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
let $play := fn:doc($url)
return $play//tei:encodingDesc
```
We find really valuable information about the usage of particular TEI elements, which can in turn inform the kinds of queries we will write. XQuery makes this form of exploratory analysis very easy. Just as statisticians would explore a dataset with simple queries before undertaking any complex analysis, I'd encourage you to spend time exploring your XML (or JSON) documents before diving into writing significant queries.

Let's try to now to write a couple analytical queries. Here's two snippets from *Julius Caesar*. First, let's look at ```<listPerson>``` 'list of persons'. Here we see a number of persons related to Julius Caesar, including Caesar himself, his wife Calphurnia, and their servants. There are similar lists of persons for other characters and roles in the play.

```xml
<listPerson>
    <person xml:id="Caesar_JC">
        <persName>
            <name>Julius Caesar</name>
        </persName>
        <sex value="1">male</sex>
        <death when-custom="ftln-1238"/>
    </person>
    <person xml:id="Calphurnia_JC">
        <persName>
            <name>Calphurnia</name>
        </persName>
        <state>
            <p><rs ref="#Caesar_JC">his</rs> wife</p>
        </state>
        <sex value="2">female</sex>
    </person>
    <person xml:id="SERVANTS.CAESAR.1_JC" corresp="#SERVANTS_JC">
        <persName>Servant to <rs ref="#Caesar_JC #Calphurnia_JC">them</rs></persName>
        <sex value="1">male</sex>
    </person>
</listPerson>
```
In the body of the play, we find ```<sp>``` or speech elements, with ```who``` attributes that identify the speakers. Note also the use of ```w``` (word), ```pc``` (punctuation character), and ```<c>``` (character) elements to markup the text of the speeches.

```xml
<sp xml:id="sp-0006" who="#COMMONERS.Carpenter_JC">
    <speaker xml:id="spk-0006">
        <w xml:id="w0001210">CARPENTER</w>
    </speaker>
    <ab xml:id="ab-0006">
        <milestone unit="ftln" xml:id="ftln-0006" n="1.1.6" ana="#prose"
            corresp="#w0001220 #p0001230 #c0001240 #w0001250 #p0001260 #c0001270 #w0001280 #c0001290 #w0001300 #p0001310"/>
        <w xml:id="w0001220" n="1.1.6">Why</w>
        <pc xml:id="p0001230" n="1.1.6">,</pc>
        <c xml:id="c0001240" n="1.1.6"> </c>
        <w xml:id="w0001250" n="1.1.6">sir</w>
        <pc xml:id="p0001260" n="1.1.6">,</pc>
        <c xml:id="c0001270" n="1.1.6"> </c>
        <w xml:id="w0001280" n="1.1.6">a</w>
        <c xml:id="c0001290" n="1.1.6"> </c>
        <w xml:id="w0001300" n="1.1.6">carpenter</w>
        <pc xml:id="p0001310" n="1.1.6">.</pc>
    </ab>
</sp>
```

Our first expression will find all the stage directions associated with characters in *Julius Caesar*.

```xquery
xquery version "3.0";

declare default element namespace "http://www.tei-c.org/ns/1.0";

let $doc := fn:doc("https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml")
for $person in $doc//person
return
      <directions>
        <person>{$person}</person>
        <direction>
            {
                for $stage in $doc//stage
                where $person/@xml:id = fn:tokenize($stage/@who, "#| #")
                return $stage
            }
        </direction>
      </directions> 
```

Ready to try this expression out with [Zorba](http://try-zorba.28.io/queries/xquery/JCBuIC%2Fiq7nR%2FyMzxY%2FMniqdqb8%3D)?

In this next example, let's list all characters and the scenes during which they appear on stage. This query illustrates the use of multiple ```for``` clauses in an FLWOR expression. 

```xquery
xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $doc := fn:doc("https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml")
return element appearances 
  {
      let $persons := $doc//tei:person/@xml:id ! fn:concat("#", .)
      for $person in $persons
      for $act in $doc//tei:div1[@type="act"]
      for $scene in $act/tei:div2
      let $act-scene := fn:concat("Act-", $act/@n, ".", "Scene-", $scene/@n)
      where $person = $scene//tei:stage/@who ! fn:tokenize(., " ") 
      group by $person
      order by $person
      return <actor id="{$person}"  act-scene=" {$act-scene}" />
  }
```
Let's give this expression a whirl using [Zorba](http://try-zorba.28.io/queries/xquery/J%2FOptdOBD9ZYoD5%2FGr9%2FxsmaT28%3D). Here is what the results look like.

```xml
<appearances>
  <actor id="#Antony_JC" act-scene=" Act-1.Scene-2 Act-2.Scene-2 Act-3.Scene-1 Act-3.Scene-2 Act-4.Scene-1 Act-5.Scene-1 Act-5.Scene-4 Act-5.Scene-5"/>
  <actor id="#Artemidorus_JC" act-scene=" Act-2.Scene-3 Act-3.Scene-1"/>
  <actor id="#Brutus_JC" act-scene=" Act-1.Scene-2 Act-2.Scene-1 Act-2.Scene-2 Act-3.Scene-1 Act-3.Scene-2 Act-4.Scene-2 Act-4.Scene-3 Act-5.Scene-1 Act-5.Scene-2 Act-5.Scene-3 Act-5.Scene-4 Act-5.Scene-5"/>
  <actor id="#COMMONERS.Carpenter_JC" act-scene=" Act-1.Scene-1"/>
  <actor id="#COMMONERS.Cobbler_JC" act-scene=" Act-1.Scene-1"/>
 ...
</appearances>
```

We've got the information we want but it's not a very attractive display. Can we do any better with the output? Sure, we can. Let's try now to format the results and output them as a HTML document. And why not add [Bootstrap](http://getbootstrap.com/) into the mix for better formatting?

###Formatting XQuery Results

So a problem with the XQuery expression above is that it's a little hard to follow. How exactly are we matching names with scenes? I wrote the expression but, returning to it several days later, it find it hard to parse out. So, realistically, we cannot expect to add more complexity and hope to understand what we're doing. So let's [refactor](https://en.wikipedia.org/wiki/Code_refactoring) our expression into several sub-expressions (or functions) to maintain readability and comprehensibility. 

Let's start out with our main expression body, which we'll keep as simple as possible.

```xquery
xquery version "3.0";

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
let $play := local:get-play($url)
let $appearances := element div {local:get-appearances($play)}
return local:html($appearances)
```

Our next function ```local:get-play()``` simply opens the play for us. Maybe we don't really even need it, but it helps to be clear about how we're accessing the play. I've put a free expression below our function just so that we can test it out.

```xquery

declare function local:get-play($url as xs:string) as document-node()
{
   fn:doc($url)
};

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
return local:get-play($url)

```

OK, now we've got the play. Let's get all the ids of the actors in the play. 

```xquery
xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:get-person-ids($play as document-node()) as xs:string*
{
  let $persons := $play//tei:person/@xml:id ! fn:concat("#", .)
  for $person in $persons
  let $id := fn:translate($person, "#", "")
  return $id
  
};


declare function local:get-play($url as xs:string) as document-node()
{
   fn:doc($url)
};

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
return local:get-person-ids(local:get-play($url))

```

The combination of evaluating the two nested functions in our return clause produces a sequence of string nodes listing all the ids in the play: 

> ```Caesar_JC Calphurnia_JC SERVANTS.CAESAR.1_JC Brutus_JC Portia_JC Lucius_JC Cassius_JC Casca_JC Cinna_JC Decius_JC Ligarius_JC Metellus_JC Trebonius_JC Cicero_JC Publius_JC Popilius_JC Flavius_JC Marullus_JC Antony_JC Lepidus_JC Octavius_JC SERVANTS.ANTONY.1_JC SERVANTS.OCTAVIUS.1_JC SOLDIERS.BRUTUS.Lucilius_JC SOLDIERS.BRUTUS.Titinius_JC SOLDIERS.BRUTUS.Messala_JC SOLDIERS.BRUTUS.Varro_JC SOLDIERS.BRUTUS.Claudius_JC SOLDIERS.BRUTUS.Cato_JC SOLDIERS.BRUTUS.Strato_JC SOLDIERS.BRUTUS.Volumnius_JC SOLDIERS.BRUTUS.Labeo_JC SOLDIERS.BRUTUS.Flavius_JC SOLDIERS.BRUTUS.Dardanus_JC SOLDIERS.BRUTUS.Clitus_JC COMMONERS.Carpenter_JC COMMONERS.Cobbler_JC Soothsayer_JC Artemidorus_JC PLEBEIANS.0.1_JC PLEBEIANS.0.2_JC PLEBEIANS.0.3_JC PLEBEIANS.0.4_JC CinnaPoet_JC Pindarus_JC SOLDIERS.BRUTUS.0.1_JC SOLDIERS.BRUTUS.0.2_JC SOLDIERS.BRUTUS.0.3_JC Poet_JC Messenger_JC SOLDIERS.ANTONY.0.1_JC SOLDIERS.ANTONY.0.2_JC``` 

Not much to look at right now, but it's the data we need for our next function, which returns the characters' actual names.

```xquery 
xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:get-person-name-by-id($play as document-node(), $id as xs:string) as xs:string
{
  let $persName := $play//tei:person[@xml:id = $id]
  return fn:string-join($persName/tei:persName//text(), " ")
};

declare function local:get-person-ids($play as document-node()) as xs:string*
{
  let $persons := $play//tei:person/@xml:id ! fn:concat("#", .)
  for $person in $persons
  let $id := fn:translate($person, "#", "")
  return $id
  
};

declare function local:get-play($url as xs:string) as document-node()
{
   fn:doc($url)
};

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
let $play := local:get-play($url)
return local:get-person-ids($play) ! local:get-person-name-by-id($play , .) 

```

This function evaluates to a friendlier sequence of names, rather than ids: 

```Julius Caesar Calphurnia Servant to them Marcus Brutus Portia Lucius Caius Cassius Casca Cinna Decius Brutus Caius Ligarius Metellus Cimber Trebonius Cicero Publius Popilius Lena Flavius Marullus Mark Antony Lepidus Octavius Servant to Antony Servant to Octavius Lucilius Titinius Messala Varro Claudius Young Cato Strato Volumnius Labeo (nonspeaking) Flavius (nonspeaking) Dardanus Clitus A Carpenter A Cobbler A Soothsayer Artemidorus Cinna the poet Pindarus Another Poet A Messenger``` 

It would be a bit tedious, I think, to run through all the functions. But I hope you can see now how we build up our expression step-by-step from smaller sub-expressions. Putting it all together, then, we have the following:

```xquery
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
```

You can try running the whole XQuery expression with [Zorba](http://try.zorba.io/queries/xquery/7tclGE7xRIiRrpvuNhs5zpYKJ5I%3D). Better yet, check out [the HTML output with Zorba](http://try.zorba.io/queries/xquery/7tclGE7xRIiRrpvuNhs5zpYKJ5I%3D).

###XQuery verus XSLT

We might conclude today with a few remarks on how XQuery and XSLT work together. We've seen in these examples that we can use XQuery to transform XML results into HTML (and other formats too). And, as Laura has shown, XSLT can carry out these transformations too. So what's the difference between XQuery and XSLT? When should you select one over the other?

In fact, there is a significant degree of overlap between the two languages. While XSLT is frequently used to transform documents of one type to another—say from TEI to HTML—we've seen that you can actually accomplish the same thing in XQuery, albeit sometimes less efficiently with complex documents. In truth, a lot comes down to context and programming preference. If you're working in a database context with many hundreds or perhaps thousand documents, then XQuery will be the natural choice. 

