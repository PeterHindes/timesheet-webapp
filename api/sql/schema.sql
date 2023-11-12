DROP TABLE IF EXISTS timeCardPunches;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
	userID INTEGER PRIMARY KEY CHECK (typeof(userID) = 'integer') CHECK (userID >= 0),
	email TEXT NOT NULL UNIQUE
);

CREATE TABLE timeCardPunches (
		punchID INTEGER PRIMARY KEY CHECK (typeof(punchID) = 'integer') CHECK (punchID >= 0),
		userID INTEGER CHECK (typeof(userID) = 'integer') CHECK (userID >= 0) NOT NULL,
		punchCatagory INTEGER DEFAULT "none selected",
		punchInTime TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (punchInTime IS dateTime(punchInTime)),
		punchOutTime TEXT DEFAULT NULL CHECK (punchOutTime IS dateTime(punchOutTime)),
		FOREIGN KEY (userID) REFERENCES users(userID)
);
CREATE TRIGGER check_punch_in_time_insert
BEFORE INSERT ON timeCardPunches
FOR EACH ROW
BEGIN
  SELECT RAISE(ABORT, 'New punch in time is before the last punch out time')
  WHERE NEW.punchInTime < (SELECT MAX(punchOutTime)
                           FROM timeCardPunches
                           WHERE userID = NEW.userID AND punchCatagory = NEW.punchCatagory AND punchInTime < NEW.punchInTime);
END;

CREATE TRIGGER check_punch_in_time_update
BEFORE UPDATE ON timeCardPunches
FOR EACH ROW
BEGIN
  SELECT RAISE(ABORT, 'New punch times overlap with existing punch times')
  WHERE NEW.punchInTime < (SELECT punchOutTime
                           FROM timeCardPunches
                           WHERE userID = NEW.userID AND punchCatagory = NEW.punchCatagory AND punchID < OLD.punchID
                           ORDER BY punchID DESC
                           LIMIT 1)
  OR NEW.punchOutTime > (SELECT punchInTime
                         FROM timeCardPunches
                         WHERE userID = NEW.userID AND punchCatagory = NEW.punchCatagory AND punchID > OLD.punchID
                         ORDER BY punchID ASC
                         LIMIT 1);
END;


