<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:mets="http://loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:local="http://bluemountain.princeton.edu"
	xmlns:ns2="http://viaf.org/viaf/terms#"
	exclude-result-prefixes="xs math xd mets xlink mods"
	version="3.0">
	
	<xsl:output encoding="UTF-8" method="text"/>
	
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 8, 2015</xd:p>
			<xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
			<xd:p></xd:p>
		</xd:desc>
		<xd:param name="pathtomets">
			<xd:p>A URI to the root of the metadata tree. Usually a local file path.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p>A stream of tab-separated values.</xd:p>
		</xd:return>
	</xd:doc>
	
	<xsl:param name="pathtomets"/>
	
	<xd:doc scope="component">
		<xd:desc>
			<xd:p>The contents of the header row: the fields of the table</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:variable name="fields">
		<field>title</field>
		<field>creators</field>
		<field>bylines</field>
		<field>authnames</field>
		<field>genre</field>
		<field>magazine</field>
		<field>issue</field>
		<field>pubdate</field>
	</xsl:variable>

	<xd:doc>
		<xd:desc>
			<xd:p>Given a viaf url, returns the authorized name</xd:p>
		</xd:desc>
		<xd:param name="viafurl">
			<xd:p>URL of a viaf resource</xd:p>
		</xd:param>
	</xd:doc>
	<xsl:function name="local:authorized-name">
		<xsl:param name="viafurl" />
		<xsl:variable name="url">
			<xsl:value-of select="concat($viafurl, '.xml')" />
		</xsl:variable>
		<xsl:value-of select="concat('&quot;', document($url)//ns2:mainHeadings/ns2:data[1]/ns2:text, '&quot;')" />
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Converts w3cdtf-formatted date string to xsdate-formatted date string</xd:p>
		</xd:desc>
		<xd:param name="instring">
			<xd:p>A string of the form YYYY, YYYY-MM, or YYYY-MM-DD</xd:p>
		</xd:param>
		<xd:return>An xs:date</xd:return>
	</xd:doc>
	<xsl:function name="local:w3cdtf-to-xsdate">
		<xsl:param name="instring" />
		<xsl:variable name="datestring">
			<xsl:choose>
				<xsl:when test="$instring castable as xs:gYear">
					<xsl:value-of select="concat($instring, '-01-01')" />					
				</xsl:when>
				<xsl:when test="$instring castable as xs:gYearMonth">
					<xsl:value-of select="concat($instring, '-01')" />
				</xsl:when>
				<xsl:when test="$instring castable as xs:date">
					<xsl:value-of select="$instring" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">not a valid date</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="xs:date($datestring)" />
	</xsl:function>
	
	<xsl:template match="/">
		<!-- header row -->
		<xsl:for-each select="$fields/field">
			<xsl:value-of select="." />
			<xsl:if test="position() != last()">
				<xsl:text>&#9;</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>&#10;</xsl:text>
		
		<!-- body rows -->
		<xsl:variable name="path">
			<xsl:value-of select="concat($pathtomets, '/?select=*mets.xml;recurse=yes')" />
		</xsl:variable>
		<xsl:apply-templates select="collection($path)//mods:relatedItem[@type='constituent']" />
		
	</xsl:template>
	
	<xsl:template match="mods:relatedItem[@type='constituent']">
		<!-- title -->
		<xsl:value-of select="mods:titleInfo[1]/mods:title[1]" /> <!-- first title -->
		<xsl:text>&#9;</xsl:text> <!-- tab -->
		
		<!-- the creators; there may be more than one, so separate with | -->
		<xsl:for-each select="mods:name">
			<xsl:value-of select="@valueURI" />
			<xsl:if test="position() != last()">
				<xsl:text>|</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>&#9;</xsl:text> <!-- tab -->
		
		<!-- bylines -->
		<xsl:for-each select="mods:name">
			<xsl:value-of select="mods:displayForm" />
			<xsl:if test="position() != last()">
				<xsl:text>|</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>&#9;</xsl:text> <!-- tab -->
		
		<!-- Authorized names -->
		<xsl:for-each select="mods:name">
			<xsl:value-of select="local:authorized-name(@valueURI)" />
			<xsl:if test="position() != last()">
				<xsl:text>|</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>&#9;</xsl:text> <!-- tab -->
		
		<!-- Genre -->
		<xsl:value-of select="mods:genre[@type='CCS']" />
		<xsl:text>&#9;</xsl:text> 
		
		<!-- magazine -->
		<xsl:value-of select="ancestor::mods:mods/mods:relatedItem[@type='host']/@xlink:href" />
		<xsl:text>&#9;</xsl:text>
		
		<!-- issue -->
		<xsl:value-of select="ancestor::mods:mods/mods:identifier[@type = 'bmtn']" />
		<xsl:text>&#9;</xsl:text>
		
		
		<!-- date -->
		<xsl:value-of select="local:w3cdtf-to-xsdate(ancestor::mods:mods/mods:originInfo/mods:dateIssued[@keyDate='yes'])" />
		
		
		<xsl:text>&#10;</xsl:text> <!-- CR ends the row -->
	</xsl:template>
	
	
</xsl:stylesheet>