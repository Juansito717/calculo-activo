<?xml version="1.0" encoding="UTF-8" ?>
<!-- **********************************************************************-->
<!-- Copyright 2012-2018                                                   -->
<!-- Matthew Boelkins                                                      -->
<!--                                                                       -->
<!-- This file is part of Active Calculus.                                 -->
<!--                                                                       -->
<!-- Permission is granted to copy, distribute and/or modify this document -->
<!-- under the terms of the Creative Commons BY-SA license.  The work      -->
<!-- may be used for free by any party so long as attribution is given to  -->
<!-- the author(s), the work and its derivatives are used in the spirit of -->
<!-- "share and share alike".  All trademarks are the registered marks of  -->
<!-- their respective owners.                                              -->
<!-- **********************************************************************-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Next paths assume current file has been copied to mathbook/user -->
<xsl:import href="../xsl/mathbook-latex.xsl" />
<xsl:import href="acs-common.xsl" />
<xsl:param name="toc.level" select="'3'" />

<xsl:output method="text" />

<!-- These switches will control what we include -->
<xsl:param name="exercise.divisional.hint" select="'no'" />
<xsl:param name="exercise.divisional.answer" select="'no'" />
<xsl:param name="exercise.divisional.solution" select="'no'" />

<xsl:param name="exercise.reading.statement" select="'no'" />

<!-- Preview activities and activities are project-like. -->
<xsl:param name="project.hint" select="'no'" />
<xsl:param name="project.answer" select="'no'" />
<xsl:param name="project.solution" select="'no'" />

<!-- Superfluous frontmatter for workbook -->
<!-- So we don't bother and kill first two pages   -->
<xsl:template match="*" mode="half-title" />
<xsl:template match="*" mode="ad-card" />

<!-- Chapters: default presentation, we have them all, so numbers OK     -->
<!-- Sections and Equivalents: kill them, except for specific ones below -->
<xsl:template match="conclusion|exercises|references|objectives|appendix|index|solutions|reading-questions" />


<!-- As a subset of full content, we can't         -->
<!-- point to much of the content with hyperlinks  -->
<!-- We do have the full context as we process, so -->
<!-- we can get numbers for cross-references and   -->
<!-- hard code them into the LaTeX                 -->
<!-- This override obliterates autonaming support  -->
<xsl:template match="*" mode="ref-id">
    <xsl:apply-templates select="." mode="number" />
</xsl:template>

<!-- We do the expedient thing and *hard-code* the number    -->
<!-- of each item cross-referenced from within the solutions -->
<!-- manual, so the cropss-refernce text matches with HTML   -->
<!-- output and LaTeX output for the entire book.            -->
<!-- Since the output LaTeX file is a subset of the content, -->
<!-- there will not be a \label for many \ref, and worse, if -->
<!-- there is a \label then a \ref to it will be wrong.      -->
<xsl:template match="*" mode="xref-number">
  <xsl:apply-templates select="." mode="number" />
</xsl:template>


<!-- If we do not include statements, then we kill -->
<!-- introductions and conclusions for exercise    -->
<!-- sections and exercise groups                  -->
<xsl:template match="exercises/introduction|exercises/conclusion|exercisegroup/introduction|exercisegroup/conclusion">
    <xsl:choose>
        <xsl:when test="$exercise.text.statement='yes'">
            <xsl:apply-imports />
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- We start a new page after each activity and PA -->
<xsl:template match="activity|exploration">
    <xsl:apply-imports />
    <xsl:text>\cleardoublepage&#xA;&#xA;</xsl:text>
</xsl:template>

<!-- Only process activity within subsection -->

<xsl:template match="introduction|subsection">
    <xsl:apply-templates select="exploration|activity" />
</xsl:template>

<!-- Captions for Figures, Tables, Listings, Lists -->
<!-- xml:id is on parent, but LaTeX generates number with caption -->
<xsl:template match="figure|listing|table|list" mode="title-caption">
    <!-- construct appropriate command -->
    <xsl:choose>
        <xsl:when test="parent::sidebyside/parent::figure or parent::sidebyside/parent::sbsgroup/parent::figure">
            <xsl:text>\subcaption*{</xsl:text>
        </xsl:when>
        <xsl:when test="self::figure/parent::sidebyside">
            <xsl:text>\captionof*{figure}{</xsl:text>
        </xsl:when>
        <xsl:when test="self::table/parent::sidebyside">
            <xsl:text>\captionof*{table}{</xsl:text>
        </xsl:when>
        <xsl:when test="self::listing">
            <xsl:text>\captionof*{listingcap}{</xsl:text>
        </xsl:when>
        <xsl:when test="self::list">
            <xsl:text>\captionof*{namedlistcap}{</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>\caption*{</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
    <!-- produce the actual content -->
    <xsl:text>\textbf{</xsl:text>
    <xsl:apply-templates select="." mode="type-name"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="." mode="number"/>
    <xsl:text>:} </xsl:text>
    <xsl:choose>
        <xsl:when test="self::figure or self::listing">
            <xsl:apply-templates select="." mode="caption-full"/>
        </xsl:when>
        <xsl:when test="self::table or self::list">
            <xsl:apply-templates select="." mode="title-full"/>
        </xsl:when>
        <!-- never used? -->
        <xsl:otherwise>
            <xsl:apply-templates select="caption"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}&#xa;</xsl:text>
</xsl:template>


<!-- Use letter paper and leave one-inch margins all around -->
<xsl:param name="latex.geometry" select="'letterpaper,tmargin=.5in,bmargin=.3in,hmargin=.75in,includeheadfoot,lmargin=1in'" />

<xsl:param name="latex.preamble.late">
    <xsl:value-of select="$latex.preamble.late.common" />
</xsl:param>

</xsl:stylesheet>

