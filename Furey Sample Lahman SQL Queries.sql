-- Which pitcher had the most strikeouts between 2000-2009?

SELECT p.playerID, CONCAT(m.nameFirst, ' ', m.nameLast) as Player, SUM(p.SO) as SO
FROM lahman2014.Pitching p
INNER JOIN lahman2014.master m
	ON p.playerID = m.playerID
WHERE p.yearID BETWEEN 2000 AND 2009
GROUP BY m.nameFirst, m.nameLAST, p.playerID
ORDER BY SO desc

-- Randy Johnson, 2182 SO
-- Javier Vazquez, 2001 SO
-- Johan Santana, 1733 SO
-- Pedro Martinez, 1620 SO
-- CC Sabathia, 1590 SO


-- Which player had the highest career OBP between Kevin Youkilis and Travis Hafner?

SELECT b.playerID, CONCAT(m.nameFirst, ' ', m.nameLast) as Player, SUM(H+BB+HBP)/SUM(AB+BB+SF+HBP) as OBP
FROM Batting b
INNER JOIN master m
	ON b.playerID = m.playerID
WHERE b.playerID IN ('youklke01','hafnetr01')
GROUP BY m.nameFirst, m.nameLAST, b.playerID
ORDER BY OBP desc

-- Kevin Youkilis, .382 OBP
-- Travis Hafner, .376 OBP


-- #3 Which pitcher has won the most Cy Young Awards in their career?

SELECT m.playerID, CONCAT(m.nameFirst, ' ', m.nameLast) as Player, 
	COUNT(ap.yearID) as CYA
FROM master m
INNER JOIN AwardsPlayers ap
	ON m.playerID = ap.playerID
WHERE ap.awardID = 'Cy Young Award'
GROUP BY m.nameFirst, m.nameLAST, m.playerID
HAVING COUNT(ap.yearID) >= 2
ORDER BY CYA desc, m.nameLAST asc

-- Roger Clemens, 7
-- Randy Johnson, 5
-- Steve Carlton, 4
-- Greg Maddux, 4
-- Clayton Kershaw, 3
-- Sandy Koufax, 3
-- Pedro Martinez, 3
-- Jim Palmer, 3
-- Tom Seaver, 3


-- #4 Which players committed at least 20 fielding errors during the 2000 season?

SELECT f.playerID, POS, CONCAT(m.nameFirst, ' ', m.nameLast) as Player, E as Errors, f.yearID
FROM fielding f
INNER JOIN master m
	ON f.playerID = m.playerID
WHERE f.yearID = 2000
	AND E >= 20
GROUP BY m.nameFirst, m.nameLAST, f.playerID, f.POS, f.yearID, Errors
ORDER BY Errors desc

-- SS Jose Valentin, 36 Errors
-- 3B Troy Glaus, 33 Errors
-- 3B Mike Lamb, 33 Errors
-- 'renteed01','SS','Edgar Renteria','27','2000'
-- 'nevinph01','3B','Phil Nevin','26','2000'
-- 'jeterde01','SS','Derek Jeter','24','2000'
-- 'relafde01','SS','Desi Relaford','24','2000'
-- 'beltrad01','3B','Adrian Beltre','23','2000'
-- 'furcara01','SS','Rafael Furcal','23','2000'
-- 'jonesch06','3B','Chipper Jones','23','2000'
-- 'palmede01','3B','Dean Palmer','23','2000'
-- 'guzmacr01','SS','Cristian Guzman','22','2000'
-- 'aurilri01','SS','Rich Aurilia','21','2000'
-- 'tejadmi01','SS','Miguel Tejada','21','2000'
-- 'mearepa01','SS','Pat Meares','20','2000'


-- #5 How much total salary did Roy Oswalt earn over the course of his career?

SELECT m.playerID, CONCAT(m.nameFirst, ' ', m.nameLast) as Player, SUM(salary) as Total_Salary
FROM master m
INNER JOIN salaries s
	ON m.playerID = s.playerID
WHERE m.playerID = 'oswalro01'
GROUP BY m.nameFirst, m.nameLAST, m.playerID

-- Roy Oswalt, $91,950,000


-- #6 What was the maximum number of errors made by Omar Vizquel in a single season in his career?

SELECT f.playerID, CONCAT(m.nameFirst, ' ', m.nameLast) as Player, MAX(E) as Max_Errors
FROM Fielding f
INNER JOIN master m
	ON f.playerID = m.playerID
WHERE f.playerID = 'vizquom01'
GROUP BY m.nameFirst, m.nameLAST, f.playerID

-- Omar Vizquel, 20


-- #7 Return the career Slugging Percentage and Salary totals for all players that debuted in the 1990 season and accumulated at least 1000 career At-bats.

CREATE TEMPORARY TABLE 90sluggers
SELECT
	b.playerID,
	SUM(AB) as CareerAB,
    (SUM(H-2B-3B-HR)+SUM(2B*2)+SUM(3B*3)+SUM(HR*4))/SUM(AB) as CareerSLG
FROM Batting b
INNER JOIN master m
	ON b.playerID = m.playerID
WHERE m.debut >= '1990-01-01' 
	AND m.debut <= '1990-12-31'
GROUP BY b.playerID
HAVING SUM(AB) >= 1000
ORDER BY CareerSLG desc;
		  
SELECT 
	m.playerID,
    CONCAT(m.nameFirst, ' ', m.nameLast) as Player,
    CareerSLG,
	SUM(salary) as Total_Salary
FROM master m
INNER JOIN 90sluggers lumber
	ON m.playerID = lumber.playerID
INNER JOIN salaries s
	ON m.playerID = s.playerID
GROUP BY m.nameFirst, m.nameLast, m.playerID, CareerSLG
ORDER BY Total_Salary desc

#  Player,           CareerSLG,        Total_Salary
-- Frank Thomas, 0.555 career SLG, $104634000 career salary 
-- Moises Alou, 0.516 career SLG, $85983474 career salary 
-- Luís Gonzalez,0.479 career SLG, $65393259 career salary
-- Tino Martinez, 0.471 career SLG, $51,845,000 career salary
-- Ray Lankford, 0.476 career SLG, $47,795,001 career salary
-- ...


#8 Return the two MVP Award winners from 2005 (AL and NL) along with their overall Avg, OBP, SLG, OPS, and wOBA from that season.

SELECT 
	b.playerID,
	CONCAT(m.nameFirst, ' ', m.nameLast) as Player, 
    ap.lgID,
    ap.awardID as MVP,
    b.yearID,
    (H/AB) as BatAvg,
    (H+BB+HBP)/(AB+BB+SF+HBP) as OBP, 
	((H-2B-3B-HR)+(2B*2)+(3B*3)+(HR*4))/AB as SLG,
	(H+BB+HBP)/(AB+BB+SF+HBP) + ((H-2B-3B-HR)+(2B*2)+(3B*3)+(HR*4))/AB as OPS,
	(((.703*(BB-IBB))+(.733*HBP)+(.890*(H-2B-3B-HR))+(1.271*2B)+(1.616*3B)+(2.101*HR))/(AB+BB-IBB+SF+SH+HBP)) as wOBA
FROM Batting b
INNER JOIN AwardsPlayers ap
	ON b.playerID = ap.playerID
INNER JOIN Master m
	ON b.playerID = m.playerID
WHERE b.yearID = 2005
	AND ap.awardID = 'Most Valuable Player'
    AND ap.yearID = 2005
GROUP BY m.nameFirst, m.nameLAST, b.playerID, ap.lgID, MVP, b.yearID, BatAvg, OBP, SLG, OPS, wOBA

-- Alex Rodriguez, 2005 AL MVP, 0.4422065 wOBA
-- Albert Pujols, 2005 NL MVP, 0.4382437 wOBA
