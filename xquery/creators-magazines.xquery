xquery version "3.0";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace ns2="http://viaf.org/viaf/terms#";

(:
	A weighted graph showing authors and the magazines they contributed to.
	For every authorized creator, for every magazine to which s/he contributed,
	return label, author, mag, contrib-count
 :)
 
 declare variable $collection := '/db/bluemtn/metadata/periodicals';


 let $creators := collection($collection)//mods:name[
 			./mods:role/mods:roleTerm = 'cre' and
 			@authority='viaf' and
 			not(empty(@valueURI))
		]/@valueURI
 
 for $creator in distinct-values($creators)
 let $viafurl := $creator || '.xml'
 let $label := $viafurl
 let $magazines := collection($collection)//mods:mods[.//mods:name[@valueURI = $creator]]/mods:relatedItem[@type='host']/@xlink:href
 for $magazine in distinct-values($magazines)
 return 
 string-join(($label, $creator, $magazine, count($magazines[.= $magazine])), ',')
 	