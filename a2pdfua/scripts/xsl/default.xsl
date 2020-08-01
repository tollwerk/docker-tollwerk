<!--
  Generates single FO document from DocBook XML source using DocBook XSL
  stylesheets.

  See xsl-stylesheets/fo/param.xsl for all parameters.

  NOTE: The URL reference to the current DocBook XSL stylesheets is
  rewritten to point to the copy on the local disk drive by the XML catalog
  rewrite directives so it doesn't need to go out to the Internet for the
  stylesheets. This means you don't need to edit the <xsl:import> elements on
  a machine by machine basis.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:exsl="http://exslt.org/common"
                xmlns:t="http://docbook.org/xslt/ns/template"
                xmlns:db="http://docbook.org/ns/docbook"
                exclude-result-prefixes="exsl xlink">
    <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>
    <xsl:import href="common.xsl"/>

    <!-- Disable default header and footer templates -->
    <xsl:template match="*" mode="running.head.mode"/>
    <xsl:template match="*" mode="running.foot.mode"/>

    <xsl:param name="fop1.extensions" select="1"/>
    <xsl:param name="toc.section.depth">3</xsl:param>
    <xsl:param name="variablelist.as.blocks" select="1"/>
    <xsl:param name="paper.type" select="'A4'"/>
    <xsl:param name="hyphenate">false</xsl:param>
    <xsl:param name="alignment">left</xsl:param>
    <xsl:param name="title.font.family" select="'FiraSans'"/>
    <xsl:param name="sans.font.family" select="'FiraSans'"/>
    <xsl:param name="monospace.font.family" select="'FiraMono'"/>
    <xsl:param name="body.font.family" select="'FiraSans'"/>
    <xsl:param name="body.font.size">
        <xsl:value-of select="$body.font.master"/><xsl:text>pt</xsl:text>
    </xsl:param>
    <xsl:param name="line-height">1.5</xsl:param>

    <!-- Page -->
    <xsl:param name="page.margin.top" select="'0'"/>
    <xsl:param name="page.margin.bottom" select="'0'"/>
    <xsl:param name="page.margin.inner" select="'0'"/>
    <xsl:param name="page.margin.outer" select="'0'"/>
    <xsl:param name="page.orientation" select="'portrait'"/>
    <xsl:param name="page.width">
        <xsl:choose>
            <xsl:when test="$page.orientation = 'portrait'">
                <xsl:value-of select="$page.width.portrait"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$page.height.portrait"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <!-- Regions -->
    <xsl:param name="region.before.extent" select="'20mm'"/>
    <xsl:param name="region.after.extent" select="'20mm'"/>
    <xsl:param name="body.margin.bottom" select="'20mm'"/>
    <xsl:param name="body.margin.top" select="'20mm'"/>
    <xsl:param name="body.margin.inner" select="'20mm'"/>
    <xsl:param name="body.margin.outer" select="'20mm'"/>

    <xsl:param name="bridgehead.in.toc" select="0"/>
    <xsl:param name="table.frame.border.thickness" select="'2px'"/>
    <xsl:param name="draft.watermark.image" select="''"/>

    <!-- Line break -->
    <xsl:template match="processing-instruction('asciidoc-br')">
        <fo:block/>
    </xsl:template>

    <!-- Horizontal ruler -->
    <xsl:template match="processing-instruction('asciidoc-hr')">
        <fo:block space-after="1em">
            <fo:leader leader-pattern="rule" rule-thickness="0.5pt" rule-style="solid" leader-length.minimum="100%"/>
        </fo:block>
    </xsl:template>

    <!-- Hard page break -->
    <xsl:template match="processing-instruction('asciidoc-pagebreak')">
        <fo:block break-after='page'/>
    </xsl:template>

    <!-- Sets title to body text indent -->
    <xsl:param name="body.start.indent">
        <xsl:choose>
            <xsl:when test="$fop.extensions != 0">0pt</xsl:when>
            <xsl:when test="$passivetex.extensions != 0">0pt</xsl:when>
            <xsl:otherwise>1pc</xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="title.margin.left">
        <xsl:choose>
            <xsl:when test="$fop.extensions != 0">-1pc</xsl:when>
            <xsl:when test="$passivetex.extensions != 0">0pt</xsl:when>
            <xsl:otherwise>0pt</xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <xsl:attribute-set name="monospace.properties">
        <xsl:attribute name="font-size">10.5pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="admonition.title.properties">
        <xsl:attribute name="font-size">14pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="hyphenate">false</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="sidebar.properties" use-attribute-sets="formal.object.properties">
        <xsl:attribute name="border-style">solid</xsl:attribute>
        <xsl:attribute name="border-width">1pt</xsl:attribute>
        <xsl:attribute name="border-color">silver</xsl:attribute>
        <xsl:attribute name="background-color">#ffffee</xsl:attribute>
        <xsl:attribute name="padding-left">12pt</xsl:attribute>
        <xsl:attribute name="padding-right">12pt</xsl:attribute>
        <xsl:attribute name="padding-top">6pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">6pt</xsl:attribute>
        <xsl:attribute name="margin-left">0pt</xsl:attribute>
        <xsl:attribute name="margin-right">12pt</xsl:attribute>
        <xsl:attribute name="margin-top">6pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">6pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:param name="callout.graphics" select="'1'"/>

    <!-- Only shade programlisting and screen verbatim elements -->
    <xsl:param name="shade.verbatim" select="1"/>
    <xsl:attribute-set name="shade.verbatim.style">
        <xsl:attribute name="background-color">
            <xsl:choose>
                <xsl:when test="self::programlisting|self::screen">#E0E0E0</xsl:when>
                <xsl:otherwise>inherit</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <!--
      Force XSL Stylesheets 1.72 default table breaks to be the same as the current
      version (1.74) default which (for tables) is keep-together="auto".
    -->
    <xsl:attribute-set name="table.properties">
        <xsl:attribute name="keep-together.within-column">auto</xsl:attribute>
    </xsl:attribute-set>

    <!--

    Article title

    -->
    <xsl:template match="article" mode="object.title.markup">
        <xsl:param name="allow-anchors" select="0"/>
        <xsl:variable name="template">
            <xsl:apply-templates select="." mode="object.title.template"/>
        </xsl:variable>
        <fo:inline role="H1">
            <xsl:call-template name="substitute-markup">
                <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
                <xsl:with-param name="template" select="$template"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>

    <!-- Headings -->
    <xsl:attribute-set name="article.titlepage.verso.style">
        <xsl:attribute name="role">H1</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="section.title.level1.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 2.0736"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="margin-top">1em</xsl:attribute>
        <xsl:attribute name="role">H2</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="section.title.level2.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.728"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="margin-top">1em</xsl:attribute>
        <xsl:attribute name="role">H3</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="section.title.level3.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.44"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="margin-top">1em</xsl:attribute>
        <xsl:attribute name="role">H4</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="section.title.level4.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.2"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="margin-top">1em</xsl:attribute>
        <xsl:attribute name="role">H5</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="section.title.level5.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="margin-top">1em</xsl:attribute>
        <xsl:attribute name="role">H6</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="section.title.level6.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="margin-top">1em</xsl:attribute>
    </xsl:attribute-set>

    <!-- Lists -->
    <xsl:attribute-set name="list.item.spacing">
        <xsl:attribute name="space-before.optimum">0.6em</xsl:attribute>
        <xsl:attribute name="space-before.minimum">0.3em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.7em</xsl:attribute>
    </xsl:attribute-set>

    <!-- Footnotes -->
    <xsl:attribute-set name="superscript.properties">
        <xsl:attribute name="font-size">60%</xsl:attribute>
        <xsl:attribute name="baseline-shift">30%</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="footnote.mark.properties">
        <xsl:attribute name="font-family">
            <xsl:value-of select="$body.fontset"></xsl:value-of>
        </xsl:attribute>
        <xsl:attribute name="font-size">60%</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="baseline-shift">30%</xsl:attribute>
    </xsl:attribute-set>
    <xsl:template name="ulink.footnote.number">
        <fo:inline xsl:use-attribute-sets="footnote.mark.properties">
            <!--            <xsl:choose>-->
            <!--                <xsl:when test="$fop.extensions != 0">-->
            <!--                    <xsl:attribute name="vertical-align">super</xsl:attribute>-->
            <!--                </xsl:when>-->
            <!--                <xsl:otherwise>-->
            <!--                    <xsl:attribute name="baseline-shift">super</xsl:attribute>-->
            <!--                </xsl:otherwise>-->
            <!--            </xsl:choose>-->
            <xsl:variable name="fnum">
                <!-- * Determine the footnote number to display for this hyperlink, -->
                <!-- * by counting all foonotes, ulinks, and any elements that have -->
                <!-- * an xlink:href attribute that meets the following criteria: -->
                <!-- * -->
                <!-- * - the content of the element is not a URI that is the same -->
                <!-- *   URI as the value of the href attribute -->
                <!-- * - the href attribute is not an internal ID reference (does -->
                <!-- *   not start with a hash sign) -->
                <!-- * - the href is not part of an olink reference (the element -->
                <!-- * - does not have an xlink:role attribute that indicates it is -->
                <!-- *   an olink, and the href does not contain a hash sign) -->
                <!-- * - the element either has no xlink:type attribute or has -->
                <!-- *   an xlink:type attribute whose value is 'simple' -->
                <!-- FIXME: list in @from is probably not complete -->
                <xsl:number level="any"
                            from="chapter|appendix|preface|article|refentry|bibliography[not(parent::article)]"
                            count="footnote[not(@label)][not(ancestor::tgroup)]
                  |ulink[node()][@url != .][not(ancestor::footnote)]
                  |*[node()][@xlink:href][not(@xlink:href = .)][not(starts-with(@xlink:href,'#'))]
                    [not(contains(@xlink:href,'#') and @xlink:role = $xolink.role)]
                    [not(@xlink:type) or @xlink:type='simple']
                    [not(ancestor::footnote)]"
                            format="1"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="string-length($footnote.number.symbols) &gt;= $fnum">
                    <xsl:value-of select="substring($footnote.number.symbols, $fnum, 1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:number value="$fnum" format="{$footnote.number.format}"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:inline>
    </xsl:template>

    <!-- Source code -->
    <xsl:param name="highlight.source" select="1"/>
    <xsl:param name="highlight.xslthl.config">
        <xsl:text>file://</xsl:text>
        <xsl:value-of select="$theme.base"/>
        <xsl:text>/highlighting/xslthl-config.xml</xsl:text>
    </xsl:param>
    <xsl:attribute-set name="monospace.verbatim.properties"
                       use-attribute-sets="verbatim.properties monospace.properties">
        <xsl:attribute name="text-align">start</xsl:attribute>
        <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
        <xsl:attribute name="padding">.5em</xsl:attribute>
    </xsl:attribute-set>

    <!-- Admonitions -->
    <xsl:param name="admon.graphics.extension">.svg</xsl:param>
    <xsl:param name="admon.graphics" select="1"/>
    <xsl:param name="admon.graphics.path">images/</xsl:param>
    <xsl:attribute-set name="graphical.admonition.properties">
        <xsl:attribute name="space-before.optimum">2em</xsl:attribute>
        <xsl:attribute name="space-before.minimum">1.6em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">2.4em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">1em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">1.6em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">2.4em</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="nongraphical.admonition.properties">
        <xsl:attribute name="space-before.minimum">1.6em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">2em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">2.4em</xsl:attribute>
        <xsl:attribute name="margin-{$direction.align.start}">0.25in</xsl:attribute>
        <xsl:attribute name="margin-{$direction.align.end}">0.25in</xsl:attribute>
    </xsl:attribute-set>
    <xsl:template name="graphical.admonition">
        <xsl:variable name="id">
            <xsl:call-template name="object.id"/>
        </xsl:variable>
        <xsl:variable name="graphic.width">
            <xsl:apply-templates select="." mode="admon.graphic.width"/>
        </xsl:variable>

        <fo:block id="{$id}"
                  xsl:use-attribute-sets="graphical.admonition.properties">
            <fo:wrapper role="artifact">
                <fo:inline-container width="{$graphic.width} + 18pt" vertical-align="top">
                    <fo:block>
                        <fo:external-graphic width="auto" height="auto"
                                             content-width="{$graphic.width}">
                            <xsl:attribute name="src">
                                <xsl:call-template name="admon.graphic"/>
                            </xsl:attribute>
                        </fo:external-graphic>
                    </fo:block>
                </fo:inline-container>
            </fo:wrapper>
            <fo:inline-container width="100% - {$graphic.width} - 18pt" vertical-align="top">
                <xsl:if test="$admon.textlabel != 0 or title or info/title">
                    <fo:block xsl:use-attribute-sets="admonition.title.properties">
                        <xsl:apply-templates select="." mode="object.title.markup">
                            <xsl:with-param name="allow-anchors" select="1"/>
                        </xsl:apply-templates>
                    </fo:block>
                </xsl:if>
                <fo:block xsl:use-attribute-sets="admonition.properties">
                    <xsl:apply-templates/>
                </fo:block>
            </fo:inline-container>
        </fo:block>
    </xsl:template>

    <!-- Metadata support ("Document Properties" in Adobe Reader) -->
    <xsl:template name="fop1-document-information">
        <xsl:variable name="authors" select="(//db:author|//db:editor|//db:corpauthor|//db.authorgroup)[1]"/>

        <xsl:variable name="title">
            <xsl:apply-templates select="/*[1]" mode="label.markup"/>
            <xsl:apply-templates select="/*[1]" mode="title.markup"/>
            <xsl:variable name="subtitle">
                <xsl:apply-templates select="/*[1]" mode="subtitle.markup">
                    <xsl:with-param name="verbose" select="0"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:if test="$subtitle !=''">
                <xsl:text> - </xsl:text>
                <xsl:value-of select="$subtitle"/>
            </xsl:if>
        </xsl:variable>

        <fo:declarations>
            <x:xmpmeta xmlns:x="adobe:ns:meta/">
                <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                    <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
                        <!-- Dublin Core properties go here -->

                        <!-- Title -->
                        <dc:title>
                            <rdf:Alt>
                                <rdf:li xml:lang="x-default"><xsl:value-of select="normalize-space($title)"/></rdf:li>
                            </rdf:Alt>
                        </dc:title>

                        <!-- Author -->
                        <xsl:if test="$authors">
                            <xsl:variable name="author">
                                <xsl:choose>
                                    <xsl:when test="$authors[self::db:authorgroup]">
                                        <xsl:call-template name="t:person-name-list">
                                            <xsl:with-param name="person.list"
                                                            select="$authors/*[self::db:author|self::db.corpauthor|
                                     self::db:othercredit|self::db:editor]"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$authors[self::db.corpauthor]">
                                        <xsl:value-of select="$authors"/>
                                    </xsl:when>
                                    <xsl:when test="$authors[orgname]">
                                        <xsl:value-of select="$authors/orgname"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!--                                        TOLLWERK-->
                                        <!--                                        <xsl:call-template name="t:person-name">-->
                                        <!--                                            <xsl:with-param name="node" select="$authors"/>-->
                                        <!--                                        </xsl:call-template>-->
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>

                            <dc:creator>
                                <xsl:value-of select="normalize-space($author)"/>
                            </dc:creator>
                        </xsl:if>

                        <!-- Subject -->
                        <xsl:if test="//db:subjectterm">
                            <dc:description>
                                <xsl:for-each select="//db:subjectterm">
                                    <xsl:value-of select="normalize-space(.)"/>
                                    <xsl:if test="position() != last()">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </dc:description>
                        </xsl:if>
                    </rdf:Description>

                    <rdf:Description rdf:about="" xmlns:pdf="http://ns.adobe.com/pdf/1.3/">
                        <!-- PDF properties go here -->

                        <!-- Keywords -->
                        <xsl:if test="//db:keyword">
                            <pdf:Keywords>
                                <xsl:for-each select="//db:keyword">
                                    <xsl:value-of select="normalize-space(.)"/>
                                    <xsl:if test="position() != last()">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </pdf:Keywords>
                        </xsl:if>
                    </rdf:Description>

                    <rdf:Description rdf:about="" xmlns:xmp="http://ns.adobe.com/xap/1.0/">
                        <!-- XMP properties go here -->

                        <!-- Creator Tool -->
                        <xmp:CreatorTool>DocBook XSL Stylesheets with Apache FOP</xmp:CreatorTool>
                    </rdf:Description>

                </rdf:RDF>
            </x:xmpmeta>
        </fo:declarations>
    </xsl:template>
</xsl:stylesheet>
