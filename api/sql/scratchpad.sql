

UPDATE timeCardPunches SET punchOutTime = CURRENT_TIMESTAMP WHERE userID = 1 AND punchOutTime IS NULL;


INSERT INTO users(email) VALUES ('example@example.com');
UPDATE timeCardPunches SET punchOutTime = dateTime("2023-11-12") WHERE userID = 1 AND punchOutTime IS NULL;



INSERT INTO timeCardPunches (userID) VALUES (1);

SELECT SUM((strftime('%s', punchOutTime) - strftime('%s', punchInTime)) / 3600.0) AS total_time
FROM timeCardPunches
WHERE userID = 1;
