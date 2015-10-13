xquery version "3.0";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace ns2="http://viaf.org/viaf/terms#";
declare namespace local="http://bluemountain.princeton.edu/springs";

declare variable $collection := '/db/bluemtn/metadata/periodicals/bmtnaaz';

(:
	Generate a table of triples: name of author, type of contribution, number of contributions.
 :)
 
 declare function local:authorized()
 {
 let $constituents := collection($collection)//mods:relatedItem[@type = 'constituent']
 for $genre in distinct-values($constituents/mods:genre[@type = 'CCS'])
 let $genre-constituents := $constituents[mods:genre[@type = 'CCS'] = $genre]
 let $authorized-creators := $genre-constituents/mods:name[mods:role/mods:roleTerm = 'cre' and not(empty(@valueURI))]
	for $name in distinct-values($authorized-creators/@valueURI)
	let $count := count($authorized-creators[@valueURI = $name])
	return
		<item name="{ $name }" genre="{ $genre }" count="{ $count }" />
 };

declare function local:unauthorized()
{
	let $constituents := collection($collection)//mods:relatedItem[@type = 'constituent']
	for $genre in distinct-values($constituents/mods:genre[@type = 'CCS'])
	let $genre-constituents := $constituents[mods:genre[@type = 'CCS'] = $genre]
	let $count := count($genre-constituents[mods:name[mods:role/mods:roleTerm = 'cre'] and empty(@valueURI)])
	
	return
		<item name="unauthorized" genre="{ $genre }" count = "{ $count }" />
};

declare function local:anonymous()
{
	let $constituents := collection($collection)//mods:relatedItem[@type = 'constituent']
	for $genre in distinct-values($constituents/mods:genre[@type = 'CCS'])
	let $genre-constituents := $constituents[mods:genre[@type = 'CCS'] = $genre]
	let $count := count($genre-constituents[count(mods:name[mods:role/mods:roleTerm = 'cre']) = 0])
		
	return
		<item name="anonymous" genre="{ $genre }" count = "{ $count }" />
};

for $item in (local:authorized() union local:unauthorized() union local:anonymous())
return
string-join(($item/@name, $item/@genre, $item/@count), '&#09;')