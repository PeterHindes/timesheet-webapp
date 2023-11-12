-- Insert a new user
INSERT INTO users(email) VALUES ('test@example.com');

-- Insert an earlier punch for the user
INSERT INTO timeCardPunches (userID, punchCatagory, punchInTime, punchOutTime)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test', datetime('now', '-4 hours'), datetime('now', '-3 hours'));

-- Insert a newer punch for the user with no punch out time
INSERT INTO timeCardPunches (userID, punchCatagory, punchInTime)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test', datetime('now'));

-- Insert a middle punch for the user after having inserted the newer punch (might fail, should succeed)
INSERT INTO timeCardPunches (userID, punchCatagory, punchInTime, punchOutTime)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test', datetime('now', '-2 hours'), datetime('now', '-1 hours'));
