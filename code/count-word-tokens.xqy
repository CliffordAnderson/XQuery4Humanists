xquery version "3.1";
declare namespace tei="http://www.tei-c.org/ns/1.0";
(:~
: This set of functions produces word frequences for any given sequence of text nodes.
:
: @author   Cliff Anderson
: @version  1.0
:)

(:~
: This function accepts a sequence of text nodes and returns a sequence of normalized string tokens.
: @param  $words the text nodes from a given text
: @return  the sequence of normalized string tokens
:)
declare function local:collect-words ($words as xs:string*) as xs:string*
{
    let $words:= fn:string-join($words, " ")
    let $words:= fn:translate($words, "!?.',-", "")
    let $words:= fn:lower-case($words)
    let $words:= fn:tokenize($words, " ")
    return $words
};

(:~
: This function accepts a sequence of normalized string tokens and returns a squence of word elements in frequency order.
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

let $phrases:= fn:doc("https://raw.githubusercontent.com/CliffordAnderson/XQuery4Humanists/master/data/eldorado.xml")//tei:l/text()
let $words := local:collect-words($phrases)
let $word-elements := local:determine-frequency($words)
return element dictionary {$word-elements}
