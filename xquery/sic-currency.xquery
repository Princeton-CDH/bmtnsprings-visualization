xquery version "3.0";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace ns2="http://viaf.org/viaf/terms#";
declare namespace local="http://bluemountain.princeton.edu/springs";

declare variable $collection := '/db/bluemtn/metadata/periodicals/bmtnaaz';

for $issue in collection($collection)//mods:mods[mods:genre='Periodicals-Issue']
let $pagecount := count($issue/ancestor::mets:mets/mets:fileSec/mets:fileGrp[@ID='IMGGRP']/mets:file)
let $keydate  := $issue/mods:originInfo/mods:dateIssued[@keyDate = 'yes']
let $label := $issue/mods:part[@type = 'issue']/mods:detail[@type = 'number']/mods:caption

return string-join(($label,$keydate,$pagecount), ',')