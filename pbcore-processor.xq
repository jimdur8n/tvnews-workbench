(:PBCore Processor
Authors: Jim Duran, Nathan Jones and Sarah Swanz.
Thanks also to Cliff Anderson.

This xquery script transforms tvnews data from myPHPAdmin export xml to PBCore.
It is designed to run in BaseX after creating a database using the raw tvnews data.
:)
xquery version "3.1";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method   "xml";
declare option output:encoding "iso-8859-1";
declare option output:indent   "yes";

declare function local:seriesTitle($Network as xs:string?) as xs:string 
  {
  switch ($Network)
    case "ABC" return "ABC World News Tonight"
    case "CBS" return "CBS Evening News"
    case "NBC" return "NBC Nightly News"
    case "CNN" return "CNN News program"
    case "FNC" return "Fox News Channel program"
    default    return "News Program"
 };

<pbcoreCollection>
{
  let $doc := fn:collection("tvn2015-05-01-08") (:Change this to whatever collection you are using:)
  let $rows := $doc/pma_xml_export/database/table
    for $row in $rows
    let $RecordNumber := $row/column[@name='RecordNumber']/text()
    let $startTime := $row/column[@name='BeginTime']/text()	
    let $endTime := $row/column[@name='EndTime']/text()
    let $title := $row/column[@name='Title']/text()
    let $description := $row/column[@name='Abstract']/text()
    let $RecordHeader := $row/column[@name='RecordHeader']/text()
    let $Network := $row/column[@name='Network']/text()
    let $BroadcastDate := $row/column[@name='Date']/text()
  return (
    if ($RecordHeader = '1') then       
          <pbcoreDescriptionDocument xmlns="http://www.pbcore.org/PBCore/PBCoreNamespace.html"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.pbcore.org/PBCore/PBCoreNamespace.html 
  https://raw.githubusercontent.com/WGBH/PBCore_2.1/master/pbcore-2.1.xsd">
            <pbcoreAssetDate>{$BroadcastDate}</pbcoreAssetDate>
            <pbcoreIdentifier source="local">{$RecordNumber}</pbcoreIdentifier>
            <pbcoreTitle titleType="Series">            
            {let $seriesTitle := local:seriesTitle($Network)
            return $seriesTitle}
            </pbcoreTitle>
            <pbcoreDescription/>
            <pbcoreCreator> 
            <creator>{$Network}</creator>
            <creatorRole>{'Producer'}</creatorRole> 
            </pbcoreCreator>
            </pbcoreDescriptionDocument>
    else (),
    <pbcorePart startTime="{$startTime}" endTime="{$endTime}">
      <pbcoreIdentifier source="local">{$RecordNumber}</pbcoreIdentifier>
      <pbcoreTitle>{$title}</pbcoreTitle>
      <pbcoreDescription>{$description}</pbcoreDescription>
    </pbcorePart>
    )
 }
</pbcoreCollection>