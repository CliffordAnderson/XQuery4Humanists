xquery version "3.1";

(: Takes a word in English and converts it to its equivalent in Pig Latin :)

let $word := "air"
let $vowels := ("a","e","i","o","u","y")
let $first-letter := fn:lower-case(fn:substring($word,1,1))
return 
  if ($first-letter = $vowels) then $word || "ay"
  else fn:substring($word,2) || $first-letter || "ay"
