xquery version "3.0";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace ns2="http://viaf.org/viaf/terms#";
declare namespace local="http://bluemountain.princeton.edu/springs";

declare variable $collection := '/db/bluemtn/metadata/periodicals/bmtnaaz';

declare function local:w3cdtf-to-xsdate($d as xs:string) as xs:date
{
  let $dstring :=
  if ($d castable as xs:gYear) then $d || "-01-01"
  else if ($d castable as xs:gYearMonth) then $d || "-01"
  else if ($d castable as xs:date) then $d
  else error($d, "not valid w3cdtf")
  return xs:date($dstring)
};

 
declare function local:constituent-pagecount($constituent as element())
as xs:integer
{
	let $metsdiv := $constituent/ancestor::mets:mets//mets:div[@DMDID = $constituent/@ID]
	let $altoids := $metsdiv//mets:area/@FILEID
	return count(distinct-values($altoids))
};

for $constituent in collection($collection)//mods:relatedItem[@type='constituent']
let $type := $constituent/mods:genre[@type = 'CCS']
let $raw-date := $constituent/ancestor::mods:mods[1]/mods:originInfo[1]/mods:dateIssued[@keyDate='yes'][1]
let $date :=
	if ($raw-date)
	 then local:w3cdtf-to-xsdate($raw-date)
	 else ""
let $pagecount := local:constituent-pagecount($constituent)
where $pagecount > 0
order by $date

return string-join(($pagecount,$type,$date), ',')