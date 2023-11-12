-- Insert a new user
INSERT INTO users(email) VALUES ('test@example.com');

-- Insert a new punch for the user
INSERT INTO timeCardPunches (userID, punchCatagory, punchInTime, punchOutTime)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test', datetime('now', '-2 hours'), datetime('now', '-1 hours'));

-- Attempt to insert a punch that overlaps with the existing punch
INSERT INTO timeCardPunches (userID, punchCatagory, punchInTime, punchOutTime)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test', datetime('now', '-1 hours'), datetime('now'));
