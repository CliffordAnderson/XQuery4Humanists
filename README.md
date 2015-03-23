# XQuery4Humanists

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

Please feel free to improve on these examples and to share your work with everyone else. The easiest way to do that is to write your expression in [Zorba](try-zorba.28.io) and then tweet out the permalink to [#prog4humanists](https://twitter.com/hashtag/prog4humanists). I look forward to seeing how you improve on my work! :)
