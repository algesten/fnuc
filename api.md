

any type
--------
clone       `:: {*} -> {*}`  
cloneDeep   `:: {*} -> {*}`  

array
-----
!append      `:: [a], a -> [a]` or `:: a -> [a] -> [a]`  
!appendTo    `:: a, [a] -> [a]` or `:: [a] -> a -> [a]`  
!concat      `:: [a], [a] -> [a]` or `:: [a] -> [a] -> [a]`  
isEmpty     `:: [a] -> Boolean`
!head        `:: [a] -> a`  
!filter      `:: [a], (a,i,[a] -> Boolean) -> [a]`  
            or `:: (a,i,[a] -> Boolean) -> [a] -> [a]`  
!map         `:: [a], (a,i,[a] -> b) -> [b]` or `:: (a,i,[a] -> b) -> [a] -> [b]`  
nth         `:: [a], Number -> a` or `:: Number -> [a] -> a`  
prepend     `:: [a], a -> [a]` or `:: a -> [a] -> [a]`
prependTo   `:: a, [a] -> [a]` or `:: [a] -> a -> [a]`  
!reduce/foldl/fold `:: [b], a, (a,b,i,[b] -> a)` or `:: (a,b,i,[b] -> a) -> a -> [b] -> a`  
!reduceRight/foldr `:: [b], a, (a,b,i,[b] -> a)` or `:: (a,b,i,[b] -> a) -> a -> [b] -> a`  
!tail        `:: [a] -> [a]`  
!find        `:: [a], (a -> Boolean) -> a | undefined`  
            or `:: (a -> Boolean) -> [a] -> a | undefined`  
findIndex   `:: [a], (a -> Boolean) -> Number` or `:: (a -> Boolean) -> [a] -> Number`  
indexOf     `:: [a], a -> Number` or `:: a -> [a] -> Number`
lastIndexOf `:: [a], a -> Number` or `:: a -> [a] -> Number`

fn
--
argN        `:: Number -> *... -> *`  
!compose     `:: ((y -> z), (x -> y), ..., (b -> c), (a... -> b)) -> (a... -> z)`  
            or `:: (a... -> b) -> (b -> c) -> ... -> (x -> y) -> (y -> z) -> (a... -> z)`  
!sequence    `:: ((a... -> b), (b -> c), ..., (x -> y), (y -> z)) -> (a... -> z)`  
            or `:: (y -> z) -> (x -> y) -> ... -> (b -> c) -> (a... -> b) -> (a... -> z)`  
!curry       `:: (* -> a) -> (* -> a)`  
!ncurry      `:: (* -> a), Number -> (* -> a)` or `:: Number -> (* -> a) -> (* -> a)`  
!I/ident     `:: a -> a`  
!flip        `:: (a, b, ..., z) -> (z, ..., b, a)`  
            or `:: (a -> b -> ... -> z) -> (z -> ... -> b -> a)`  
tap         `:: a, (a -> *) -> a` or `:: (a -> *) -> a -> a`  

ap?
arity? vs
nAry, unary, binary
bind?
comparator?
construct/constructN?
converge?
lift?
memoize?
once?
useWith?
call?       `:: (*... -> a), *... -> a`  
apply?      `:: [*], (*... -> a) -> a` or `:: (*... -> a) -> [*] -> a`  
unapply?    `:: ([*...] -> a) -> (*... -> a)`  


object
------

mixin        `:: {*}, {*}... -> {*}` or `:: {*} -> {*} -> {*}`  
merge        `:: {*}, {*}... -> {*}` or `:: {*} -> {*} -> {*}`  

prop/get     `:: {k:v}, k -> v` or `:: k -> {k:v} -> v`  
propOf/getOf `:: k, {k:v} -> v` or `:: {k,v} -> k -> v`  
has          `:: {k:v}, k -> Boolean` or `:: k -> {k:v} -> Boolean`  
hasOf        `:: k, {k:v} -> Boolean` or `:: {k:v} -> k -> Boolean`  
pick         `:: {k:v}, [k] -> {k:v}` or `:: [k] -> {k:v} -> {k:v}`  
pickOf       `:: [k], {k:v} -> {k:v}` or `:: {k:v} -> [k] -> {k:v}`  
keys         `:: {k:v} -> [k]`  
values       `:: {k:v} -> [v]`  

strings
-------
charAt       `:: String, Number -> String` or `:: Number -> String -> String`  
match        `:: RegExp -> String -> [String] | null`  
replace      `:: RegExp|String -> String -> String -> [String] | null`  
split        `:: String, String -> [String]` or `:: String -> String -> String`  
strIndexOf     `:: String, String -> Number` or `:: String -> String -> Number`  
strLastIndexOf `:: String, String -> Number` or `:: String -> String -> Number`  
substring    `:: String, Number, Number -> String` or `:: Number -> Number -> String -> String`  
trim         `:: String -> String`  


type
----

isType       `:: a, String|Object -> Boolean` or `:: String|Object -> a -> Boolean`  
typeOf       `:: a -> String`  
