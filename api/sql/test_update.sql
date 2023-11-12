-- Insert a new user
INSERT INTO users(email) VALUES ('test@example.com');

-- Insert an earlier punch for the user
INSERT INTO timeCardPunches (userID, punchCatagory, punchInTime, punchOutTime)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test', datetime('now', '-4 hours'), datetime('now', '-3 hours'));

-- Insert a middle punch for the user
INSERT INTO timeCardPunches (userID, punchCatagory, punchInTime, punchOutTime)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test', datetime('now', '-2 hours'), datetime('now', '-1 hours'));

-- Insert a newer punch for the user
INSERT INTO timeCardPunches (userID, punchCatagory, punchInTime, punchOutTime)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test', datetime('now'), datetime('now', '+1 hours'));

-- Update the middle punch to end before the newer punch starts
UPDATE timeCardPunches
SET punchOutTime = datetime('now', '+1 second')
WHERE userID = (SELECT userID FROM users WHERE email = 'test@example.com') AND punchCatagory = 'test' AND punchInTime = datetime('now', '-2 hours');

-- Update the middle punch to start after the earlier punch ends
UPDATE timeCardPunches
SET punchInTime = datetime('now', '-3 hours', '-1 second')
WHERE userID = (SELECT userID FROM users WHERE email = 'test@example.com') AND punchCatagory = 'test' AND punchInTime = datetime('now', '-2 hours');
