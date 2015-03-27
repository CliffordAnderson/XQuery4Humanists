#XQuery4Humanists

We're going to explore some fundamental concepts of XQuery and then try out some applications. If you're using the oXygen XML editor, we're assuming that you're using Saxon PE (professional edition) v. 9.5.1.7 and that you've turned on support for XQuery 3.0. Check your settings to make sure we'll all on the same page.

![Imgur](http://i.imgur.com/pAcmiju.png)

If you cannot get oXygen to work, don't worry! You can also execute these XQuery expressions using an hosted instance of [Zorba](http://try-zorba.28.io/queries/xquery), an open source XQuery and JSONiq processor. Just clear out the code and substitute the XQuery code you want to evaluate. 

##Introduction to Functional Programming

If you've programmed in a language like PHP or Python, you've probably been exposed to imperative and object-oriented constructs. XQuery belongs to a different strand of programming languages derived from the lambda calculus and related to programming languages like Erlang, Haskell, Lisp, and R. In functional programming languages, everything is an expression and all expressions evaluate to some value. While many programmers consider functional programming languages hard to learn, my experience is that first-time programmers find them easier to understand.

For example, try out this expression in XQuery:
```xquery
1 + 1
```
This expression evaluates to 2. Pretty simple, right? You can evaluate any function in XQuery in like manner. For instance, try:
```xquery
fn:upper-case("hello, world!")
```
Since all expressions evaluate to some value, you can use a expression in XQuery wherever you would use a value. For example, you can pass one expression as the input to another expression. This example takes a string ```"1,2,3"```, converts it into a sequence of three strings, reverse the order, and then joins the sequence of three strings back together.

```xquery
string-join(fn:reverse(fn:tokenize("1,2,3",",")),",")
```

This ability to substitute expressions with values is called [referential transparency](https://en.wikipedia.org/wiki/Referential_transparency_(computer_science)). In a nutshell, it means that your expression will always evaluate to the same value when given the same input. Programming in XQuery (and XSLT and R) is different from other kinds of programming because you're not producing 'side effects' such as updating the value of your variables.

###FLWOR Expressions

Things are already looking a little messy, aren't they? A fundamental construct in XQuery is the FLWOR expression. While you could write XQuery expressions without FLWOR expressions, you probably wouldn't want to. FLWOR expressions introduce some key concepts, including variable binding, sorting, and filtering. FLWOR stands for "for, let, where, order by, return."

* ```for``` iteratives over a sequence (technically, a "tuple stream"), binding a variable to each item in turn.
* ```let``` binds an variable to an expression.
* ```where``` filters the items in the sequence using a boolean test
* ```order by``` orders the items in the sequence.
* ```return``` gives the result of the FLWOR expression.

If you use a ```for``` or a ```let```, you must also provide a ```return```. ```where``` and ```order by``` are optional.

Let's take a look at an example of an XQuery expression. In this case, we'll iterate over a sequence of book elements and return fiction or nonfiction elements with titles as appropriate.

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
return element {$class} {$title}
```

XQuery 3.0 introduced a few new clauses to FLWOR expressions.

* ```group by```
* ```count```

Here's an example of ```group by```

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
return element {$class} {fn:string-join($title, ", ")}
```

Here's an example of ```count```

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
count $num
return element {$class} {$num || ". " || $title}
```
Try [Zorba](http://try-zorba.28.io/queries/xquery/AGJEUoN%2BXytamwW%2B2CgXzJ6rY74%3D) to see this query.

###Conditional Expressions

Like other programming languages, XQuery permits conditions expressions of the form ```if...then...else```. However, unlike other programming languages, the ```else``` case is always required. This is because an expression must always evaluate to a value. We'll be using ```if...then...else``` in some examples below. To make sure you understand how to use them, let's quickly code the famous (at least in programmers' circles) [fizzbuzz](http://c2.com/cgi/wiki?FizzBuzzTest) exercise in XQuery.

```xquery
xquery version "3.0";
 
(: Fizz Buzz in XQuery :)
 
for $i in (1 to 100)
return 
  if ($i mod 3 = 0 and $i mod 5 = 0) then "fizzbuzz"
  else if ($i mod 3 = 0) then "fizz"
  else if ($i mod 5 = 0) then "buzz"
  else $i
```
Ready to try it out on [Zorba](http://try-zorba.28.io/queries/xquery/TUTdQbUrDJ5IehMnHsGlej66A4M%3D)?

###User-Defined Functions

The great thing about XQuery is that many functions already come built into the language. Check out Priscilla Walmsley's very helpful [list of XQuery functions](http://www.xqueryfunctions.com/). The built-in functions all come prefixed with the ```fn``` namespace. Shall we try a few together?

Of course, it's also possible to write your own functions in XQuery. In fact, it's usually *necessary* to write new functions. You can do so in two ways. On the one hand, you can declare functions in the XQuery prologue. Or you can write anonymous functions. Let's take a look at both examples.

Here's a user-defined function to write a friendly hello to someone. Our function will accept a string representing someone's name as an argument and return a greeting in response.

```xquery
xquery version "3.0";

declare function local:say-hello($name as xs:string) as xs:string
{
    "Hello, " || $name || "!"
};

local:say-hello("Dave")
```

Another way of writing this function is to use a FLWOR expression. In this case, we'll write an anonymous function, meaning we cannot access it by name, and bind it to a variable with a ```let``` clause. We'll then use the ```return``` clause to call and evaluate the function.

```xquery
xquery version "3.0";

let $say-hello := function($name as xs:string) as xs:string {"Hello, " || $name || "!" }
return $say-hello("Dave")
```

Whether you declare named functions in your prologue or assign anonymous functions to variables in your expression body depends on the purpose you intend to achieve.

##Pig Latin in XQuery

My son Theodore loves to speak Pig Latin. He can speak it really fast, making it difficult for my wife and I to follow him. Wouldn't it be helpful to have a Pig Latin interpreter, I thought? So let's write a basic parser for Pig Latin in XQuery this month.

The rules for [Pig Latin](https://en.wikipedia.org/wiki/Pig_Latin) are relatively simple though different dialects exist, as we shall see. Let's take the simplest dialect first. Basically, to turn any English word into an equivalent word in Pig Latin you take the first consonant off the front of the word, add it to the end, and then add "ay." If your word already starts with a vowel, then just add "ay" to the end. Thus, "Hello" becomes "Ellohay." "I" becomes "Iay."

###Exercise #1

So, for our first exercise, let's write a basic XQuery expression that takes a word and returns its equivalent this dialect of Pig Latin. 

*Hint: If you need help getting started, try using this function: [fn:substring](http://www.xqueryfunctions.com/xq/fn_substring.html)*

Ready to compare your expression?Here's what I came up with...[Zorba](http://try-zorba.28.io/queries/xquery/QK5qu0xXmoe16U2ruUvUJMyf768%3D) and [Gist](https://gist.github.com/CliffordAnderson/076b5e82f1d7e22e05ca)

###Exercise #2

Now that we can convert individual words to Pig Latin, let's move on to sentences. Try to write an expression to convert sentences to Pig Latin. It's OK if you strip away punctuation to do so, though you get extra credit if you retain it. Write an expression to convert, e.g., "I speak Pig Latin" to "Iay peaksay igpay atinlay".

*Hint: You'll probably want to use the functions [fn:tokenize](http://www.xqueryfunctions.com/xq/fn_tokenize.html) to split up your sentence into words and [fn:string-join](http://www.xqueryfunctions.com/xq/fn_string-join.html) to recompose your words into a sentence.*

Ready to compare your expression? Here's my go at it... [Zorba](http://try-zorba.28.io/queries/xquery/viIDlwPueygREld7%2FOCE3n9AYEE%3D) and [Gist](https://gist.github.com/CliffordAnderson/e75fd3e4e3e569a661cf)

###Exercise #3

I mentioned that other dialectics of Pig Latin exist. In fact, we speak a different version at home. In this version, all the consonants preceeding the vowel must be moved to the end of the word before adding "ay". So "there" becomes "erethay." If the word starts with a vowel, then the rules remain the same as previously. Your function should turn "I speak Pig Latin" into "Iay eakspay igpay atinlay"

If you know how to use regular expressions, you might write the expression like this.

```xquery
xquery version "3.0";

let $phrase := "I speak Pig Latin"
for $word in fn:tokenize($phrase, " ")
return
    if (fn:count($word) > 1) then
        let $first := fn:replace($word, "^(.*?)[a,e,i,o,u].*", "$1")
        let $last := fn:replace($word, "^.*?([a,e,i,o,u].*)", "$1")
        return $last || $first || "ay"
    else
        $word || "ay"
```

But we're going to try not to use regular expressions when we don't need to. 

*Hint: A good way to approach this problem without relying on regular expressions is to write a recursive function to handle moving the leading consonants to the end of each word.*

Ready to check your work? Here's how I did it... [Zorba](http://try-zorba.28.io/queries/xquery/htyppNcHns5R%2BLIHC%2FJz%2BmlQGDU%3D) and [Gist](https://gist.github.com/CliffordAnderson/6ed7e1f9a32abf15d9fd)

*Bonus Credit: Remember that recursion always requires a base case. In my example, the base case works most of the time but will not always work. Can you create an example where it will fail? Actually, don't try this in class–recursion is painful to the nth degree when it fails.* 

There are always lots of different ways to accomplish a task in any programming language, though some may have subtle bugs and others may be less straightforwrd. [Here are a few other attempts at a Pig Latin parser in XQuery](https://gist.github.com/CliffordAnderson/a1ac3141828b504ee756/edit). If we have time, we might look at these. Otherwise, please try them out yourself and see if you can spot any bugs.

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

Hint: You'll probably need to use regular expressions in ```local:collect-words()``` to clean up the strings. If so, this function ```fn:replace($words, "[!?.',/-]", "")``` should do the trick nicely.

Give it a try yourself before checking out what I came up with... [Zorba](http://try-zorba.28.io/queries/xquery/ZZf2fGYOwtkBvN8sbzI4cX4plYw%3D) and [Gist](https://gist.github.com/CliffordAnderson/468e0b6a8ee6143676f9). 

Extra Credit: Add an expression to the query to eliminate common stop-words–i.e. "of," "the," etc.–from your dictionary.

##Exploring Shakespeare

Finally, let's tackle a few more complicated XQuery expressions using the [Folger Digital Texts](http://www.folgerdigitaltexts.org/) of William Shakespeare. To understand these expressions, you'll need to acquaint yourself a bit with the TEI markup used in this digital edition. Here's two snippets from *Julius Caesar*.

First, let's look at ```<listPerson>``` 'list of persons'. Here we see a number of persons related to Julius Caesar, including Caesar himself, his wife Calphurnia, and their servants. There are similar lists of persons for other characters and roles in the play.

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

##Wrapping Up

I hope that you've enjoyed this brief tour of XQuery. Please [be in touch](http://www.library.vanderbilt.edu/scholarly/) if you have any questions.

Feel free to improve on these examples and to share your work with everyone else. The easiest way to do that is to write your expression in [Zorba](try-zorba.28.io) and then tweet out the permalink to [#prog4humanists](https://twitter.com/hashtag/prog4humanists). I look forward to seeing how you improve on my work! :)

Many thanks to [Dr. Laura Mandell](http://idhmc.tamu.edu/the-director/) and her colleagues at the [Initiative for Digital Humanities, Media, and Culture](http://idhmc.tamu.edu/) for the opportunity to lead this session of her [Programming4Humanists](http://www.programming4humanists.org/) series.
