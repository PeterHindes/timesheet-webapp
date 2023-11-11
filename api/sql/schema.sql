DROP TABLE IF EXISTS timeCardPunches;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
	userID INTEGER PRIMARY KEY CHECK (typeof(userID) = 'integer') CHECK (userID >= 0),
	email TEXT NOT NULL UNIQUE
);

CREATE TABLE timeCardPunches (
		punchID INTEGER PRIMARY KEY CHECK (typeof(punchID) = 'integer') CHECK (punchID >= 0),
		userID INTEGER CHECK (typeof(userID) = 'integer') CHECK (userID >= 0) NOT NULL,
		punchCatagory INTEGER DEFAULT 0 CHECK (typeof(punchCatagory) = 'integer') CHECK (punchCatagory >= 0) NOT NULL,
		punchInTime TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (punchInTime IS dateTime(punchInTime)),
		punchOutTime TEXT DEFAULT NULL CHECK (punchOutTime IS dateTime(punchOutTime)),
		FOREIGN KEY (userID) REFERENCES users(userID)
);
CREATE TRIGGER check_punch_in_time
BEFORE INSERT ON timeCardPunches
FOR EACH ROW
BEGIN
  SELECT RAISE(ABORT, 'New punch in time is before the last punch out time')
  WHERE NEW.punchInTime < (SELECT MAX(punchOutTime)
                           FROM timeCardPunches
                           WHERE userID = NEW.userID AND punchCatagory = NEW.punchCatagory);
END;


