xquery version "3.0";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace ns2="http://viaf.org/viaf/terms#";
declare namespace local="http://bluemountain.princeton.edu/springs";

declare variable $collection := '/db/bluemtn/metadata/periodicals/bmtnaaz';

(:
	Generate a table of triples: date, genre, count.
 :)
 
 
(:~
 : Returns a valid xs:date from a w3cdtf-formatted string.
 : The input string may simply be a year (e.g., '2015'), in which
 : case the function appends January 1 to it (e.g., 2015-01-01);
 : if it is a YearMonth, then the function returns default first of 
 : the month.
 :
 : The function works by seeing if it can cast the input string as
 : an xs:date type.
 : @param $d a string in w3cdtf format
 :)
declare function local:w3cdtf-to-xsdate($d as xs:string) as xs:date
{
  let $dstring :=
  if ($d castable as xs:gYear) then $d || "-01-01"
  else if ($d castable as xs:gYearMonth) then $d || "-01"
  else if ($d castable as xs:date) then $d
  else error($d, "not valid w3cdtf")
  return xs:date($dstring)
};

let $issues := collection($collection)//mods:mods[mods:genre = 'Periodicals-Issue']
let $header := string-join(('date', 'textcount', 'illustrationcount', 'addcount', 'musiccount'), ',')
let $rows   := 
	for $issue in collection($collection)//mods:mods[mods:genre = 'Periodicals-Issue']
  	let $date := local:w3cdtf-to-xsdate($issue/mods:originInfo/mods:dateIssued[@keyDate='yes'])
  	let $textcount   := count($issue/mods:relatedItem[@type='constituent']/mods:genre[@type = 'CCS' and . = 'TextContent'])
  	let $illustcount := count($issue/mods:relatedItem[@type='constituent']/mods:genre[@type = 'CCS' and .= 'Illustration'])
  	let $adcount     := count($issue/mods:relatedItem[@type='constituent']/mods:genre[@type = 'CCS' and .= 'SponsoredAdvertisement'])
  	let $musiccount  := count($issue/mods:relatedItem[@type='constituent']/mods:genre[@type = 'CCS' and .= 'Music'])
	  return string-join(($date,$textcount,$illustcount,$adcount,$musiccount), ',')

return ($header,$rows)