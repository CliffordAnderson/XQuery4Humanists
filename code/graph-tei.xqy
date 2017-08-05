xquery version "3.1";

(: Converts TEI texts in the Folger Shakespeare Edition into graphml :)

declare namespace graphml = "http://graphml.graphdrawing.org/xmlns";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace functx = 'http://www.functx.com';

declare function local:title-node($doc as document-node()?) as element(graphml:node)*
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

let $doc := fn:doc("https://raw.githubusercontent.com/XQueryInstitute/Course-Materials/master/folger%20shakespeare%20texts/JC.xml")
let $play := local:title-node($doc)
let $acts-scenes := local:act-scene-nodes($doc)
let $play-to-acts := local:play-to-acts($play, $acts-scenes)
let $acts-to-scenes := local:acts-to-scenes($acts-scenes)
let $persons := local:person-nodes($doc)
let $persons-to-scenes := local:persons-to-scenes($persons, $acts-scenes, $doc)
return local:make-graphml(($play, $persons, $acts-scenes, $play-to-acts, $acts-to-scenes, $persons-to-scenes))
