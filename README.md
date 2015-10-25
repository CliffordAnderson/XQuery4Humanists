#XQuery4Humanists

##Session One

We're going to explore some fundamental concepts of XQuery and then try out some applications. If you're using the oXygen XML editor, we're assuming that you're using Saxon PE (professional edition) v. 9.5.1.7 and that you've turned on support for XQuery 3.0. Check your settings to make sure we'll all on the same page.

![Imgur](http://i.imgur.com/pAcmiju.png)

If you cannot get oXygen to work, don't worry! You can also execute these XQuery expressions using an hosted instance of [Zorba](http://try-zorba.28.io/queries/xquery), an open source XQuery and JSONiq processor. Just clear out the code and substitute the XQuery code you want to evaluate. 

###Introduction to Functional Programming

If you've programmed in a language like PHP or Python, you've probably been exposed to imperative and object-oriented constructs. The distinguishing feature of such programming languages is that they rely on changes of state to process information. That is, they require you to tell the computer how to process your ideas step-by-step, kind of like when you are making a recipe and taking the flour from a dry mix to dough to some baked good.

XQuery belongs to a different strand of programming languages derived from the lambda calculus and related to programming languages like Erlang, Haskell, Lisp, and R. In functional programming languages, everything is an expression and all expressions evaluate to some value. Clear? :) A simpler way of putting things is that in functional programming you write functions that take a value as input and produce a value as an output. So, returning to our baking example, 

While many programmers consider functional programming languages hard to learn, my experience is that first-time programmers find them easier to understand.

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

Functions represent the heart of functional programming but they can appear a little intimidating at first. The basic idea of a function is to break up complicated code into nice, simple, smaller units. A function also allows us to control better the information we receive and the outputs we provide.

Before we get started writing functions in XQuery, let's try to explore the concept in pseudo-code, i.e. something that looks like code but doesn't actually run. Let's say that we want to write a function for our local diner. Imagine that every order can be supplemented with a salad if you choose. So we'll need to update the order for the chef and also the price of the meal whenever someone decides to compliment the meal with a salad.

So our pseudo-function would look something like this:
```
order -> "French Dip Sandwich", salad -> true
	function add-salad
		if salad is true, then order -> "French Dip Sandwich & Salad"
		otherwise order stays the same
```
In other words, we take the initial food order, add information about whether the patron also wants a salad, and return an updated order based on the result. Fairly straightforward, right?

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

Let's get back to our pseudo-function that we sketch out at top. How may we turn this pseudo-code into a real XQuery expression? Let's write the function first. Remember that we want to take a food choice and a yes/no (true/false) decision about whether to add a salad as inputs and then return a combined food choice as a result. Below is a first pass at writing that function.

```xquery
xquery version "3.1"; 

declare function local:add-salad($food, $salad)
{
	if ($salad = true()) then $food || " and salad"
	else $food
};
```
To call this function we need a main expression body. It's actually pretty simple.
```xquery
local:add-salad("Steak",false())
```
Et voilá! You have written a function to add (or not) salads to every food order. Still, there is a problem. What if someone sends a malformed order? For example, what if patron just asked for 1 with a salad. What would happen? We'd get back the result ```1 and salad```. Even stranger, what happens when someone orders "Fish" and says "No" to salad. We'd an error saying ```Items of type xs:string and xs:boolean cannot be compared.``` What does that mean? Isn't there a way to check for these errors before they happen? 

In fact, there is. In the fancy language of computer science, this is called type checking. Basically, we want to define what type of information can go into our function and also what type of information can be returned as values by our function. In XQuery, we can check the types in the so-called function signature. Here's how we do that.
```xquery
xquery version "3.1"; 

declare function local:add-salad($food as xs:string, $salad as xs:boolean) as xs:string
{
	if ($salad = true()) then $food || " and salad"
	else $food
};

local:add-salad("Fish", true())
```
By adding the clause ```as xs:string``` and ```as xs:boolean``` you limit the range of acceptable values to strings and booleans respectively. The ```as xs:string``` after the paragraph indicates that the return value will always be a string. While it's not strictly necessary to add types to your inputs and to your return values, it's a very good habit to get into. You'll find that if you cannot determine what type of information your function can accept and what type of information your function will return, you probably don't really understand what your function is doing.


Whether you declare named functions in your prologue or assign anonymous functions to variables in your expression body depends on the purpose you intend to achieve.

###Problem Sets

####Pig Latin in XQuery

My son Theodore loves to speak Pig Latin. He can speak it really fast, making it difficult for my wife and I to follow him. Wouldn't it be helpful to have a Pig Latin interpreter, I thought? So let's write a basic parser for Pig Latin in XQuery this month.

The rules for [Pig Latin](https://en.wikipedia.org/wiki/Pig_Latin) are relatively simple though different dialects exist, as we shall see. Let's take the simplest dialect first. Basically, to turn any English word into an equivalent word in Pig Latin you take the first consonant off the front of the word, add it to the end, and then add "ay." If your word already starts with a vowel, then just add "ay" to the end. Thus, "Hello" becomes "Ellohay." "I" becomes "Iay."

*Exercise #1*

So, for our first exercise, let's write a basic XQuery expression that takes a word and returns its equivalent this dialect of Pig Latin. 

*Hint: If you need help getting started, try using this function: [fn:substring](http://www.xqueryfunctions.com/xq/fn_substring.html)*

Ready to compare your expression?Here's what I came up with...[Zorba](http://try-zorba.28.io/queries/xquery/QK5qu0xXmoe16U2ruUvUJMyf768%3D) and [Gist](https://gist.github.com/CliffordAnderson/076b5e82f1d7e22e05ca)

*Exercise #2*

Now that we can convert individual words to Pig Latin, let's move on to sentences. Try to write an expression to convert sentences to Pig Latin. It's OK if you strip away punctuation to do so, though you get extra credit if you retain it. Write an expression to convert, e.g., "I speak Pig Latin" to "Iay peaksay igpay atinlay".

*Hint: You'll probably want to use the functions [fn:tokenize](http://www.xqueryfunctions.com/xq/fn_tokenize.html) to split up your sentence into words and [fn:string-join](http://www.xqueryfunctions.com/xq/fn_string-join.html) to recompose your words into a sentence.*

Ready to compare your expression? Here's my go at it... [Zorba](http://try-zorba.28.io/queries/xquery/viIDlwPueygREld7%2FOCE3n9AYEE%3D) and [Gist](https://gist.github.com/CliffordAnderson/e75fd3e4e3e569a661cf)

*Exercise #3*

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

There are always lots of different ways to accomplish a task in any programming language, though some may have subtle bugs and others may be less straightforward. [Here are a few other attempts at a Pig Latin parser in XQuery](https://gist.github.com/CliffordAnderson/a1ac3141828b504ee756/edit). If we have time, we might look at these. Otherwise, please try them out yourself and see if you can spot any bugs.

##Session Two

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

##Session Three

###XML Databases

XQuery is a powerful language for exploring and drawing results from individual XML documents. However, its real power comes to the fore when you combine it with XML databases. In this session, we're going to explore how to use XQuery in BaseX, an open source XML database.

![BaseX, an open source XML Database](http://i.imgur.com/twQUdGH.png)

###Loading CSV

A common challenge when loading data into an XML database is turning it from some other format into XML. For example, you might have data stored in Excel or perhaps a relational database like Access or MySQL. Consider, for example, the tabular data shown below.

[A CSV file on Github](http://i.imgur.com/tYLvWJ2.png)

How would we load the information in this file into BaseX? Fortunately, BaseX has you covered. There are two functions in BaseX that you can use in combination to load a CSV file and convert it to XML.  Let's try them out!

The CSV file shown above is available on [Github](https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv). First, we'll write a function to grab the text from Github and display it as a CSV. To do this, we'll use a BaseX function called [fetch:text](http://docs.basex.org/wiki/Fetch_Module#fetch:text), which just grabs the content of websites and returns them as a big string of text. So we can get the CSV with this code:
```xquery
xquery version "3.1";

let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
return $csv
```
The only complicated part of this expression is the crazy long URL for the CSV file. Otherwise, it's simple and straightforward, right? Our next step is to convert the CSV into XML. In this case, there's a function called [csv:parse](http://docs.basex.org/wiki/CSV_Module) that converts CSV files into XML files. Here's how it works.
```xquery
xquery version "3.1";

let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
let $books := csv:parse($csv)
return $books
```

Nice, right? The only problem with the output is that it's pretty generic. In particular, the entries do not differentiate between authors, titles, ISBNs, binding, and publication dates. So it would be easy to get lost when query this document, mistakenly asking for the ISBN when you actually wanted a date, for instance. 

![CSV without labelled entries](http://i.imgur.com/2k6fVoq.png)

Fixing the problem is also relatively straightforward, though you'll notice a new syntax. What's up with that strange ```map``` syntax?

```xquery
xquery version "3.1";

let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
let $books := csv:parse($csv, map {'header':'true'} )
return $books
```
The ```map {'header':'true'}``` is an [XQuery Map](http://docs.basex.org/wiki/XQuery_3.1#Maps). Maps and arrays are being introduced into XQuery primarily to handle a widely used format called JSON. (While there's more to XQuery maps than JSON compatibility, we don't need to worry about other uses here.)  JSON stands for JavaScript Object Notation. It's a lightweight format originally designed for use with JavaScript but now frequently employed to transmit information back and forth on the Internet. We'll see that kind of use in a moment. Here, however, we're using this XQuery map to provide some configuration information. The map is essentially acting like a config file for the function, telling it that the CSV has defined headers. After calling the expression with the configuration information provided by the map, we get a much more articulate result.

![CSV with headers as entries]http://i.imgur.com/jS8aNZm.png[/img]

Not bad for a few lines of code, right? But, wait, there's more! Let's not just leave our data as is. Let's combine it with another source of data on the internet. In our next section, we'll learn a little more about JSON and how to interact with APIs that only provide JSON data.

For this example, we'll be drawing on an API (Application Programming Interface) provided by the Open Library: the [Open Library Read API](https://openlibrary.org/dev/docs/api/read). We will use this API to enrich our book information with additional details. The API allows us to pass in an ISBN and receive a whole bunch of additional information in JSON format. To do so, we just concatenate this base URL (http://openlibrary.org/api/volumes/brief/isbn/) with an ISBN and add .json to the end. For example, the ISBN of Jeannette Walls' *The Glass Castle* is 074324754X. So the URL to retrieve the JSON is [http://openlibrary.org/api/volumes/brief/isbn/074324754X.json](http://openlibrary.org/api/volumes/brief/isbn/074324754X.json). Try it and see what you get back! Looks a little complicated right? You can actually use oXygen to 'pretty print' or format JSON. Suitably cleaned up, the JSON looks like this:

![JSON data about the Glass Castle](http://i.imgur.com/da92Xze.png)

Just a short (and terminologically free) note about the syntax. The square brackets represent arrays, meaning that they contain zero to many ordered values. The curly brackets represent objects, which contain keys on the left side of the colon and values on the right side. If you are using a string as a key or value, then you must put it in quotation marks. You can read the [whole JSON specification](http://www.json.org/) in less than ten minutes.

To fetch the JSON with XQuery, we write an expression very similar to our initial expression to fetch a CSV document.

```xquery
xquery version "3.1";

let $url := "http://openlibrary.org/api/volumes/brief/isbn/074324754X.json"
let $json := fetch:text($url)
return $json
```
We can treat JSON as text but it would be easier to convert it to XML so that we can work with it in a more familiar format. XQuery 3.1 introduces a new built-in function to produce this conversion: [fn:json-to-xml](http://docs.basex.org/wiki/XQuery_3.1#fn:json-to-xml). As you see, the usage of this function is very similar to ```csv:parse```.

```xquery
xquery version "3.1";

let $url := "http://openlibrary.org/api/volumes/brief/isbn/074324754X.json"
let $json := fetch:text($url)
let $book := fn:json-to-xml($json)
return $book
````
Our next step is to join these two sources of information together. Let's write a query that converts our CSV of book data to XML, collects all the ISBNs, queries the Open Library for the subject information, and adds that information back to the XML document . Whew! Sounds complicated, right? Let's give it a shot!

We start by modifying our initial expression to get and convert the CSV of book data. But this time we won't return the data. Instead, we'll pass the ISBNs into a function that queries the Open Library for more information. 

Let's proceed step-by-step. We will build a function first that takes an ISBN and returns ```<subject>``` elements with the respective subjects as child text nodes.

```xquery

declare function local:get-subjects-by-isbn($isbn as xs:string) as element()*
{
  let $url := "http://openlibrary.org/api/volumes/brief/isbn/" || $isbn || ".json"
  let $json := fetch:text($url)
  let $book-data := fn:json-to-xml($json)
  for $subject in $book-data//xf:array[@key="subjects"]/xf:string/text()
  return element subject {$subject}
};
```

The final line converts the text nodes into elements using something called a [computed element constructor](http://www.w3.org/TR/xquery/#id-computedElements). Basically, we take a bunch of strings and wrap them into subject elements in order to include them with the other elements in our book records.

The body of the query expression looks like this:

```xquery
let $url := "https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/c362876f6f6b4ec6755069a3ab256fb01d495616/data/books.csv"
let $csv := fetch:text($url)
let $books := csv:parse($csv, map {'header':'true'} )
let $records :=
  for $book in $books/csv/record
  let $subjects := local:get-subjects-by-isbn($book/ISBN/text())
  let $record := element record {($book/*, $subjects)}
return element csv {$records}
```
This expression is basically the same as our previous expression, apart from iterating through the list of books to gather the subjects for each book individually. Perhaps the only tricky thing about this expression appears in this sub-expression ```element record {($book/*, $subjects)}```. Here we are creating a new record element by combining the entry elements from the previous book element with the new subject elements we've retrieved from the Internet Archive. If you look closely at the last two lines, you'll realize that we're not actually changing the original $book document; we are just creating a copy with more information added. As we mentioned at the outset, functional languages generally avoid changing state; once you define a variable, you can't change it. Here, we get around that problem (or feature!) by generating a new CSV element combining information from both sources.

Here's the full XQuery expression:

```xquery
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
return element csv {$records}
```
and also a resulting record with the added subject information:
![CSV record with added subject information](http://i.imgur.com/WklULX7.png)

###Wrapping Up

I hope that you've enjoyed this brief tour of XQuery. Please [be in touch](http://www.library.vanderbilt.edu/scholarly/) if you have any questions. I'm always glad to help whenever I can.

Feel free to improve on these examples and to share your work with everyone else. The easiest way to do that is to write your expression in [Zorba](try-zorba.28.io) and then tweet out the permalink to [#prog4humanists](https://twitter.com/hashtag/prog4humanists). I look forward to seeing how you improve on my work! :)

Many thanks to [Dr. Laura Mandell](http://idhmc.tamu.edu/the-director/) and her colleagues at the [Initiative for Digital Humanities, Media, and Culture](http://idhmc.tamu.edu/) for the opportunity to lead these three sessions of her [Programming4Humanists](http://www.programming4humanists.org/) series.
