-- Insert a new user
INSERT INTO users(email) VALUES ('test@example.com');

-- Insert a new punch for the user without providing an end time or start time
INSERT INTO timeCardPunches (userID, punchCatagory)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test');

-- Try to insert a new punch before closing the last one should fail
INSERT INTO timeCardPunches (userID, punchCatagory)
VALUES ((SELECT userID FROM users WHERE email = 'test@example.com'), 'test');
