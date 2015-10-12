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
	</xd:doc>
	
	<xsl:variable name="fields">
		<field>title</field>
		<field>creators</field>
		<field>bylines</field>
		<field>authnames</field>
		<field>genre</field>
		<field>magazine</field>
		<field>pubdate</field>
	</xsl:variable>
	
	<xsl:function name="local:authorized-name">
		<xsl:param name="viafid" />
		<xsl:variable name="url">
			<xsl:value-of select="concat($viafid, '.xml')" />
		</xsl:variable>
		<xsl:value-of select="concat('&quot;', document($url)//ns2:mainHeadings/ns2:data[1]/ns2:text, '&quot;')" />
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
		<xsl:apply-templates select="//mods:relatedItem[@type='constituent']" />
	</xsl:template>
	
	<xsl:template match="mods:relatedItem[@type='constituent']">
		<!-- title -->
		<xsl:value-of select="mods:titleInfo[1]/mods:title[1]" /> <!-- first title -->
		<xsl:text>&#9;</xsl:text> <!-- tab -->
		
		<!-- the creators; there may be more than one, so separate with commas -->
		<xsl:for-each select="mods:name">
			<xsl:value-of select="@valueURI" />
			<xsl:if test="position() != last()">
				<xsl:text>,&#xA0;</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>&#9;</xsl:text> <!-- tab -->
		
		<!-- bylines -->
		<xsl:for-each select="mods:name">
			<xsl:value-of select="mods:displayForm" />
			<xsl:if test="position() != last()">
				<xsl:text>,&#xA0;</xsl:text>
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
		
		
		<xsl:value-of select="mods:genre[@type='CCS']" />
		<xsl:text>&#9;</xsl:text> 
		
		<xsl:value-of select="ancestor::mods:mods/mods:relatedItem[@type='host']/@xlink:href" />
		<xsl:text>&#9;</xsl:text>
		
		<xsl:value-of select="ancestor::mods:mods/mods:originInfo/mods:dateIssued[@keyDate='yes']" />
		
		
		<xsl:text>&#10;</xsl:text> <!-- CR ends the row -->
	</xsl:template>
	
	
</xsl:stylesheet>