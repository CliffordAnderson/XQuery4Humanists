## Session Two

In this session, we are going to tackle some textual analysis with XQuery. When you are working with real world data like documents encoded according to the [TEI Guidelines](http://www.tei-c.org/index.xml), your query expressions will tend to become more complicated than the simple examples we saw in the first session. We'll apply what we've learned and use our new-found knowledge of XQuery to explore literary documents.

### Learning Outcomes

* Apply XQuery to TEI documents to study word frequency;
* Use XQuery to carry out exploratory analysis of TEI documents;
* Learn to create web pages from TEI documents with XQuery;
* Transform a TEI document into GraphML for network analysis.

### Word Frequencies in XQuery

A good use case for XQuery is developing word frequency lists for digital texts. Among the first poems I learned as a child was "Eldorado" by Edgar Allen Poe. I recall being struck by the repetition of the word "shadow" in the poem. Why did Poe repeat the word in these lines? While this session's XQuery exercise won't sort out the answer to that question, it will help us find out how frequently he used that and other words.

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

I've also include the poem in data folder of this repository, in case you'd like to use it. Here's an XQuery to retrieve it.

```xquery
xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

fn:doc("https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/master/data/eldorado.xml")
```

We could count the words manually with such a short poem. But our goal is to write an XQuery expression to do the counting for us. Your mission, should you choose to accept it, is to write an XQuery expression that takes the text nodes from the l elements of the source poem and produces a dictionary of the unique words in the poem along with their frequency.

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

To get you started, let's assume the query body looks something like this:

```xquery
xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

fn:doc("https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/master/data/eldorado.xml")//tei:l/text()
let $words := local:collect-words($phrases)
let $word-elements := local:determine-frequency($words)
return element dictionary {$word-elements}
```

To get this to work, we have to write two functions: `local:collect-words()`, which we will use to clean up the words by getting rid of capitalization, punctuation, and the like, and `local:determine-frequency()`, which we will use to get the frequency of the words.

> Hint: You'll need clean up the punctuation in `local:collect-words()` to get an accurate count of word tokens. The [`fn:translate` function](http://www.xqueryfunctions.com/xq/fn_translate.html) should do the trick nicely.

Give it a try yourself before [checking out what I came up with....](code/count-word-tokens.xqy)

Let's write the `local:collect-words()` function first. This function accepts a sequence of text nodes, strips away punctuation and other non-essential differences, and returns a sequence of words.

```xquery
xquery version "3.1";

(:~
: This function accepts a sequence of text nodes and returns a sequence of normalized string tokens.
: @param  $words the text nodes from a given text
: @return  the sequence of normalized string tokens
:)
declare function local:collect-words($words as xs:string*) as xs:string*
{
    let $words := fn:string-join($words, " ")
    let $words := fn:translate($words, "!?.',-", "")
    let $words := fn:lower-case($words)
    let $words := fn:tokenize($words, " ")
    return
        $words
};

local:collect-words("This is a test of the system.")
```

Writing a function in this style is perfectly OK in XQuery, but it's not good style. We're rebinding `$words` three times. (Technically, this is called "shadow binding." We're actually creating different variables behind the scenes.) From a functional perspective, it gets confusing since variables are not supposed to vary. We could rewrite FLWOR expression this as a sequence of nested sub-expressions, but doing so makes our expression hard to read:

```xquery
fn:tokenize(fn:lower-case(fn:translate(fn:string-join($words, " "), "!?.',-", "")), " ")
```

As we saw in the previous session, the XQuery 3.1 Recommendation introduced the *arrow operator* to avoid writing these kinds of expressions. The arrow operator pipes the value of a previous expression as the first argument to another function. So, for example, we could rewrite the expression above like this:

```xquery
xquery version "3.1";

declare function local:collect-words($words as xs:string*) as xs:string*
{
    fn:string-join($words, " ")
    => fn:translate("!?.',-", "")
    => fn:lower-case()
    => fn:tokenize (" ")
};

local:collect-words("This is a test of the system.")
```
The arrow operator allows us to keep our code clean and straightforward by removing any need for rebinding variables in a FLWOR expression or writing complexly nested subexpressions. Note that you'll need to try the expression above with a processor that supports XQuery 3.1.

OK, now let's write our next function: `local:determine-frequency()`. This function accepts a sequence of word tokens and then returns a sequence of `word` elements indicating the frequency of word types. So we need to write something like the following.

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
            attribute frequency { fn:count($words[. = $word]) },
            $word
        }
    order by $item/@frequency descending
    return $item
};
```
So we iterate through the distinct values of words and build word elements for each of those word types. We then count the number of times that a token of that word type appears in our original sequence, assigning that count as the `frequency` attribute. Finally, we sort them into descending order according to their frequency and return them.

> A final note. Do you note the strange way we've formatted our XQuery comments? The use of `(:~`, `@param`, and `@return` allows us to produce documentation from our code with a tool called [XQDoc](http://xqdoc.org). If you're writing anything beyond simple, one-off XQuery expressions, you should consider writing XQDoc comments to alert others (and remind yourself) about how your code works.

Extra Credit: Add an expression to the query to eliminate common stop-words—i.e. "of," "the," etc.—from your dictionary.

### Exploring Shakespeare

Let's tackle a few more complicated XQuery expressions using the [Folger Digital Texts](http://www.folgerdigitaltexts.org/) of William Shakespeare. To understand these expressions, you'll need to acquaint yourself a bit with the TEI markup used in this digital edition. The best way to do that with XQuery is just to write some simple exploratory expressions.

For instance, let's grab a whole document first and see what's there. I've put the edition of _Julius Caesar_ up at an ungainly [url](https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"), which we will assign to a variable for easier use.

```xquery
xquery version "3.1";

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
return fn:doc($url)
```

OK, now let's take a look at some of its constituent parts. What's in the header, for instance? *Don't forget to add the TEI namespace!*

```xquery
xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
let $play := fn:doc($url)
return $play/tei:TEI/tei:teiHeader
```

As far as TEI documents go, there's a lot information here! So perhaps we ought to drill down to the encoding description. Let's do that.

```xquery
xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
let $play := fn:doc($url)
return $play//tei:encodingDesc
```
We find really valuable information about the usage of particular TEI elements, which can in turn inform the kinds of queries we will write. XQuery makes this form of exploratory analysis very easy. Just as statisticians would explore a dataset with simple queries before undertaking any complex analysis, I'd encourage you to spend time exploring your XML (or JSON) documents before diving into writing significant queries.

Let's try to now to write a couple analytical queries. Here's two snippets from _Julius Caesar_. First, let's look at `<listPerson>`, a TEI element that houses a list of persons. Here we see a number of persons related to Julius Caesar, including Caesar himself, his wife Calphurnia, and their servants. There are similar lists of persons for other characters and roles in the play.

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
In the body of the play, we find `<sp>` or speech elements, with `who` attributes that identify the speakers. Note also the use of `<w>` (word), `<pc>` (punctuation character), and `<c>` (character) elements to markup the text of the speeches.

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
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

let $doc := fn:doc("https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml")
for $person in $doc//tei:person
return
    <directions>
        <person>{$person}</person>
        <direction>
        {
            for $stage in $doc//tei:stage
            where $person/@xml:id = fn:tokenize($stage/@who, "#| #")
            return $stage
        }
        </direction>
    </directions>
```

In this next example, let's list all characters and the scenes during which they appear on stage. This query illustrates the use of multiple `for` clauses in an FLWOR expression.

```xquery
xquery version "3.1";

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
      return <actor id="{$person}" act-scene="{$act-scene}" />
  }
```
Let's give this expression a whirl. Here is what the results look like.

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

### Formatting XQuery Results

So a problem with the XQuery expression above is that it's a little hard to follow. How exactly are we matching names with scenes? I wrote the expression, but, returning to it several days later, I find it hard to parse out. So, realistically, we cannot expect to add more complexity and hope to understand what we're doing. So let's [refactor](https://en.wikipedia.org/wiki/Code_refactoring) our expression into several sub-expressions (or functions) to maintain readability and comprehensibility.

Let's start out with our main expression body, which we'll keep as simple as possible.

```xquery
xquery version "3.1";

let $url := "https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml"
let $play := local:get-play($url)
let $appearances := element div { local:get-appearances($play) }
return local:html($appearances)
```

Our next function `local:get-play()` opens the play for us. Maybe we don't even need it, but it helps to be clear about how we're accessing the play. I've put a free expression below our function so that we can test it out.

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
xquery version "3.1";

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

> `Caesar_JC Calphurnia_JC SERVANTS.CAESAR.1_JC Brutus_JC Portia_JC Lucius_JC Cassius_JC Casca_JC Cinna_JC Decius_JC Ligarius_JC Metellus_JC Trebonius_JC Cicero_JC Publius_JC Popilius_JC Flavius_JC Marullus_JC Antony_JC Lepidus_JC Octavius_JC SERVANTS.ANTONY.1_JC SERVANTS.OCTAVIUS.1_JC SOLDIERS.BRUTUS.Lucilius_JC SOLDIERS.BRUTUS.Titinius_JC SOLDIERS.BRUTUS.Messala_JC SOLDIERS.BRUTUS.Varro_JC SOLDIERS.BRUTUS.Claudius_JC SOLDIERS.BRUTUS.Cato_JC SOLDIERS.BRUTUS.Strato_JC SOLDIERS.BRUTUS.Volumnius_JC SOLDIERS.BRUTUS.Labeo_JC SOLDIERS.BRUTUS.Flavius_JC SOLDIERS.BRUTUS.Dardanus_JC SOLDIERS.BRUTUS.Clitus_JC COMMONERS.Carpenter_JC COMMONERS.Cobbler_JC Soothsayer_JC Artemidorus_JC PLEBEIANS.0.1_JC PLEBEIANS.0.2_JC PLEBEIANS.0.3_JC PLEBEIANS.0.4_JC CinnaPoet_JC Pindarus_JC SOLDIERS.BRUTUS.0.1_JC SOLDIERS.BRUTUS.0.2_JC SOLDIERS.BRUTUS.0.3_JC Poet_JC Messenger_JC SOLDIERS.ANTONY.0.1_JC SOLDIERS.ANTONY.0.2_JC`

Not much to look at right now, but it's the data we need for our next function, which returns the characters' actual names.

```xquery
xquery version "3.1";

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

> `Julius Caesar Calphurnia Servant to them Marcus Brutus Portia Lucius Caius Cassius Casca Cinna Decius Brutus Caius Ligarius Metellus Cimber Trebonius Cicero Publius Popilius Lena Flavius Marullus Mark Antony Lepidus Octavius Servant to Antony Servant to Octavius Lucilius Titinius Messala Varro Claudius Young Cato Strato Volumnius Labeo (nonspeaking) Flavius (nonspeaking) Dardanus Clitus A Carpenter A Cobbler A Soothsayer Artemidorus Cinna the poet Pindarus Another Poet A Messenger`

It would be a bit tedious, I think, to run through all the functions. But I hope you can see now how we build up our expression step-by-step from smaller sub-expressions. Putting it all together, then, we have the following:

```xquery
xquery version "3.1";

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
    where $id = $scene//tei:stage/@who ! fn:tokenize(., " ") ! fn:replace(., "#", "")
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
let $appearances := element div { local:get-appearances($play) }
return local:html($appearances)
```

Try running the whole XQuery expression with BaseX or eXist. Your query should produce a simple web page like the following:

![Characters' appearances in Julius Caesar](http://i.imgur.com/cparMLW.png)

### Graphing TEI

The final example in this section is more advanced. We will draw out the implicit graph of relationships between characters in *Julius Caesar*. We will do this by identifying relationships in the TEI document and converting them into [GraphML](http://graphml.graphdrawing.org/), a standard for encoding graphs as XML. We will write a query that takes a Folger play (e.g. *Julius Caesar*) as input and produces graphML as its output.

First, we need to figure out our graph model, that is, what our nodes and edges should be. To keep matters simple, we will create four node kinds (`Work`, `Act`, `Scene`, and `Character`) and two kinds of relationships (`Appears` and `Contains`). The illustration below indicates our model.

![Graph Model](http://i.imgur.com/AGcJaez.png)

To generate graphML nodes and edges from our TEI document, we need to identify the corresponding elements and then link them together with edges using ids. The expression body collects nodes and links them with edges.

```xquery
xquery version "3.1";

(: Converts TEI texts in the Folger Shakespeare Edition into graphML :)

declare namespace graphml = "http://graphml.graphdrawing.org/xmlns";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: retrieves the TEI edition :)
let $doc := fn:doc("JC.xml")
(: creates the work node :)
let $play := local:title-node($doc)
(: creates the act and scene nodes :)
let $acts-scenes := local:act-scene-nodes($doc)
(: creates the edges between the work node to the act nodes :)
let $play-to-acts := local:play-to-acts($play, $acts-scenes)
(: creates the edges between the act nodes and the scenes nodes :)
let $acts-to-scenes := local:acts-to-scenes($acts-scenes)
(: creates the character nodes :)
let $persons := local:person-nodes($doc)
(: creates the edges between the character nodes and the scene nodes :)
let $persons-to-scenes := local:persons-to-scenes($persons, $acts-scenes, $doc)
(: create the graphML document of all the edges and nodes :)
return local:make-graphml(($play, $persons, $acts-scenes, $play-to-acts, $acts-to-scenes, $persons-to-scenes))
```

As you see, this query consists of a single FLWOR expression that loads the TEI document, assigns the values of a series of function calls to variables, and then returns a function that packages up all those values into a graphML document.

The hard part is writing the functions. Let's look at how to write the first function: `local:title-node()`. As always, I recommend starting by writing the function signature. While it's tempting to delay defining the types until you've composed the function (or to put off annotating the types altogether), getting in the habit of indicating the types of your inputs and output will prevent frustrating bugs down the line. In this case, we will accept a document-node (possibly empty) as our input and return a graphML node as our output. The function retrieves the `tei:idno` along with the `tei:title` and `tei:author` from the `tei:fileDesc` and creates a graphML node with an `id` attribute, a predefined `labels` attribute and a two data elements.

```xquery
declare function local:title-node($doc as document-node()?) as element(graphml:node)
{
  let $idno := $doc//tei:idno/text()
  let $title := $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
  let $author := $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/text()
  return
    <graphml:node id="{$idno}" labels=":Work">
      <graphml:data key="title">{$title}</graphml:data>
      <graphml:data key="author">{$author}</graphml:data>
    </graphml:node>
};
```

A potentially tricky thing in this function is the shift from the TEI to the graphML namespace. You need to declare both namespaces in your XQuery prolog for this function to work.

Next let's create the nodes for the acts and the scenes. We are going to create both using a single function, though you might also want to break this function apart for the sake of clarity. The function signature is nearly identical to the previous function except that we will be returning a series of graphML nodes. Note the strategy below of assigning the count of the `tei:div1` and `tei:div2` elements rather than the elements themselves. Also, note that we create unique identifiers for both acts and scenes since these elements do not have ids in the Folger texts. We will use those ids to link acts and scenes together in a another function.

```xquery
declare function local:act-scene-nodes($doc as document-node()?) as element(graphml:node)*
{
  let $acts := fn:count($doc//tei:div1[@type="act"])
  let $act-nodes := (1 to $acts) !
      <graphml:node id="{'act' || . }" labels=":Act">
        <graphml:data key="act">{'Act ' || . }</graphml:data>
     </graphml:node>
  let $scene-nodes :=
    for $act in 1 to $acts
    for $scene in 1 to fn:count($doc//tei:div1[@n=$act]//tei:div2[@type="scene"])
    return
     <graphml:node id="{'act' || $act || 'scene' || $scene }" labels=":Scene">
        <graphml:data key="scene">{'Scene ' || $scene }</graphml:data>
     </graphml:node>
  return ($act-nodes, $scene-nodes)
};
```

Now we gather together the character nodes. The function signature is what we expected. Notice that we are limiting our characters to those who have names. The eliminates some minor characters along with anonymous soldiers who move on and off stage. This editorial decision makes our graph cleaner. We also clean up the `ids`, removing `.` and `_` characters. The reason for trimming these characters is that their presence might trip up our graphing software. In other scenarios, it might be important to maintain the correspondence between the TEI ids and the graphML ideas–for instance, if you want people to click from the graph to the TEI edition of the text.

```xquery
declare function local:person-nodes($doc as document-node()?) as element(graphml:node)*
{
  for $person in $doc//tei:person
  let $person-id := $person/@xml:id/fn:data()
  let $person-name := $person/tei:persName/tei:name/text()
  where $person-name
  order by $person-name
  return
    <graphml:node id="{$person-id => translate('._','')}" labels=":Character">
      <graphml:data key="name">{$person-name}</graphml:data>
    </graphml:node>
};
```

We've now established all the nodes we need for our graph. With *Julius Caesar* as our input, we produce one `work` node, five `act` nodes, eighteen `scene` nodes, and twenty-five `character` nodes. How now to relate them with edges?

The first function is straightforward. We take our `work` node and link it to all the `act` nodes. We return a series of edges between these nodes.

```xquery
declare function local:play-to-acts($play as element(graphml:node)*, $acts-scenes as element(graphml:node)*) as element(graphml:edge)*
{
  for $node in $acts-scenes
  where $node/@labels eq ":Act"
  return
  <graphml:edge
     source="{$play/@id}"
     target="{$node/@id}"
     labels=":Contains">
       <graphml:data key="label">contains</graphml:data>
  </graphml:edge>
};
```

The next function connects the acts to the scenes. Here we iterate through our act nodes and look scenes they contain. We do this by checking for the id of the act within the id of the scenes. As before, we return a sequence of edges.

```xquery
declare function local:acts-to-scenes($acts-scenes as element(graphml:node)*) as element(graphml:edge)*
{
  for $node in $acts-scenes[@labels eq ":Act"]
  for $scene in $acts-scenes[@labels eq ":Scene"]
  where fn:contains($scene/@id, $node/@id)
  return
  <graphml:edge
     source="{$node/@id}"
     target="{$scene/@id}"
     label=":Contains">
       <graphml:data key="label">contains</graphml:data>
  </graphml:edge>
};
```

The final set of edges we need to establish relate characters to scenes. We do not need to connect characters to acts or works since we've already made those edges to our scenes and they'll transitively connect the characters to those nodes. This query requires that we pass in our TEI document-node again because we need to look up information we haven't captured in our nodes, namely, the scenes in which these characters appear. Note how the clean up the ids to make sure that they correspond to the ids in our character nodes. Also note the use of existential quantification to match characters with our list of named characters. We want to filter out the anonymous players again to avoid generating edges that lack corresponding nodes.

```xquery
declare function local:persons-to-scenes($persons as element(graphml:node)*, $acts-scenes as element(graphml:node)*, $doc as document-node()) as element(graphml:edge)*
{
  for $act in 1 to fn:count($acts-scenes[@labels eq ":Act"])
  for $scene in $doc//tei:div1[@n=$act]//tei:div2
  let $characters := $scene//tei:stage/@who ! fn:tokenize(., " ") ! translate(., "#._", "")
  return
    for $character in $characters
    where some $person in $persons/@id satisfies $character eq $person  
    return
  <graphml:edge
     source="{$character}"
     target="{'act' || $act || 'scene' || $scene/@n}"
     label=":Appears">
       <graphml:data key="label">appears</graphml:data>
  </graphml:edge>
};
```

After creating the requisite edges and nodes, our last task is to package both together as graphML. We'll opt for a directed property graph, reflecting our model above. This function may look intimidating, but it's primarily boilerplate. We are adding the namespace and schema reference we need to create a valid graphML document.

> Note that graphML does not allow `label` or `labels` attributes on edges and nodes. We're adding them because we want to add these features to our Neo4j representation of this graph.

We borrow a function from Priscilla Walmsley's `functx` library. While graphML does not impose any constraint on the order of edges and nodes, this function orders our nodes and edges.

```xquery
declare function local:make-graphml($data as element()* ) as element(graphml:graphml)? {
  <graphml:graphml
    xmlns:grapml="http://graphml.graphdrawing.org/xmlns"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
    <graphml:graph id="G" edgedefault="directed">
      {
        functx:distinct-deep(
          for $node in $data
          order by xs:string($node/fn:node-name()) descending, $node/@labels, ($node/graphml:data/text())[1]
          return $node)
      }
    </graphml:graph>
  </graphml:graphml>
};
```

The final result is a graphML document with our nodes and edges. We show a snippet below; you can check out the [full XML document in our data folder](data/jc-graph.xml). You can also check out the [complete query expression in the code folder](code/graph-tei.xqy). 

```xml
<graphml:graphml xmlns:graphml="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:grapml="http://graphml.graphdrawing.org/xmlns" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
  <graphml:graph id="G" edgedefault="directed">
    <graphml:node id="act1" labels=":Act">
      <graphml:data key="act">Act 1</graphml:data>
    </graphml:node>
    <graphml:node id="act2" labels=":Act">
      <graphml:data key="act">Act 2</graphml:data>
    </graphml:node>
    <graphml:node id="act3" labels=":Act">
      <graphml:data key="act">Act 3</graphml:data>
    </graphml:node>
    <graphml:node id="act4" labels=":Act">
      <graphml:data key="act">Act 4</graphml:data>
    </graphml:node>
    <graphml:node id="act5" labels=":Act">
      <graphml:data key="act">Act 5</graphml:data>
    </graphml:node>
    ...
    </graphml:edge>
    <graphml:edge source="JC" target="act1" labels=":Contains">
      <graphml:data key="label">contains</graphml:data>
    </graphml:edge>
    <graphml:edge source="JC" target="act2" labels=":Contains">
      <graphml:data key="label">contains</graphml:data>
    </graphml:edge>
    <graphml:edge source="JC" target="act3" labels=":Contains">
      <graphml:data key="label">contains</graphml:data>
    </graphml:edge>
    <graphml:edge source="JC" target="act4" labels=":Contains">
      <graphml:data key="label">contains</graphml:data>
    </graphml:edge>
    <graphml:edge source="JC" target="act5" labels=":Contains">
      <graphml:data key="label">contains</graphml:data>
    </graphml:edge>
  </graphml:graph>
</graphml:graphml>
```

You can now load The graphML document into a graph visualization tool like [Gephi](https://gephi.org/) or a graph database like [Neo4j](https://neo4j.com/) for analysis. Here's visualization of nodes and edges of our *Julius Caesar* graph in Neo4j.

> To load this example into Neo4j, you'll need to install Neo4j as well as the [APOC](https://github.com/neo4j-contrib/neo4j-apoc-procedures) procedures. After you have both set up, you can load this graph with the following Cypher command: `call apoc.import.graphml("https://github.com/CliffordAnderson/XQuery4Humanists/edit/master/data/jc-graph.xml, {batchSize: 10000, readLabels: true, storeNodeIds: false, defaultRelationshipType:"RELATED"})`

![Julius Caesar Graph in Neo4j](http://i.imgur.com/gai55cE.png)

In this session, we've scratched the surface of the possibilities of using XQuery to explore TEI documents. There is no more suitable tool for analyzing and interpreting TEI. The power of XQuery grows as you move from querying individual TEI documents to examining entire TEI corpora. As a challenge, can you create a graphML document, for instance, of the entire Folger Shakespeare TEI corpus, demonstrating the linkages among characters between plays?
