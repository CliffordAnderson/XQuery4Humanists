# XQuery4Humanists

###FLWOR Expressions

```xquery
let $books :=
  <books>
    <book class="fiction">Book of Strange New Things</book>
    <book class="nonfiction">Programming Scala</book>
    <book class="fiction">Absurdistan</book>
    <book class="nonfiction">Art of R Programming</book>
    <book class="fiction">I, Robot</book>
  </books>
for $book in $books/book
let $title := $book/text()
let $class := $book/@class
order by $title
group by $class
return ($class, $title)
```

##Word Frequencies in XQuery

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

I've also provided [a gist with the poem](https://gist.github.com/CliffordAnderson/2045cefaf2a687e5d078/), in case you'd like to use it.

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

Hint: You'll probably need to use regular expressions to clean up the strings. If so, this function ```fn:replace($words, "[!?.',/-]", "")``` should do the trick nicely.

Give it a try yourself before checking out [what I came up with](http://try-zorba.28.io/queries/xquery/ZZf2fGYOwtkBvN8sbzI4cX4plYw%3D). I'm sure you can do better, right? If you've found a simpler solution, tweet it out to #XQY14.

Extra Credit: Add an expression to the query to eliminate common stop-words–i.e. "of," "the," etc.–from your dictionary.


##Pig Latin in XQuery

My son Theodore loves to speak Pig Latin. He can speak it really fast, making it difficult for my wife and I to follow him. Wouldn't it be helpful to have a Pig Latin interpreter, I thought? So let's write a basic parser for Pig Latin in XQuery this month.

The rules for [Pig Latin](https://en.wikipedia.org/wiki/Pig_Latin) are relatively simple though different dialects exist, as we shall see. Let's take the simplest dialect first. Basically, to turn any English word into an equivalent word in Pig Latin you take the first consonant off the front of the word, add it to the end, and then add "ay." If your word already starts with a vowel, then just add "ay" to the end. Thus, "Hello" becomes "Ellohay." "I" becomes "Iay."

###Exercise #1

So, for our first exercise, let's write a basic XQuery expression that takes a word and returns its equivalent in Pig Latin. Since we did not cover [regular expressions](https://en.wikipedia.org/wiki/Regular_expression) during our summer institute, I invite you to attempt the expression without their use.

*Hint: If you need help getting started, try using these functions: [fn:substring](http://www.xqueryfunctions.com/xq/fn_substring.html) and [fn:lower-case](http://www.xqueryfunctions.com/xq/fn_lower-case.html).*

Ready to compare your expression? [Here's what I came up with...](http://try-zorba.28.io/queries/xquery/QK5qu0xXmoe16U2ruUvUJMyf768%3D) [Gist](https://gist.github.com/CliffordAnderson/076b5e82f1d7e22e05ca)

###Exercise #2

Now that we can convert individual words to Pig Latin, let's move on to sentences. Try to write an expression to convert sentences to Pig Latin. It's OK if you strip away punctuation to do so, though you get extra credit if you retain it. Write an expression to convert, e.g., "I speak Pig Latin" to "Iay peaksay igpay atinlay".

*Hint: You'll probably want to use the functions [fn:tokenize](http://www.xqueryfunctions.com/xq/fn_tokenize.html) to split up your sentence into words and [fn:string-join](http://www.xqueryfunctions.com/xq/fn_string-join.html) to recompose your words into a sentence.*

Ready to compare your expression? [Here's my go at it.](http://try-zorba.28.io/queries/xquery/viIDlwPueygREld7%2FOCE3n9AYEE%3D) [Gist](https://gist.github.com/CliffordAnderson/e75fd3e4e3e569a661cf)

###Exercise #3

I mentioned that other dialectics of Pig Latin exist. In fact, we speak a different version at home. In this version, all the consonants preceeding the vowel must be moved to the end of the word before adding "ay". So "there" becomes "erethay." If the word starts with a vowel, then the rules remain the same as previously.Your function should turn "I speak Pig Latin" into "Iay eakspay igpay atinlay"

*Hint: A good way to approach this problem without relying on regular expressions is to write a recursive function to handle moving the leading consonants to the end of each word.*

Ready to check your work? [Here's how I did it.](http://try-zorba.28.io/queries/xquery/htyppNcHns5R%2BLIHC%2FJz%2BmlQGDU%3D) [Gist](https://gist.github.com/CliffordAnderson/6ed7e1f9a32abf15d9fd)

*Bonus Credit: Remember that recursion always requires a base case. In my example, the base case works most of the time but will not always work. Can you create an example where it will fail?*

###Exploring Shakespeare
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



```xquery
xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $doc := fn:doc("https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml")
return element appearances 
  {
      let  $persons := $doc//tei:person/@xml:id !  fn:concat("#", .)
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

Please feel free to improve on these examples and to share your work with everyone else. The easiest way to do that is to write your expression in [Zorba](try-zorba.28.io) and then tweet out the permalink to [#prog4humanists](https://twitter.com/hashtag/prog4humanists). I look forward to seeing how you improve on my work! :)

