<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:css="http://www.w3.org/1996/css" version="1.0">

  <p:input port="source"/>
  <p:output port="result">
    <p:pipe port="result" step="xslt"/>
  </p:output>

  <p:option name="href" required="true"/>

  <p:xslt name="xslt">
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/revealjs-fo.xsl"/>
    </p:input>
  </p:xslt>

  <p:xsl-formatter name="xsl-formatter">
    <p:with-option name="href" select="$href"/>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xsl-formatter>

</p:declare-step>
