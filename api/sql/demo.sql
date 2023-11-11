


INSERT INTO timeCardPunches (userID) VALUES (1);
UPDATE timeCardPunches SET punchOutTime = dateTime("2023-11-12") WHERE userID = 1 AND punchOutTime IS NULL;

SELECT SUM((strftime('%s', punchOutTime) - strftime('%s', punchInTime)) / 3600.0) AS total_time
FROM timeCardPunches
WHERE userID = 1;
