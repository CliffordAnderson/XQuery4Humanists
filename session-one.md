## Session One

### Introduction to Functional Programming

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

### FLWOR Expressions

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

XQuery 3.0 introduced a two new clauses to FLWOR expressions.

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

### Conditional Expressions

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

### User-Defined Functions

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

### Problem Sets

#### Pig Latin in XQuery

My son Theodore loves to speak Pig Latin. He can speak it really fast, making it difficult for my wife and I to follow him. Wouldn't it be helpful to have a Pig Latin interpreter, I thought? So let's write a basic parser for Pig Latin in XQuery this month.

The rules for [Pig Latin](https://en.wikipedia.org/wiki/Pig_Latin) are relatively simple though different dialects exist, as we shall see. Let's take the simplest dialect first. Basically, to turn any English word into an equivalent word in Pig Latin you take the first consonant off the front of the word, add it to the end, and then add "ay." If your word already starts with a vowel, then just add "ay" to the end. Thus, "Hello" becomes "Ellohay." "I" becomes "Iay."

*Exercise #1*

So, for our first exercise, let's write a basic XQuery expression that takes a word and returns its equivalent this dialect of Pig Latin.

*Hint: If you need help getting started, try using this function: [fn:substring](http://www.xqueryfunctions.com/xq/fn_substring.html)*

Ready to compare your expression? [Here's what I came up with...](https://gist.github.com/CliffordAnderson/076b5e82f1d7e22e05ca)

*Exercise #2*

Now that we can convert individual words to Pig Latin, let's move on to sentences. Try to write an expression to convert sentences to Pig Latin. It's OK if you strip away punctuation to do so, though you get extra credit if you retain it. Write an expression to convert, e.g., "I speak Pig Latin" to "Iay peaksay igpay atinlay".

*Hint: You'll probably want to use the functions [fn:tokenize](http://www.xqueryfunctions.com/xq/fn_tokenize.html) to split up your sentence into words and [fn:string-join](http://www.xqueryfunctions.com/xq/fn_string-join.html) to recompose your words into a sentence.*

Ready to compare your expression? [Here's my go at it...](https://gist.github.com/CliffordAnderson/e75fd3e4e3e569a661cf)

*Exercise #3*

I mentioned that other dialectics of Pig Latin exist. In fact, we speak a different version at home. In this version, all the consonants preceeding the vowel must be moved to the end of the word before adding "ay". So "there" becomes "erethay." If the word starts with a vowel, then the rules remain the same as previously. Your function should turn "I speak Pig Latin" into "Iay eakspay igpay atinlay"

If you know how to use regular expressions, you might write the expression like this.

```xquery
xquery version "3.0";

let $phrase := "I speak Pig Latin"
for $word in fn:tokenize($phrase, " ")
return
    if (fn:count($word) > 1) then
        let $first := fn:replace($word, "^(.*?)[aeiou].*", "$1")
        let $last := fn:replace($word, "^.*?([aeiou].*)", "$1")
        return $last || $first || "ay"
    else
        $word || "ay"
```

But we're going to try not to use regular expressions when we don't need to.

*Hint: A good way to approach this problem without relying on regular expressions is to write a recursive function to handle moving the leading consonants to the end of each word.*

Ready to check your work? [Here's how I did it...](https://gist.github.com/CliffordAnderson/6ed7e1f9a32abf15d9fd)

*Bonus Credit: Remember that recursion always requires a base case. In my example, the base case works most of the time but will not always work. Can you create an example where it will fail? Actually, don't try this in class–recursion is painful to the nth degree when it fails.*

There are always lots of different ways to accomplish a task in any programming language, though some may have subtle bugs and others may be less straightforward. [Here are a few other attempts at a Pig Latin parser in XQuery](https://gist.github.com/CliffordAnderson/a1ac3141828b504ee756). If we have time, we might look at these. Otherwise, please try them out yourself and see if you can spot any bugs.
