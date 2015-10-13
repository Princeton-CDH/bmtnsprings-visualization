xquery version "3.0";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace ns2="http://viaf.org/viaf/terms#";
declare namespace local="http://bluemountain.princeton.edu/springs";

declare variable $collection := '/db/bluemtn/metadata/periodicals/bmtnaap';

declare function local:constituent-pagecount($constituent as element())
as xs:integer
{
	let $metsdiv := $constituent/ancestor::mets:mets//mets:div[@DMDID = $constituent/@ID]
	let $altoids := $metsdiv//mets:area/@FILEID
	return count(distinct-values($altoids))
};

for $constituent in collection($collection)//mods:relatedItem[@type='constituent']
let $type := $constituent/mods:genre[@type = 'CCS']
let $date := $constituent/ancestor::mods:mods[1]/mods:originInfo[1]/mods:dateIssued[@keyDate='yes'][1]
let $pagecount := local:constituent-pagecount($constituent)
where $pagecount > 0
order by $date

return string-join(($pagecount,$type,$date), ',')