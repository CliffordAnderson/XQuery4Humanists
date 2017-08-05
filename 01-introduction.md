## Session One

In this session, you will learn the basics of the [XQuery](https://www.w3.org/TR/xquery-31/) programming language. I cannot cover the full XQuery specification in this introductory lesson. I hope to provide enough on an orientation for you to get started with the XQuery and to start solving some real problems.

### Learning Outcomes

* Understand why XQuery makes a good fit for digital humanists;
* Apply XQuery FLWOR expressions to manipulate XML Data;
* Solve problems with simple user-defined functions in XQuery.

### Introduction

If you've programmed in a language like PHP or Python, you've used imperative and object-oriented constructs. The distinguishing feature of such programming languages is that they rely on changes of state to process information. That is, they require you to tell the computer how to process your ideas step-by-step, kind of like when you are making a recipe and taking the flour from a dry mix to dough to some baked good.

XQuery belongs to a different strand of programming languages derived from the lambda calculus and related to programming languages like Erlang, Haskell, Lisp, and R. In functional programming languages, everything is an expression and all expressions evaluate to some value. Clear? :) A simpler way of putting things is that in functional programming you write functions that take a value as input and produce a value as an output. So, returning to our baking example,

While imperative programmers consider functional programming languages hard to learn, my experience is that first-time programmers find them easier to understand.

For example, try out this expression in XQuery:

```xquery
1 + 1
```
This expression evaluates to 2. Pretty simple, right? You can evaluate any function in XQuery in like manner. For instance, try:

```xquery
fn:upper-case("hello, world!")
```

Since all expressions evaluate to values, you can use a expression in XQuery wherever you would use a value. For example, you can pass one expression as the input to another expression. This example takes a string `"1,2,3"`, converts it into a sequence of three strings, reverse the order, and then joins the sequence of three strings back together.

```xquery
fn:string-join(fn:reverse(fn:tokenize("1,2,3",",")),",")
```

This ability to substitute expressions with values is called [referential transparency](https://en.wikipedia.org/wiki/Referential_transparency_(computer_science)). Your expression will always evaluate to the same value when given the same input. Programming in XQuery (and XSLT and R) is different from other kinds of programming because you're not producing 'side effects' such as updating the value of your variables.

### A Bit of Syntax

Like any programming language, you need to memorize a bit of syntax and operators to write XQuery expressions. This does not cover all the syntax, but here are some key parts.

| Syntax        | Meaning                                     |
| ------------- | -------------                               |
| `( )`         | sequence constructor                        |
| `:=`          | assignment, binds a variable to a value     |
| `(:  :)`      | XQuery comment, not interpreted             |
| `&#124;&#124;`| concatenation, joins together two strings   |
| `!`           | simple mapping operator, applies a function on right to value on the right |
| `=>`          | arrow operator, pipes the value on the left to the function on the right   |

If you have used XPath to work with XML documents, you will also recognize these operators and path expressions, since XPath is actually a subset of XQuery (and in fact all of the entries above are part of XPath):

| Syntax        | Meaning                                          |
| ------------- | -------------                                    |
| `/`           | path operator                                    |
| `//`          | compact syntax for descendant-or-self::node()/   |
| `*`           | compact syntax for child::element() or wildcard  |
| `.`           | compact syntax for self::node()                  |


### FLWOR Expressions

Our code is already looking a little messy, isn't it? A fundamental construct in XQuery is the *FLWOR expression*. While you could write XQuery expressions without FLWOR expressions, you probably wouldn't want to. FLWOR expressions introduce some key concepts, including variable binding, sorting, and filtering. FLWOR stands for "*for*, *let*, *where*, *order by*, *return*"—each *clauses* that make up a FLWOR *expression*.

* `for` iteratives over a sequence (technically, a "tuple stream"), binding a variable to each item in turn.
* `let` binds an variable to an expression.
* `where` filters the items in the sequence using a boolean test
* `order by` orders the items in the sequence.
* `return` gives the result of the FLWOR expression.

If you use a `for` or a `let`, you must also provide a `return`. The `where` and `order by` clauses are optional.

Here's a simple FLWOR expression using just `let` to bind a variable and then and `return` to return its value.

```xquery
let $date := fn:current-date()
return $date
```

Try it out and see what you date get back. By the way, did you notice that we broke a fundamental rule we described above?

Here's a basic FLWOR expression that uses a `for` clause to iterate through several cities, binding each in turn to the variable `$city`, and using the `return` clause to return the count the number of characters of each city name.

```xquery
for $city in ("Chicago", "New York", "Nashville", "Montreal")
return fn:string-length($city)
```

Which city wins for longest name? Which for shortest?

> Why are there parentheses surrounding the names of the cities? Why are city names in quotation marks? Why the need for this extra syntax? The quotation marks indicate that we're dealing with strings rather than, say, numbers or XML element names. We need to include the parentheses to make clear that we're dealing with a *sequence* of strings (see the table of syntax above). If we wrote `for $city in "Chicago", "New York"`, then our XQuery interpreter would assume that we were introducing a new clause in our FLWOR expression rather than a sequence of items. The parentheses definitely resolve that interpretative ambiguity.

You can combine `for` and `let` clauses and also use them more than once. Let's take a look at an example of an XQuery FLWOR expression. In this case, we'll iterate over a sequence of book elements and return fiction or nonfiction elements with titles as appropriate.

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
return $book
```

Try using running this expression. Note that the book names are out of order. Can you put them into alphabetical order by adding another clause to the FLWOR? See this [gist](https://gist.github.com/CliffordAnderson/618702a8987629476f81506912a4e258) for the solution. Can you use another clause to filter out the nonfiction books? [Here's how](https://gist.github.com/CliffordAnderson/50d512f9d03c09f389c9ffe5345a8b73).

XQuery 3.0 introduced two new clauses to FLWOR expressions.

* `group by`
* `count`

The `group by` clause organizes sequences into related buckets. Can you add a `group by` to the example below to split the list into fiction and nonfiction?

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
order by $book/text()
return $book
```

Did you run into problems? If so, were you trying to add the `group by` clause along these lines: `group by $book/@class`? If so, then you will have encountered an error. The problem is that the grouping key, that is, the buckets you'd like to use to group items, must be available when you start grouping. It's easy to fix this error. You can either assign the group key in advance using a `let` clause or you can bind it in the `group by` as follows: `group by $book/@class`.

The results of applying the `group by` may not look impressive at first, but consider that you can also create new elements to sort out these groups. In the example below, we'll use a [computed element constructor](https://www.w3.org/TR/xquery-31/#id-computedElements) to create parent elements for the groups of fiction and nonfiction books.

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
return element {$class} {$title}
```

The lists of titles are still a little messy. Any thoughts about how to clean them up?

The other new clause of the FLWOR expression is `count`. This is one of those features that beginning students find very useful. Here's an example of `count`:

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
order by $title
count $num
return $num || ". " || $title
```

Other ways exist to count in FLWOR expressions, but it's easy to get the order mixed up as you manipulate the tuple stream. Try combining `group by` with `count` to see what I mean. Can you partition books into fiction and nonfiction while also order the books sequentially in those groups? Try it out yourself, then check my [solution](https://gist.github.com/CliffordAnderson/35cde75043b55ab8a213d3e0449941c9).

> Note for eXist users: Unfortunately the `count` clause has not yet been implemented in eXist. Luckily, a workaround is available: first, use the `at` clause to bind the variable `$num` to the current position of the interation through the books and (b) use either an intermediate FLWOR to pre-sort the books or, as shown here, the `fn:sort` function:
> 
> ```xquery
> for $book at $num in fn:sort($books/book)
> let $title := $book/text()
> return $num || ". " || $title
> ```

### Quantified Expressions  

What if you want to ask whether items in a sequence meet certain criteria? For instance, we might want to ask whether any names in a list contain initials. This would be useful, for instance, if you are standardizing name authority records. Here's a FLWOR expression that uses a built-in function called `fn:contains` that checks for a period in name forms.

```xquery
let $names := ("G. G. Ashwood", "Patricia Conley", "S. Dole Melipone", "Ella Runciter")
for $name in $names
return fn:contains($name, ".")
```

The expression returns a sequence of boolean values: `true, false, true, false`. That's good information, but we want to check whether any or all items in the list satisfy our condition. We can use quantified expressions in XQuery to ask those questions. If you have studied predicate logic, you'll already be familiar with [existential quantification](https://en.wikipedia.org/wiki/Existential_quantification) using the symbols `∃` for some and `∀` for all.) Here are examples of `some` and `every` expressions.

* *some*

```xquery
some $num in (1,2,3) satisfies $num mod 2 = 0
```  

* *every*

```xquery
every $num in (1,2,3) satisfies $num mod 2 = 0
```

Now, can you apply them to solve the questions above? Give it a shot by writing a query that asks whether there are any initials in the list of names and another that checks whether none of the names have initials. When you're ready, check your answers [against my versions](https://gist.github.com/CliffordAnderson/86c9a0ec058749257a3bd6aff2897700).

### Comparisons

XQuery offers three different ways of making comparisons. At first glance, you might wonder why the language designers included different options. Couldn't they have simply picked one set of comparison operators and stuck with them? In practice, experienced XQuery programmers frequently use them, at least the first two, interchangeably. As beginning XQuery programmers, it behooves you to understand the differences, since mixing them up can introduce subtle bugs.

* Value Comparisons (`eq`, `ne`, `lt`, `le`, `gt`, and `ge`)
* General Comparisons (`=`, `!=`, `<`, `<=`, `>`, and `>=`)
* Node Comparisons (`is`, `<<`, `>>`)

#### Value Comparisons

Value comparisons check whether two values are equal.

```xquery
1 eq 3 - 2
```

#### General Comparisons

General comparisons check whether the value of the left is equal to *any* value on the right. In other words, a general comparison performs an implicit existential quantification.

```xquery
1 = (1, 2)
```

You could rewrite this expression with the `some` operator as `some $num in (1, 2) satisfies $num = 1`. As you can see, you can rewrite a value comparison using general comparison. Let's try it on the example above: `1 = 3 - 2`. But the math can appear to go haywire if you're not careful, since `1 = (3 - 2, 2 - 3)` is also true.

A deeper difference between value and general comparisons is that the first are transitive and the second are not. As Katz and Chamberlain point out in [XQuery from the Experts](https://books.google.com/books?id=VEWRh5_On38C&pg=PA105#v=onepage&q&f=false), when you write general comparisons, you may find yourself facing non-transitive equations.

```xquery
xquery version "3.1";

let $first := 1
let $second := (1, 2, 3)
let $third := 3
return ($first = $second, $second = $third, $first = $third)
```

If your analysis depends on the transitivity property, make sure that you stay with value comparisons rather than general comparisons.

#### Node Comparisons

There is also a comparison that checks node identity, `is`. In the example below, we list three coffee shops in Nashville. Two of the `shop` elements are apparently identical. But your XQuery intepreter keeps track of their distinct identities so you can ask whether they're actually the same.

```xquery
xquery version "3.1";

let $coffee-shops :=
  <coffee-shops>
   <shop>Barista Parlor</shop>
   <shop>Revelator</shop>  
   <shop>Barista Parlor</shop>          
  </coffee-shops>
let $first-shop := $coffee-shops/shop[1]
let $second-shop := $coffee-shops/shop[3]
return $first-shop is $second-shop
```

Try using `<<` and `>>` to check whether `$first-shop` comes before or after the `$second-shop`.

For practice, can you fill in the correct comparison operators in the two examples below (replacing `FIX ME!` with your answer)?

```xquery
let $ids :=
  <identifiers>
    <isbn num="13">978-0133507645</isbn>
    <isbn num="10">0133507645</isbn>
    <isbn num="13">978-0133507645</isbn>
  </identifiers>
where $ids/isbn/@num FIX ME! "13"
return $ids
```

```xquery
let $ids :=
  <identifiers>
    <isbn num="13">978-0133507645</isbn>
    <isbn num="10">0133507645</isbn>
    <isbn num="13">978-0133507645</isbn>
  </identifiers>
where some $id in ($ids/isbn/@num) satisfies FIX ME!
return $ids
```

### Conditional Expressions

Like other programming languages, XQuery permits conditions expressions of the form `if...then...else`. However, unlike other programming languages, the `else` case is always required. This is because an expression must always evaluate to a value. We'll be using `if...then...else` in some examples below. To make sure you understand how to use them, let's quickly code the famous (at least in programmers' circles) [fizzbuzz](http://c2.com/cgi/wiki?FizzBuzzTest) exercise in XQuery.

```xquery
xquery version "3.1";

(: Fizz Buzz in XQuery :)

for $i in (1 to 100)
return
  if ($i mod 3 = 0 and $i mod 5 = 0) then "fizzbuzz"
  else if ($i mod 3 = 0) then "fizz"
  else if ($i mod 5 = 0) then "buzz"
  else $i
```

You can also use a `switch` expression to handle complicated branching logic.

```xquery
xquery version "3.1";

for $day in (1 to 7)
return switch ($day)
  case 1 return "Monday"
  case 2 return "Tuesday"
  case 3 return "Wednesday"
  case 4 return "Thursday"
  case 5 return "Friday"
  case 6 return "Saturday"
  case 7 return "Sunday"
  default return "What day again?"
```

There is also an expression called `typeswitch` that let's you branch on types rather than values. Here's an example:

```xquery
xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $doc :=
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader type="text">
            <fileDesc>
                <titleStmt>
                    <title>Testing XPath</title>
                    <author>Clifford Anderson</author>
                </titleStmt>
                <publicationStmt>
                    <idno>Test Document #1</idno>
                    <publisher>Paralipomena</publisher>
                    <pubPlace>Nashville, TN</pubPlace>
                    <date when="2014"/>
                </publicationStmt>
                <!--comment-->
                <sourceDesc>
                    <p xml:lang="eng">Born digitally as a classroom exercise</p>
                </sourceDesc>
            </fileDesc>   
        </teiHeader>
        <text>
            <front>
                <note type="abstract">This is a sample XPath Document</note>
            </front>
            <body>
                <p n="1">Who wants to learn XPath?</p>
                <p n="2" xml:lang="eng">Let's get started with XPath</p>
                <p>No time to waste!</p>
            </body>
        </text>
    </TEI>
for $node in $doc//node()    
return
    typeswitch($node)
        case comment() return "A comment: " || fn:string($node)
        case element(tei:p) return "A paragraph element: " || $node/data()
        default return ()
```

Can you expand this `typeswitch` example to return the text values of the author and title elements?

### Built-in Functions

Functions represent the heart of functional programming, but they can appear a little intimidating at first. The basic idea of a function is to break up complicated code into nice, simple, smaller units. A function also allows us to control better the information we receive and the outputs we provide.

The great thing about XQuery is that many functions already come built into the language. You can check out the [official list](https://www.w3.org/TR/xpath-functions-31/), but you will probably find Priscilla Walmsley's synopsis more helpful [list of XQuery functions](http://www.xqueryfunctions.com/). The built-in functions all come prefixed with the `fn` namespace.

Want to try a few together? Let's experiment with the functions that apply to sequences. Here's the set of [General functions and operators on sequences] (minus one function) from the XQuery 3.1 Recommendation.

| Function         | Meaning                                      |
| ---------------- | --------------                               |
| fn:empty         | Returns true if the argument is the empty sequence. |
| fn:exists        | Returns true if the argument is a non-empty sequence. |
| fn:head          | Returns the first item in a sequence. |
| fn:tail          | Returns all but the first item in a sequence. |
| fn:insert-before | Returns a sequence constructed by inserting an item or a sequence of items at a given position within an existing sequence. |
| fn:remove        | Returns a new sequence containing all the items of `$target` except the item at position `$position`. |
| fn:reverse       | Reverses the order of items in a sequence.
| fn:subsequence   | Returns the contiguous sequence of items in the value of `$sourceSeq` beginning at the position indicated by the value of `$startingLoc` and continuing for the number of items indicated by the value of `$length`. |

Let's apply each of these functions to the sequence: `("Kraków", "Montreal", "Mexico City", "Utrecht")`. As you experiment with each of these functions, note that they take different numbers of arguments. Some take one, two, and three arguments.

As we noted at the beginning of this introduction, you can also chain functions together. You can write these chains in many ways, but we'll focus on two here.

The first is to put one function inside another. To reverse our sequence and then take the first item (i.e., the item had been the last), you could write this function within a function.

```xquery
fn:head(fn:reverse(("Kraków", "Montreal", "Mexico City", "Utrecht")))
```

Another possibility would be to pipe the result from the first function to the next function using the *arrow operator* `=>`:

```xquery
fn:reverse(("Kraków", "Montreal", "Mexico City", "Utrecht")) => fn:head()
```

This format is easier to read as you add more and more functions to an operation. Remember that the first argument to the function on the right side of the arrow operator is implied; you don't state it directly because it's being "piped" or "forwarded" from the previous expression.

You can also combine expressions using the simple mapping operator (`!`), which acts like a `for` in an FLWOR expression. The simple mapping operator applies the function on the right side of the operator to each item on the left hand sequence. Let's use it to create upper-case equivalents of all the items in our sequence.

```xquery
("Kraków", "Montreal", "Mexico City", "Utrecht") ! fn:upper-case(.)
```

Note that we have to use the `.` operator to indicate where we want to substitute the items in the left-handed sequence. This actually allows greater flexibility in our expressions. For instance, can you create a version of the expression above that concatenates the phrase `DH met in  ` with the place name? If you can do that, can you also create a version that indicates the correct year of the meeting (without using a FLWOR expression)? My [version](https://gist.github.com/CliffordAnderson/484b42eff8b4c7b8644edecaf22e6da2) could probably be improved.

### User-defined Functions

Of course, it's also possible to write your own functions in XQuery. In fact, it's generally *necessary* to write new functions. You can do so in two ways. On the one hand, you can declare functions in the XQuery prologue. Or you can write anonymous functions. Let's take a look at both examples.

Here's a user-defined function to write a friendly hello to someone. Our function will accept a string representing someone's name as an argument and return a greeting in response.

```xquery
xquery version "3.1";

declare function local:say-hello($name as xs:string) as xs:string
{
  "Hello, " || $name || "!"
};

local:say-hello("Dave")
```

Another way of writing this function is to use a FLWOR expression. In this case, we'll write an anonymous function, meaning we cannot access it by name, and bind it to a variable with a `let` clause. We'll then use the `return` clause to call and evaluate the function.

```xquery
xquery version "3.1";

let $say-hello := function($name as xs:string) as xs:string { "Hello, " || $name || "!" }
return $say-hello("Dave")
```

Let's write a function to help fulfill restaurant orders. Our function will take a food choice along with a yes/no (true/false) decision about whether to add a salad as inputs and then return a combined food choice as a result. Below is a first pass at writing that function.

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
local:add-salad("Steak", false())
```
Et voilá! You have written a function to add (or not) salads to every food order. Still, there is a problem. What if someone sends a malformed order? For example, what if patron just asked for 1 with a salad. What would happen? We'd get back the result `1 and salad`. Even stranger, what happens when someone orders "Fish" and says "No" to salad. We'd an error saying `Items of type xs:string and xs:boolean cannot be compared.` What does that mean? Isn't there a way to check for these errors before they happen?

In fact, there is. In the fancy language of computer science, this is called *type checking*. Basically, we want to define what type of information can go into our function and also what type of information can be returned as values by our function. In XQuery, we can check the types in the so-called function signature.

Here's how we do that.

```xquery
xquery version "3.1";

declare function local:add-salad($food as xs:string, $salad as xs:boolean) as xs:string
{
  if ($salad = true()) then $food || " and salad"
  else $food
};

local:add-salad("Fish", true())
```

By adding the clause `as xs:string` and `as xs:boolean` you limit the range of acceptable values to strings and booleans respectively. The `as xs:string` after the paragraph indicates that the return value will always be a string. While it's not strictly necessary to add types to your inputs and to your return values, it's a good habit to get into. You'll find that if you cannot determine what type of information your function can accept and what type of information your function will return, you probably don't fully understand what your function is doing.

Whether you declare named functions in your prologue or assign anonymous functions to variables in your expression body depends on the purpose you intend to achieve.

### Recursive Functions

Recursion forms the gateway to more advanced XQuery. We will explore a basic example of a recursive function here. The basic idea behind recursion is dividing a big task into a set of smaller tasks. To make recursion work, you need to have at least one recursive case (i.e., a case of a big task that you can split into smaller tasks) as well as at least one base case (i.e., a case that represents an indivisible task). Let's test out these concepts by computing the [fibonacci sequence](https://en.wikipedia.org/wiki/Fibonacci_number) in XQuery.

```xquery
xquery version "3.1";

declare function local:fib($num as xs:integer) as xs:integer
{
  switch($num)
  case 0 return 0
  case 1 return 1
  default return local:fib($num - 1) + local:fib($num - 2)
};

local:fib(30)
```

Can you create a version of this function that outputs all the numbers in the fibonacci sequence up to and including the nth fibnonacci number that you pass into the function? See my answers in this [gist](https://gist.github.com/CliffordAnderson/7997843).

### Problem Sets

#### Pig Latin in XQuery

My son Theodore loves to speak Pig Latin. He can speak it fast, making it difficult for my wife and I to follow him. Wouldn't it be helpful to have a Pig Latin interpreter, I thought? Let's write a basic parser for Pig Latin in XQuery this month.

The rules for [Pig Latin](https://en.wikipedia.org/wiki/Pig_Latin) are simple though different dialects exist, as we will see. Let's take the simplest dialect first. Basically, to turn any English word into its translation in Pig Latin you take the first consonant off the front of the word, add it to the end, and then add "ay." If your word already starts with a vowel, then add "ay" to the end. Thus, "Hello" becomes "Ellohay." "I" becomes "Iay."

*Exercise #1*

For our first exercise, let's write a basic XQuery expression that takes a word and returns its equivalent this dialect of Pig Latin.

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
xquery version "3.1";

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

There are always lots of different ways to accomplish a task in XQuery, though some may have subtle bugs and others may be less straightforward. [Here are other attempts at a Pig Latin parser in XQuery](https://gist.github.com/CliffordAnderson/a1ac3141828b504ee756). If we have time, we might look at these. Otherwise, please try them out yourself and see if you can spot any bugs.
