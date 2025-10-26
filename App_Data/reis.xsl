<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Основной шаблон -->
	<xsl:output method="html" indent="yes"/>

	<xsl:template match="/reisedata">
		<html>
			<head>
				<meta charset="utf-8"/>
				<title>Trips</title>
				<style>
					.third { background-color: yellow; padding: 2px; display: inline-block; }
					.highlight { font-weight: bold; color: red; }
					table { border-collapse: collapse; width: 100%; }
					th, td { border: 1px solid #ccc; padding: 6px; text-align: left; }
					.row-odd { background-color: #f9f9f9; }
					.row-even { background-color: #ffffff; }
				</style>
			</head>
			<body>
				<!-- Список поездок: фильтрация по наличию flight/price -->
				<xsl:for-each select="trip[transport/flight/price!='']">
					<!-- сортировка по rating (убывание) -->
					<xsl:sort select="number(rating)" data-type="number" order="descending"/>
					<div>
						<h1>
							<xsl:value-of select="destination"/>
							<xsl:text> </xsl:text>
							<xsl:text>(рейтинг: </xsl:text>
							<xsl:value-of select="rating"/>
							<xsl:text>)</xsl:text>
						</h1>

						<!-- Рассчёт стоимости: берем flight/price если есть, иначе train/price -->
						<xsl:variable name="transportPrice">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(transport/flight/price)) &gt; 0">
									<xsl:value-of select="number(transport/flight/price)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="number(transport/train/price)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<xsl:variable name="accPrice" select="number(accommodation/hotel/price)"/>
						<xsl:variable name="exc" select="number(excursions/total)"/>
						<xsl:variable name="meals" select="number(meals/total)"/>
						<xsl:variable name="ins" select="number(insurance/total)"/>
						<xsl:variable name="oth" select="number(other/total)"/>
						<xsl:variable name="total" select="$transportPrice + $accPrice + $exc + $meals + $ins + $oth"/>

						<!-- Показ компонентов -->
						<ul>
							<li>
								Transport
								<ul>
									<li>
										<!-- третий уровень: flight -->
										<span class="third">
											<xsl:if test="string-length(normalize-space(transport/flight/price)) &gt; 0">
												Flight: <xsl:value-of select="transport/flight/number"/> -
												<xsl:value-of select="transport/flight/airport"/> -
												<xsl:value-of select="transport/flight/price"/>
											</xsl:if>
											<xsl:if test="not(string-length(normalize-space(transport/flight/price)))">
												Train price: <xsl:value-of select="transport/train/price"/>
											</xsl:if>
										</span>
									</li>
								</ul>
							</li>

							<li>
								Accommodation
								<ul>
									<li>
										<span class="third">
											<xsl:value-of select="accommodation/hotel/name"/> —
											<xsl:value-of select="accommodation/hotel/stars"/>★ —
											<xsl:value-of select="accommodation/hotel/price"/> €
										</span>
									</li>
								</ul>
							</li>

							<li>
								Excursions: <span class="third">
									<xsl:value-of select="excursions/total"/> €
								</span>
							</li>
							<li>
								Meals: <span class="third">
									<xsl:value-of select="meals/total"/> €
								</span>
							</li>
							<li>
								Insurance: <span class="third">
									<xsl:value-of select="insurance/total"/> €
								</span>
							</li>
							<li>
								Other: <span class="third">
									<xsl:value-of select="other/total"/> €
								</span>
							</li>
						</ul>

						<!-- Итоговая сумма с условием выделения -->
						<p>
							Total cost:
							<xsl:choose>
								<xsl:when test="$total &gt; 1000">
									<span class="highlight">
										<xsl:value-of select="format-number($total,'0.00')"/> €
									</span>
								</xsl:when>
								<xsl:otherwise>
									<span>
										<xsl:value-of select="format-number($total,'0.00')"/> €
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</p>

						<hr/>
					</div>
				</xsl:for-each>

				<!-- Табличный вывод: все trip (чередующиеся цвета) -->
				<h2>All trips (XML dump)</h2>
				<table>
					<tr>
						<th>ID</th>
						<th>Destination</th>
						<th>Rating</th>
						<th>Transport</th>
						<th>Accommodation</th>
						<th>Excursions</th>
						<th>Meals</th>
						<th>Insurance</th>
						<th>Other</th>
						<th>Total</th>
					</tr>
					<xsl:for-each select="trip">
						<xsl:variable name="rowClass">
							<xsl:choose>
								<xsl:when test="position() mod 2 = 1">row-odd</xsl:when>
								<xsl:otherwise>row-even</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<xsl:variable name="tprice">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(transport/flight/price)) &gt; 0">
									<xsl:value-of select="number(transport/flight/price)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="number(transport/train/price)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="sum" select="number($tprice) + number(accommodation/hotel/price) + number(excursions/total) + number(meals/total) + number(insurance/total) + number(other/total)"/>

						<tr>
							<td class="{$rowClass}">
								<xsl:value-of select="@id"/>
							</td>
							<td class="{$rowClass}">
								<xsl:value-of select="destination"/>
							</td>
							<td class="{$rowClass}">
								<xsl:value-of select="rating"/>
							</td>
							<td class="{$rowClass}">
								<xsl:if test="string-length(normalize-space(transport/flight/price)) &gt; 0">
									<xsl:value-of select="concat('Flight ', transport/flight/number, ' (', transport/flight/airport, ') ', transport/flight/price, '€')"/>
								</xsl:if>
								<xsl:if test="not(string-length(normalize-space(transport/flight/price)))">
									<xsl:value-of select="concat('Train ', transport/train/price, '€')"/>
								</xsl:if>
							</td>
							<td class="{$rowClass}">
								<xsl:value-of select="concat(accommodation/hotel/name, ' — ', accommodation/hotel/stars, '★ — ', accommodation/hotel/price, '€')"/>
							</td>
							<td class="{$rowClass}">
								<xsl:value-of select="excursions/total"/>
							</td>
							<td class="{$rowClass}">
								<xsl:value-of select="meals/total"/>
							</td>
							<td class="{$rowClass}">
								<xsl:value-of select="insurance/total"/>
							</td>
							<td class="{$rowClass}">
								<xsl:value-of select="other/total"/>
							</td>
							<td class="{$rowClass}">
								<xsl:value-of select="format-number($sum,'0.00')"/>
							</td>
						</tr>
					</xsl:for-each>
				</table>

			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
