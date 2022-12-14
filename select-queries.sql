USE BUDT703_Project_0506_02
-- Create view to show the restaurants' details including the average stars and 
numbers of reviews written by the users. 
GO
DROP VIEW [VanMunchers.rating];
 
GO
CREATE VIEW [VanMunchers.rating] AS
SELECT r.rstId, r.rstName, CONCAT(r.rstAddress, ', ', r.rstCity, ', ', 
r.rstState, ' ', r.rstPostalCode) AS 'rstLoc',
r.rstWeb, res.rstNumReview, res.rstStars, d.NumBook
FROM [VanMunchers.Restaurant] r
LEFT JOIN (
SELECT re.rstId, ROUND((CAST(SUM(re.revStars) AS float)/ 
CAST(COUNT(*) AS float)), 1) AS 'rstStars', COUNT (re.revId) as 'rstNumReview' FROM
[VanMunchers.Review] re GROUP BY re.rstId) res ON res.rstId = r.rstId
LEFT JOIN (
SELECT b.rstId, COUNT(b.usrId) AS 'NumBook' FROM 
[VanMunchers.Bookmark] b GROUP BY b.rstId) d ON r.rstId = d.rstId
GROUP BY r.rstId, r.rstName, CONCAT(r.rstAddress, ', ', r.rstCity, ', ', 
r.rstState, ' ', r.rstPostalCode), r.rstWeb, res.rstNumReview, rstStars, d.NumBook
WITH CHECK OPTION;
GO
 
-- Create view to show the users' details including the numbers of reviews that the
users wrote. 
GO
DROP VIEW IF EXISTS [VanMunchers.numCusRev];
GO
CREATE VIEW [VanMunchers.numCusRev] AS
SELECT u.usrId, u.usrName, CONCAT(u.usrCity, ', ', u.usrState) AS 'usrLoc', 
u.usrStartDate, COUNT(re.revId) AS 'usrNumReview'
FROM [VanMunchers.User] u, [VanMunchers.Review] re
WHERE u.usrId = re.usrId
GROUP BY u.usrId, u.usrName, u.usrCity, u.usrState, u.usrStartDate
WITH CHECK OPTION;
GO
-- Create view to show the restaurant amenities. 
Go
DROP VIEW IF EXISTS [VanMunchers.RestAmenities];
Go
CREATE VIEW [VanMunchers.RestAmenities] AS
SELECT rs.rstId,rs.rstName,a.ameAlcohol, a.ameAndroidPay, a.ameApplePay, 
a.ameDelivery, a.ameOutDoorSeat, a.ameParking,a.ameReservartion,a.ameStaffMasks,
a.ameTakeOut, a.ameVegetarian,a.ameWaiterService,a.ameWifi,
(a.ameAlcohol+a.ameAndroidPay+a.ameApplePay+a.ameDelivery+a.ameOutDoorSeat+a.amePar
king+
a.ameReservartion+a.ameStaffMasks+a.ameTakeOut+a.ameVegetarian+a.ameWaiterService+a
.ameWifi) as 'totalAmenities' 
FROM [VanMunchers.Restaurant] rs,[VanMunchers.Amenities] a
WHERE rs.rstId=a.rstId
WITH CHECK OPTION;
GO
-- Create view to evaluate restaurants' performances from two web sources.
GO
DROP VIEW IF EXISTS [VanMunchers.RestWebsource]
GO
CREATE VIEW [VanMunchers.RestWebsource] AS
SELECT w.*,rs.rstName, ROUND((CAST(SUM(r.revStars) AS float)/ CAST(COUNT(*) AS 
float)), 1) AS 'avgStars', COUNT(r.revId) AS 'Number of Review'
FROM [VanMunchers.Review] r,[VanMunchers.Websource] w, [VanMunchers.Restaurant] rs
WHERE r.webId=w.webId AND r.rstId=rs.rstId
GROUP BY w.webId, webSource, rs.rstName
WITH CHECK OPTION;
GO
-- 1. What are the top 5 restaurants that have the greatest number of reviews?
SELECT Top(5) ra.rstName, ra.rstNumReview
FROM [VanMunchers.rating] ra
ORDER BY ra.rstNumReview DESC;
-- 2. What are the top 5 restaurants with the highest star ratings? 
SELECT Top(5) ra.rstName, ra.[rstStars] AS 'Restaurant Stars'
FROM [VanMunchers.rating] ra
ORDER BY ra.rstStars DESC;
-- 3. What are the restaurant names, its number of amenities and its average stars?
SELECT r.rstName AS 'Restaurant', r.rstStars AS 'Average Stars',a.totalAmenities AS
'Number of Amenities'
FROM [VanMunchers.rating] r, [VanMunchers.RestAmenities] a
WHERE r.rstId = a.rstId
GROUP BY r.rstName, r.rstStars, a.totalAmenities
ORDER BY a.totalAmenities DESC
-- 4. Whether the rating of the restaurant is different from 2 web resources?
SELECT rw.webSource,rw.rstName, rw.avgStars
FROM [VanMunchers.RestWebsource] rw;
-- 5. Who are the users that are more active in sharing their views? 
SELECT u.usrName, SUM(a.textchars) AS 'Review Characters'
FROM (
SELECT *,(LEN([VanMunchers.Review].revText)) as textchars 
FROM [VanMunchers.Review]) a, [VanMunchers.User] u
WHERE a.usrId = u.usrId
GROUP BY a.usrId, u.usrName
ORDER BY SUM(a.textchars) DESC
-- 6. Which restaurant provides more amenities than average?
SELECT a.rstName, a.totalAmenities 
FROM [VanMunchers.RestAmenities] a
WHERE a.totalAmenities > (select AVG(totalAmenities) FROM 
[VanMunchers.RestAmenities])
ORDER BY a.totalAmenities DESC;
-- 7. What amenities did the top 3 restaurants have in common for them to be 
popular? (considering bookmarks as a measure of popularity)
SELECT TOP (3) r.rstName, a.ameAlcohol, a.ameAndroidPay, a.ameApplePay, 
a.ameDelivery, a.ameOutDoorSeat, a.ameParking,a.ameReservartion,a.ameStaffMasks,
a.ameTakeOut, a.ameVegetarian,a.ameWaiterService,a.ameWifi,ra.NumBook
FROM [VanMunchers.Restaurant] r, [VanMunchers.Amenities] a,[VanMunchers.Bookmark] 
b, [VanMunchers.rating] ra
WHERE a.rstId=r.rstId AND ra.rstId=r.rstId
GROUP BY r.rstName,a.ameAlcohol, a.ameAndroidPay, a.ameApplePay, a.ameDelivery, 
a.ameOutDoorSeat, a.ameParking,a.ameReservartion,a.ameStaffMasks,
a.ameTakeOut, a.ameVegetarian,a.ameWaiterService,a.ameWifi,ra.NumBook
ORDER BY ra.NumBook DESC
--8. What are the top 5 restaurant which received the most number of bookmarks?
SELECT Top(5) ra.rstName, ra.NumBook AS 'Number of Bookmarks'
FROM [VanMunchers.rating] ra
ORDER BY ra.NumBook DESC;
-- 9. What are the names of customers that have written the most number of reviews?
SELECT ncr.usrName, ncr.usrNumReview
FROM [VanMunchers.numCusRev] ncr, (
SELECT MAX(ncr.usrNumReview) AS MaxNum FROM [VanMunchers.numCusRev] ncr) m
WHERE ncr.usrNumReview = m.MaxNum
ORDER BY ncr.usrNumReview DESC;