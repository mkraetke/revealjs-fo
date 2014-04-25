<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="xs" 
  version="2.0">
  
  <xsl:param name="slide-border-width" select="'0.2mm'" as="xs:string"/>
  <xsl:param name="slide-width" select="'132mm'" as="xs:string"/>
  <xsl:param name="slide-height" select="'90mm'" as="xs:string"/>
  <xsl:param name="slide-padding" select="'2mm'" as="xs:string"/>
  <xsl:param name="slide-top" select="'100mm'" as="xs:string"/>
  <xsl:param name="slide-left" select="'140mm'" as="xs:string"/>
  <xsl:param name="base-font-size" select="10" as="xs:decimal"/>
  <xsl:param name="base-line-height" select="$base-font-size * 1.3" as="xs:decimal"/>
  <xsl:param name="base-dir" select="replace(base-uri(), '^(.+)/.+$', '$1')"/>

  <xsl:template match="/">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
      <fo:layout-master-set>
        <fo:simple-page-master master-name="page" margin="1cm" page-height="210mm" page-width="297mm">
          <fo:region-body region-name="body"/>
        </fo:simple-page-master>
      </fo:layout-master-set>
      <fo:page-sequence master-reference="page">
        <xsl:apply-templates select="html/body/div[@class eq 'reveal']/div[@class eq 'slides']"/>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>

  <xsl:template match="div[@class eq 'slides']">
    <fo:flow flow-name="body">
      <xsl:for-each select="//section[not(child::section)]">
        <xsl:variable name="pos" select="position() mod 4" as="xs:integer"/>
        <xsl:variable name="top" select="if($pos = (3,0)) then $slide-top else '0'" as="xs:string"/>
        <xsl:variable name="left" select="if($pos = (2,0)) then $slide-left else '0'" as="xs:string"/>
        <fo:block-container position="absolute" top="{$top}" left="{$left}" width="{$slide-width}" height="{$slide-height}" border-style="solid"
          border-width="{$slide-border-width}">
          <fo:block-container margin="{$slide-padding, $slide-padding, $slide-padding, $slide-padding}">
            <!-- page counter -->
            <fo:block text-align="right" font-size="{concat($base-font-size * 0.8, 'pt')}">
              <xsl:value-of select="position(), '/', count(//section[not(child::section)])"/>
            </fo:block>
            <xsl:apply-templates/>
          </fo:block-container>
        </fo:block-container>
        <!-- page break after four slides -->
        <xsl:if test="$pos eq 0">
          <fo:block page-break-after="always"/>
        </xsl:if>
      </xsl:for-each>
    </fo:flow>
  </xsl:template>
  
  <!-- headlines -->
  
  <xsl:template match="*[local-name() = ('h1','h2','h3','h4','h5','h6')]">
    <xsl:variable name="headline-font-size" select="concat(5 div xs:integer(substring-after(local-name(), 'h')) * $base-font-size, 'pt')" as="xs:string"/>
    <fo:block font-family="Helvetica, sans-serif" font-weight="bold" space-after="{$headline-font-size}">
      <xsl:attribute name="font-size" select="$headline-font-size"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>
  
  <!-- simple paragraphs -->
  
  <xsl:template match="p">
    <fo:block space-after="{concat($base-line-height, 'pt')}">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>
  
  <!-- lists -->
  
  <xsl:template match="ul|ol">
    <fo:list-block
      provisional-distance-between-starts="{concat($base-line-height, 'pt')}"
      provisional-label-separation="6pt">
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>
  
  <xsl:template match="li">
    <xsl:variable name="list-level" select="count(ancestor::*[local-name() = ('ol', 'ul')])" as="xs:integer"/>
    <fo:list-item space-after="{concat($base-line-height * 0.25, 'pt')}">
      <fo:list-item-label end-indent="label-end()">
        <fo:block>
          <xsl:choose>
            <xsl:when test="../ul">
              <xsl:value-of select="if($list-level eq 3) then '&#x2043;'
                else if($list-level eq 2) then '&#x25e6;'
                else '&#x2022;'"/>
            </xsl:when>
            <xsl:when test="../ol">
              <xsl:number format="{if($list-level eq 3) then 'i'
                else if($list-level eq 2) then 'a'
                else '1'}"/>
            </xsl:when>
          </xsl:choose>
        </fo:block>
        <fo:block>&#x2022;</fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <fo:block><xsl:apply-templates/></fo:block>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>
  
  <!-- images -->

  <xsl:template match="img">
    <fo:block>
      <fo:external-graphic src="{concat($base-dir, '/', @src)}" content-type="{replace(@src, '^.+\.([a-z]+)$', '$1')}" 
        content-height="auto" content-width="{concat(xs:decimal(replace($slide-width, '[a-z]+', '')) - 4 * xs:decimal(replace($slide-padding, '[a-z]+', '')), replace($slide-width, '[0-9]+', ''))}" scaling="uniform"/>  
    </fo:block>
  </xsl:template>
  
  <!-- code listings -->
  
  <xsl:template match="pre">
    <fo:block line-height="{concat($base-line-height, 'pt')}" margin-bottom="{$base-line-height}">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="code">
    <fo:block font-family="Courier, monospace" font-size="{concat($base-font-size * 0.9, 'pt')}">
      <xsl:analyze-string select="." regex="(.+?)\n">
        <xsl:matching-substring>
          <fo:block >
            <xsl:value-of select="."/>
          </fo:block>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <fo:block font-family="Courier, monospace">
            <xsl:value-of select="."/>
          </fo:block>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </fo:block>
  </xsl:template>
  
  <!-- line break, dirty uuuh -->
  
  <xsl:template match="br">
    <fo:block line-height="0"></fo:block>
  </xsl:template>

</xsl:stylesheet>