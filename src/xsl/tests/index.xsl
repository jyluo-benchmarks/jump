<?xml version="1.0" encoding="UTF-8" ?>

<!--
 -*- mode: Fundamental; tab-width: 4; -*-
 ex:ts=4

 XSLT stylesheet that converts a JUnit testresult to HTML.

 $Id: index.xsl,v 1.13 2002/08/14 20:42:20 znerd Exp $
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output
	method="xml"
	indent="no"
	doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
	doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

	<xsl:template match="testsuite">
		<html>
			<head>
				<title>Test results</title>
				<link rel="stylesheet" type="text/css" href="stylesheet.css" />
			</head>
			<body>
				<h1>Test results</h1>
				<h2>Summary</h2>
				<table class="summary">
					<tr>
						<th>#</th>
						<th>Name</th>
						<th>Time</th>
						<th>Result</th>
					</tr>
					<xsl:apply-templates select="testcase" mode="summary" />
				</table>
				<p>
					<xsl:variable name="testcaseCount" select="count(testcase)" />
					<xsl:variable name="failedTestcaseCount" select="count(testcase/failure)" />
					<xsl:variable name="erroneousTestcaseCount" select="count(testcase/error)" />

					<xsl:text>Performed </xsl:text>
					<xsl:if test="$testcaseCount &gt; 1">
						<xsl:text>all </xsl:text>
					</xsl:if>
					<xsl:value-of select="$testcaseCount" />
					<xsl:text> test</xsl:text>
					<xsl:if test="$testcaseCount &gt; 1">
						<xsl:text>s</xsl:text>
					</xsl:if>
					<xsl:text> in </xsl:text>
					<xsl:value-of select="/testsuite/@time" />
					<xsl:text> second</xsl:text>
					<xsl:if test="not(/testsuite/@time = 1)">
						<xsl:text>s</xsl:text>
					</xsl:if>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="$failedTestcaseCount" />
					<xsl:text> failed and </xsl:text>
					<xsl:value-of select="$erroneousTestcaseCount" />
					<xsl:text> had errors.</xsl:text>
				</p>

				<h2>Test result details</h2>
				<xsl:apply-templates select="testcase" />
			</body>
		</html>
	</xsl:template>

	<xsl:template match="testcase" mode="summary">
		<xsl:variable name="testnumber" select="position()" />
		<xsl:variable name="name_orig"  select="substring-after(@name, 'test')" />
		<xsl:variable name="name_start" select="translate(substring($name_orig, 1, 1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
		<xsl:variable name="name_end"   select="substring($name_orig, 2, string-length($name_orig) - 1)" />

		<xsl:variable name="name" select="concat($name_start, $name_end)" />

		<tr>
			<td class="testnumber">
				<xsl:value-of select="$testnumber" />
			</td>
			<td class="testname">
				<a>
					<xsl:attribute name="href">
						<xsl:text>#test-</xsl:text>
						<xsl:value-of select="$name" />
					</xsl:attribute>
					<xsl:value-of select="$name" />
				</a>
			</td>
			<td>
				<xsl:value-of select="@time" />
			</td>
			<xsl:choose>
				<xsl:when test="failure">
					<td class="failure">
						<acronym>
							<xsl:attribute name="title">
								<xsl:value-of select="failure/@type" />
							</xsl:attribute>
							<xsl:value-of select="substring-after(substring-after(failure/@type, '.'), '.')" />
						</acronym>
					</td>
				</xsl:when>
				<xsl:when test="error">
					<td class="testresult_error">
						<xsl:apply-templates select="error" />
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td class="okay">OK</td>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>

	<xsl:template match="testcase[not(failure) and not(error)]">
		<xsl:variable name="name_orig"  select="substring-after(@name, 'test')" />
		<xsl:variable name="name_start" select="translate(substring($name_orig, 1, 1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
		<xsl:variable name="name_end"   select="substring($name_orig, 2, string-length($name_orig) - 1)" />

		<xsl:variable name="name" select="concat($name_start, $name_end)" />

		<a>
			<xsl:attribute name="name">
				<xsl:text>test-</xsl:text>
				<xsl:value-of select="$name" />
			</xsl:attribute>
		</a>
		<h3>
			<xsl:text>Test </xsl:text>
			<xsl:value-of select="$name" />
		</h3>
		<table class="testcase_details">
			<tr>
				<th>Name:</th>
				<td>
					<xsl:value-of select="$name" />
				</td>
			</tr>
			<tr>
				<th>Time:</th>
				<td>
					<xsl:value-of select="@time" />
					<xsl:text> second</xsl:text>
					<xsl:if test="not(@time = 1)">
						<xsl:text>s</xsl:text>
					</xsl:if>
				</td>
			</tr>
		</table>
	</xsl:template>

	<xsl:template match="testcase[failure]">
		<xsl:variable name="name_orig"  select="substring-after(@name, 'test')" />
		<xsl:variable name="name_start" select="translate(substring($name_orig, 1, 1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
		<xsl:variable name="name_end"   select="substring($name_orig, 2, string-length($name_orig) - 1)" />

		<xsl:variable name="name"    select="concat($name_start, $name_end)" />

		<xsl:variable name="details_orig"        select="failure/text()" />
		<xsl:variable name="details_orig_length" select="string-length($details_orig)" />
		<xsl:variable name="details_after_at"   select="substring-after($details_orig, 'at ')" />
		<xsl:variable name="details_after_at_length" select="string-length(details_after_at)" />
		<xsl:variable name="details"             select="$details_after_at" />

		<a>
			<xsl:attribute name="name">
				<xsl:text>test-</xsl:text>
				<xsl:value-of select="$name" />
			</xsl:attribute>
		</a>
		<h3>
			<xsl:text>Test </xsl:text>
			<xsl:value-of select="$name" />
			<xsl:text> (</xsl:text>
			<span class="failure">Failed</span>
			<xsl:text>)</xsl:text>
		</h3>
		<table class="testcase_details">
			<tr>
				<th>Name:</th>
				<td>
					<xsl:value-of select="$name" />
				</td>
			</tr>
			<tr>
				<th>Time:</th>
				<td>
					<xsl:value-of select="@time" />
					<xsl:text> second</xsl:text>
					<xsl:if test="not(@time = 1)">
						<xsl:text>s</xsl:text>
					</xsl:if>
				</td>
			</tr>
			<tr>
				<th>Failure type:</th>
				<td>
					<xsl:value-of select="failure/@type" />
				</td>
			</tr>
			<tr>
				<th>Message:</th>
				<td class="testdetails_message">
					<xsl:value-of select="normalize-space(failure/@message)" />
				</td>
			</tr>
			<tr>
				<th>Details:</th>
				<td class="testdetails_details">
					<xsl:value-of select="$details" />
				</td>
			</tr>
		</table>
	</xsl:template>
</xsl:stylesheet>
