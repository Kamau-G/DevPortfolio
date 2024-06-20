IF DB_ID('CasinoDB') IS NOT NULL
 DROP DATABASE CasinoDB;
GO
CREATE DATABASE CasinoDB;
GO
USE CasinoDB;
GO
CREATE TABLE ClubCategories (
    id INT PRIMARY KEY IDENTITY(1,1),
    cat_name VARCHAR(50) NOT NULL,  -- Name oegoryId INT REFERENCES Categories(CategoryId),  -- Ff the Club
    info VARCHAR(240)  -- Description of the Club 
);
GO
CREATE TABLE Clubs (
    id INT PRIMARY KEY IDENTITY(1,1),
    club_name VARCHAR(50) NOT NULL,  -- Name of the Club
    category_id INT,  -- Foreign key referencing Categories table not marked do to database triggers dealing with is_active
    info VARCHAR(240) CHECK (LEN(info) >= 10),  -- Description of the Club 
	is_active BIT DEFAULT 1
	CONSTRAINT club_name_unique UNIQUE (club_name),
);
GO
CREATE TABLE Games (
    id INT PRIMARY KEY IDENTITY(1,1) ,
    game_name VARCHAR(50) NOT NULL,  -- Name of the Game
    genre VARCHAR(20),             -- Genre of the Game 
    min_players INT,                 -- Minimum number of players 
    max_players INT                  -- Maximum number of players 
	CONSTRAINT game_name_unique UNIQUE (game_name)
);
GO
CREATE TABLE CasinoEvents (
    id INT PRIMARY KEY IDENTITY(1,1),
    event_name VARCHAR(50) NOT NULL,  -- Name of the Casino Event
    event_date DATETIME NOT NULL,         -- Date of the Casino Event
    info VARCHAR(240),               -- Description of the Event 
    start_time DATETIME,                  -- Start time of the Event 
	end_time DATETIME
);
GO
CREATE TABLE Patrons (
    id INT PRIMARY KEY IDENTITY(1,1),
    patron_name VARCHAR(100) NOT NULL, -- Name of the Patron
    patron_rank VARCHAR(20) CHECK (patron_rank IN ('Alpha','Gold', 'Silver', 'Bronze','Omega')),       -- Membership Level (e.g., Gold, Silver, Bronze)
    Email VARCHAR(50),                 -- Patron's email address 
	is_active BIT Default 1,
	CONSTRAINT patron_email_unique UNIQUE (Email),
);
GO
CREATE TABLE EventVisitors(
	patron_id INT NOT NULL FOREIGN KEY REFERENCES Patrons(id),
	event_id INT NOT NULL FOREIGN KEY REFERENCES CasinoEvents(id)
);
GO
CREATE TABLE Coins (
    id INT PRIMARY KEY IDENTITY(1,1),  -- Auto-incrementing integer for unique ID
    coin_name VARCHAR(50) NOT NULL,  -- Name of the coin (e.g., Bitcoin, Penny)
    coin_value DECIMAL(10,2) NOT NULL  -- Decimal value of the coin
	CHECK (coin_value > 0),
	CHECK (coin_value >= 0.01 AND coin_value <= 1000000),
	CONSTRAINT coin_name_unique UNIQUE (coin_name)
);
CREATE TABLE PatronCoinsHeld(
	coin_id INT FOREIGN KEY REFERENCES coins(id),
	patron_id INT FOREIGN KEY REFERENCES patrons(id),
	amount DECIMAL(10,2) NULL
);
GO
CREATE TABLE PatronCoinsLost(
	coin_id INT FOREIGN KEY REFERENCES coins(id),
	patron_id INT FOREIGN KEY REFERENCES patrons(id),
	amount DECIMAL(10,2) NULL
);
GO
CREATE TABLE Notes (
    id INT PRIMARY KEY IDENTITY(1,1),  -- Auto-incrementing integer for unique ID
	sndr INT FOREIGN KEY REFERENCES patrons(id),
	rcpnt INT FOREIGN KEY REFERENCES patrons(id),
    note_text VARCHAR(240) NOT NULL CHECK (LEN(note_text)>=10),           -- Text content of the note
    creation_date DATETIME NOT NULL CHECK (creation_date>=GETDATE())        -- Date the note was created
);
GO
CREATE TABLE Competitions (
    id INT PRIMARY KEY IDENTITY(1,1),  -- Auto-incrementing integer for unique ID
    title VARCHAR(100) NOT NULL CHECK (LEN(title) >= 5), -- title of the comp
	info VARCHAR(240) NOT NULL CHECK (LEN(info) >= 10), -- information about comp
	CONSTRAINT competition_title_unique UNIQUE (title)
);
GO
CREATE TABLE CompetitionParticipants(
	patron_id INT FOREIGN KEY REFERENCES patrons(id),
	comp_id INT FOREIGN KEY REFERENCES Competitions(id),
	sign_up_date DATETIME DEFAULT GETDATE()
);
GO
CREATE TABLE CompWinners (
    id INT PRIMARY KEY IDENTITY(1,1),  -- Auto-incrementing integer for unique ID
    winner_name VARCHAR(100) NOT NULL, -- Name of the winner
    competition_id INT FOREIGN KEY REFERENCES Competitions(id)  -- Foreign key referencing Competitions table (assumes a Competitions table exists)
);
GO
CREATE TABLE GameWinners(
    id INT PRIMARY KEY IDENTITY(1,1),  -- Auto-incrementing integer for unique ID
    winner_name VARCHAR(100) NOT NULL, -- Name of the winner
    game_id INT FOREIGN KEY REFERENCES Competitions(id)  -- Foreign key referencing Competitions table (assumes a Competitions table exists)
);
GO
CREATE TABLE Departments (
    id INT PRIMARY KEY IDENTITY(1,1),  -- Auto-incrementing integer for unique ID
    dep_name VARCHAR(100) NOT NULL CHECK (LEN(dep_name) >= 3), -- Name of the department
	CONSTRAINT department_name_unique UNIQUE (dep_name)
);
GO
CREATE TABLE Employees (
    id INT PRIMARY KEY IDENTITY(1,1),  -- Auto-incrementing integer for unique ID
    employee_name VARCHAR(100) NOT NULL CHECK (LEN(employee_name) >= 3), -- Name of the employee
    department_id INT FOREIGN KEY REFERENCES Departments(id),  -- Foreign key referencing Departments table (assumes a Departments table exists)
    hire_date DATETIME DEFAULT GETDATE()             -- Date the employee was hired
	
);
GO
CREATE TABLE Managers(
	id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	emp_id INT FOREIGN KEY REFERENCES Employees(id) NOT NULL,
	is_avtive BIT DEFAULT 0,
	hire_date DATETIME DEFAULT GETDATE()
);
CREATE TABLE Regions (
    id INT PRIMARY KEY IDENTITY(1,1),  -- Auto-incrementing integer for unique ID
    region_name VARCHAR(50) NOT NULL CHECK (LEN(region_name) >= 3), -- Name of the region
    manager_id INT FOREIGN KEY REFERENCES Employees(id),  -- Foreign key referencing Employees table (assumes an Employees table exists)
	CONSTRAINT region_name_unique UNIQUE (region_name)
);
GO
USE CasinoDB;
BEGIN TRY
	BEGIN TRAN;
	--CREATE CLUSTERED INDEX idx_game_id ON Games(id);
	CREATE NONCLUSTERED INDEX idx_game_name ON Games(game_name);
	--CREATE CLUSTERED INDEX idx_competition_id ON Competitions(id);
	CREATE NONCLUSTERED INDEX idx_competition_title ON Competitions(title);
	--CREATE CLUSTERED INDEX idx_note_id ON Notes(id);
	CREATE NONCLUSTERED INDEX idx_note_date ON Notes(creation_date);
	--CREATE CLUSTERED INDEX idx_patron_id ON Patrons(id);
	CREATE NONCLUSTERED INDEX idx_patron_rank ON Patrons(patron_rank);
	--CREATE CLUSTERED INDEX idx_club_category_id ON Clubs(id);
	CREATE NONCLUSTERED INDEX idx_club_category_active ON Clubs(category_id, is_active);
	--CREATE CLUSTERED INDEX idx_event_date_id ON CasinoEvents(id);
	CREATE NONCLUSTERED INDEX idx_event_date_name ON CasinoEvents(event_date, event_name);
	--CREATE CLUSTERED INDEX idx_coin_id ON Coins(id);
	CREATE NONCLUSTERED INDEX idx_coin_value ON Coins(coin_value);

COMMIT TRAN;
  PRINT 'Index Transaction Passed';
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
  PRINT 'Index Transaction Failed';
END CATCH;
GO
USE CasinoDB;
GO
BEGIN TRY
	BEGIN TRAN;
INSERT INTO ClubCategories(cat_name,info) VALUES('High Roller','Members love to spend money');
INSERT INTO ClubCategories(cat_name,info) VALUES('Low Roller','Members love to watch people spend money');
-- Insert Club 1 (VIP)
INSERT INTO Clubs (club_name, category_id, info)
VALUES ('High Rollers Club', (SELECT MIN(id) FROM ClubCategories), 'A club for our most valued patrons.');
-- Insert Club 2 (Slots)
INSERT INTO Clubs (club_name, category_id, info)
VALUES ('Slot Maniacs', (SELECT Max(id) FROM ClubCategories), 'Join us for thrilling slots and big wins!');
-- Insert Club 2 (Astrology)
INSERT INTO Clubs (club_name, category_id, info)
VALUES ('Club Astrology', NULL, 'Join us to game with the stars!');
-- Insert Club 2 (Tennis)
INSERT INTO Clubs (club_name, category_id, info)
VALUES ('Club Tennis', NULL, 'Join us to play tennis!');
-- Insert Game 1 (Blackjack)
INSERT INTO Games (game_name, genre, min_players, max_players)
VALUES ('Spades', 'Card Game', 1, 7);
-- Insert Game 2 (Roulette)
INSERT INTO Games (game_name, genre, min_players, max_players)
VALUES ('Roulette', 'Table Game', 1, 8);
-- Insert Patron 1
INSERT INTO Patrons (patron_name, patron_rank, Email)
VALUES ('John Smith', 'Gold', 'john.smith@email.com');
-- Insert Patron 2
INSERT INTO Patrons (patron_name, patron_rank)
VALUES ('Jane Doe', 'Silver');
-- Insert Coin 1 (USD)
INSERT INTO Coins (coin_name, coin_value)
VALUES ('USD', 1.00);
-- Insert Coin 2 (Bitcoin)
INSERT INTO Coins (coin_name, coin_value)
VALUES ('Bitcoin', 10000.00);
--Insert PatronCoinsHeld 1
INSERT INTO PatronCoinsHeld VALUES ((SELECT MAX(id) FROM Coins),(SELECT Min(id) FROM Patrons),100);
--Insert PatronCoinsHeld 2
INSERT INTO PatronCoinsHeld VALUES ((SELECT MAX(id) FROM Coins),(SELECT MAX(id) FROM Patrons),1000000);
-- Insert Note 1 (About a patron)
INSERT INTO Notes
VALUES ((SELECT MAX(id) FROM Patrons),(SELECT MIN(id) FROM Patrons),'Met with patron John Smith today to discuss membership upgrade options.', GETDATE());
-- Insert Note 2 (General note)
INSERT INTO Notes
VALUES ((SELECT MIN(id) FROM Patrons),(SELECT MAX(id) FROM Patrons),'Reminder to update slot machine payouts for the upcoming promotion.', GETDATE());
-- Insert Department 1 (Security)
INSERT INTO Departments (dep_name)
VALUES ('Security');
-- Insert Department 2 (Marketing)
INSERT INTO Departments (dep_name)
VALUES ('Marketing');
-- Insert Employee 1 (Security) (references Departments table)
INSERT INTO Employees (employee_name, department_id, hire_date)
VALUES ('John Jones', (SELECT MAX(id) FROM Departments), GETDATE() - 1250);
-- Insert Employee 2 (Marketing) (references Departments table)
INSERT INTO Employees (employee_name, department_id, hire_date)
VALUES ('Jane Doe', (SELECT MIN(id) FROM Departments), GETDATE() - 365);
-- Insert Region 1 (North America) (references Employees table)
INSERT INTO Regions (region_name, manager_id)
VALUES ('Mexico', (SELECT MAX(id) FROM Employees));  -- Assuming John Jones (Employee 1) is the manager
-- Insert Region 2 (Europe) (references Employees table)
INSERT INTO Regions (region_name, manager_id)
VALUES ('Pacific North West', (SELECT MAX(id) FROM Employees));
-- House Data
-- Insert Department 1 (House)
INSERT INTO Departments (dep_name)
VALUES ('House');
INSERT INTO Employees (employee_name, department_id, hire_date)
VALUES ('House', (SELECT id FROM Departments WHERE dep_name = 'House'), GETDATE() - 3650);
-- Comp Data
INSERT INTO Competitions VALUES ('Tennis Games','The match of all time, competitors will have to defeat every entry to win the prize');
INSERT INTO Competitions VALUES ('Card Game Tournement','The best card matchs of all time, there will be a random card game chosen to play. When or go home');
INSERT INTO Competitions VALUES ('Battle of Will','Staring competition if you blink you lose no pressure');
COMMIT TRAN;
  PRINT 'Insert Transaction Pass';
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	PRINT 'Insert Transaction Fail';
END CATCH;
----

GO
USE CasinoDB;
GO
--- Triggers
CREATE TRIGGER trg_club_desc_on_insert
 ON Clubs AFTER INSERT
AS
BEGIN
  IF LEN((SELECT info FROM inserted)) < 10
  BEGIN
    RAISERROR ('Club description must be at least 10 characters long.', 16, 1);
    ROLLBACK TRANSACTION;  -- Rollback the entire transaction if description is too short
  END;
END;
GO
CREATE TRIGGER trg_club_category_delete
 ON ClubCategories AFTER DELETE
AS
BEGIN
  UPDATE Clubs
  SET is_active = 0
  WHERE category_id = (SELECT id FROM deleted);
END;
GO
CREATE TRIGGER trg_setPatronToActive
 ON Notes AFTER INSERT
AS
BEGIN
  UPDATE Patrons
  SET is_active = 1
  WHERE id = (SELECT sndr FROM inserted)
  OR id = (SELECT rcpnt FROM inserted);
END;
GO
--- FUNCTIONS
CREATE FUNCTION fn_getActiveClubsByCategory (@category_id INT)
RETURNS TABLE
AS
RETURN (
  SELECT c.id, c.club_name, c.info
  FROM Clubs c
  INNER JOIN ClubCategories cc ON c.category_id = cc.id
  WHERE cc.id = @category_id AND c.is_active = 1
);
GO
CREATE FUNCTION fn_PatronCoinValues (@patron_id INT)
RETURNS TABLE
AS
RETURN(
  SELECT coin_name,coin_id,amount,coin_value, (amount * coin_value) AS total_value_held FROM Patrons p 
  JOIN PatronCoinsHeld pch ON p.id = pch.patron_id
  JOIN Coins c ON pch.coin_id = c.id
  WHERE p.id = @patron_id
  );
 GO
CREATE FUNCTION fn_getPatronAmountOfCoinsHeld (@patron_id INT)
RETURNS DECIMAL(15,2)
AS
BEGIN
  DECLARE @returnValue DECIMAL(10,2);

  SELECT @returnValue = SUM(amount) FROM PatronCoinsHeld WHERE patron_id = @patron_id

  RETURN @returnValue;
END;
GO
--- PROCEDURES
CREATE PROCEDURE prc_CreatePatron
(
  @patron_name VARCHAR(100),
  @patron_rank VARCHAR(20),
  @email VARCHAR(50)
)
AS
BEGIN
  DECLARE @existing_email BIT;

  -- Check for existing email (optional, modify based on your needs)
  IF @email IS NULL OR @email in (SELECT email FROM Patrons) 
    BEGIN
      RAISERROR ('Email address is null or already exists.', 16, 1);
      RETURN;  -- Exit the procedure if email already exists
  END;
  ELSE
  -- Insert new patron record
  INSERT INTO Patrons (patron_name, patron_rank, Email)
  VALUES (@patron_name, @patron_rank, @email);
END;
GO
CREATE PROCEDURE prc_UpdateGameInfo
(
  @game_id INT,
  @game_name VARCHAR(50),
  @genre VARCHAR(20),
  @min_players INT,
  @max_players INT
)
AS
BEGIN
  IF @game_id in (select id from Games)
  BEGIN
  -- Update game details (check for existing game_id if needed)
  UPDATE Games
  SET game_name = @game_name,
      genre = @genre,
      min_players = @min_players,
      max_players = @max_players
  WHERE id = @game_id;
  END;
  ELSE
   RAISERROR ('Id does not exist', 16, 1);
   RETURN;  -- Exit the procedure if email already exists
END;
GO
-- DELETE's a category
CREATE PROCEDURE prc_DeleteClubCategory(@idToDel INT)
AS BEGIN
 BEGIN TRY
  BEGIN TRAN;
   DELETE FROM ClubCategories WHERE id = @idToDel;
   COMMIT TRAN;
  END TRY
 BEGIN CATCH
  RAISERROR ('Category Id not found.', 10,1);
  ROLLBACK TRAN;
END CATCH;
END;
GO
CREATE PROCEDURE prc_regesterCompParticipant(@patron_id INT, @comp_id INT)
AS BEGIN
   IF @patron_id in (SELECT id FROM Patrons) AND @comp_id in (SELECT id FROM Competitions)
   BEGIN
    INSERT INTO CompetitionParticipants VALUES (@patron_id,@comp_id,GETDATE())
   END;
   ELSE
    RAISERROR ('Transaction Fail one or both ids invalid.', 10,1);
END;

-- <TEST AREA>
--- PROCEDURE TESTS ---
/*

DECLARE @testId INT;
SET @testId = (SELECT MAX(id) FROM Games);
EXEC dbo.prc_UpdateGameInfo @testId,'THIS WORKS','card',6,11;
GO
SELECT * FROM Games;
EXEC dbo.prc_CreatePatron 'Enkidu','Omega','Enkidu@email.com';
GO
SELECT * FROM Patrons;
GO
DECLARE @testId2 INT;
DECLARE @testId3 INT;
DECLARE @testId4 INT;
DECLARE @testId5 INT;
SET @testId2 = (SELECT MAX(id) FROM Patrons);
SET @testId4 = (SELECT MAX(id) FROM Competitions);
SET @testId3 = (SELECT MIN(id) FROM Patrons);
SET @testId5 = (SELECT MIN(id) FROM Competitions);
EXEC dbo.prc_regesterCompParticipant @testId2 ,@testId5;
EXEC dbo.prc_regesterCompParticipant @testId3,@testId4;
GO
SELECT * FROM CompetitionParticipants;
*/

--- FUNCTION TESTS ---
/*

USE CasinoDB;
GO
SELECT dbo.fn_getPatronAmountOfCoinsHeld ((SELECT MIN(id) FROM Patrons)) AS Aggregate_Coin_Quantity;
GO
SELECT * FROM fn_PatronCoinValues((SELECT MIN(id) FROM Patrons));
GO
SELECT * FROM fn_getActiveClubsByCategory((SELECT MIN(id) FROM ClubCategories));

*/
--- TRIGGER TESTS ---

/*
-- Club_isActive trg test 
SELECT * FROM ClubCategories;
GO
SELECT * FROM Clubs;
GO
DELETE FROM ClubCategories WHERE id = (SELECT MIN(id) FROM ClubCategories);
GO
SELECT * FROM ClubCategories;
GO
SELECT * FROM Clubs;
*/