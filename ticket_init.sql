DROP DATABASE IF EXISTS Online_ticket_booking;
/* Create the database */
CREATE DATABASE IF NOT EXISTS Online_ticket_booking;
/* Switch to the online_ticket_booking database */
USE Online_ticket_booking;

/* Drop existing tables  */
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS ticketTypes;
DROP TABLE IF EXISTS ticketDeliveries;
DROP TABLE IF EXISTS venuePickUp; 
DROP TABLE IF EXISTS emailDelivery;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS vouchers;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS bookingCreations;


/* Create the customers table */
CREATE TABLE IF NOT EXISTS customers(
	customerId INT AUTO_INCREMENT PRIMARY KEY,
    fName VARCHAR(255) NOT NULL,
    lName VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    addressLine VARCHAR(50) NOT NULL,
    city varchar(20) NOT NULL,
	postalCode varchar(15) DEFAULT NULL,
	country varchar(30) NOT NULL,
    CONSTRAINT uc_name_address UNIQUE (fName, lName, addressLine, city, postalCode, country)
) ENGINE=INNODB;

/* Insert data into the customers table */
INSERT INTO customers(fName, lName, email, phone, addressLine, city, postalCode, country) values
('Alice', 'Smith', 'alicesmith@gmail.com', '+496966902550', '54, rue Royale','Nantes','44000','France'),
('Bob', 'Jones', 'bobjones@gmail.com', '+496966902551', '8489 Strong St.','Las Vegas','83030','USA'),
('Mary', 'Williams', 'marywilliams@gmail.com', '+496966902552', '636 St Kilda Road','Melbourne','3004','Australia');


/* Create the events table */
CREATE TABLE IF NOT EXISTS events(
	eventId INT AUTO_INCREMENT PRIMARY KEY,
    eventName VARCHAR(50) NOT NULL,
    eventDescription TEXT,
    startDateTime DATETIME NOT NULL,
    endDateTime DATETIME NOT NULL,
    totalTickets INT NOT NULL,
    city varchar(20) NOT NULL,
    country varchar(30) NOT NULL,
    venue VARCHAR(50) NOT NULL,
    CONSTRAINT start_before_end CHECK(endDateTime >= startDateTime)
) ENGINE=INNODB;

/* Insert data into the events table */
INSERT INTO events(eventName, eventDescription, startDateTime, endDateTime, totalTickets, city, country, venue) values
('Exeter Food Festival 2023', 'Food festival in Exeter', '2023-06-10 10:00:00', '2023-06-11 01:00:00', 10, 'Exeter', 'UK', 'Cathedral Square'),
('Exmouth Music Festival 2023', 'Music festival in Exmouth', '2023-07-01 16:00:00', '2023-07-02 04:00:00', 20, 'Exmouth', 'UK', 'Beach Lane'),
('Taylor Swift Concert 2024', 'Taylor Swift concert in London', '2024-03-21 19:00:00', '2024-03-21 23:00:00', 10, 'London', 'UK', 'Wembley'),
('Art Gallery Open Day', 'Art gallery open day in Exeter', '2023-07-08 10:00:00', '2023-07-08 18:00:00', 5, 'Exeter', 'UK', 'Albert Gallery'),
('Rock Band Concert', 'Rock band concert in Exeter', '2023-12-17 21:00:00', '2023-12-18 00:00:00', 5, 'Exeter', 'UK', 'Exeter Phoenix'),
('Christmas Entertainment Park', 'Christmas event in Berlin', '2023-12-20 16:00:00', '2023-12-20 22:00:00', 5, 'Berlin', 'Germany', 'Brandenburg Tur'),
('Deutsche Wurst Tag', 'German sausages day in Exeter', '2023-07-04 10:00:00', '2023-07-04 20:00:00', 5, 'Exeter', 'UK', 'University Campus');


/* Create the tickettypes table */
CREATE TABLE IF NOT EXISTS ticketTypes(
	ticketType VARCHAR(30) NOT NULL,
    basePrice DECIMAL(10,2) NOT NULL CHECK (basePrice >= 0),
    seatsTotal INT NOT NULL,
    eventId INT NOT NULL,
    CONSTRAINT pk_ticketype PRIMARY KEY (ticketType, eventId),
    CONSTRAINT fk_tt_event FOREIGN KEY (eventId) 
		REFERENCES events(eventId) ON DELETE CASCADE -- !!!!!!!!!!!!!!
) ENGINE=INNODB;

/* Insert data into the tickettypes table */
INSERT INTO ticketTypes(ticketType, basePrice, seatsTotal, eventId) values
('Adult', 25.00, 5, 1),
('Child', 10.00, 5, 1),
('Gold', 100.00, 3, 2),
('Silver', 70.00, 7, 2),
('Bronze', 45.00, 10, 2),
('Outskirt', 150.00, 4, 3),
('Premium', 250.00, 3, 3),
('VIP', 500.00, 3, 3),
('Adult', 30.00, 3, 4),
('Student', 18.00, 2, 4),
('Friends', 5.00, 2, 5),
('Standard', 20.00, 3, 5),
('Adult', 20.00, 3, 6),
('Child', 10.00, 2, 6),
('Standard', 8.00, 5, 7);


/* Create the ticketdeliveries table */
CREATE TABLE IF NOT EXISTS ticketDeliveries(
	deliveryId INT AUTO_INCREMENT PRIMARY KEY,
    deliveryStatus VARCHAR(30) NOT NULL
) ENGINE=INNODB;

/* Insert data into the ticketdeliveries table */
INSERT INTO ticketDeliveries(deliveryStatus) values
('Delivered'),
('Delivered'),
('Delivered'),
('Delivered'),
('Delivered'),
('Delivered'),
('Delivered'),
('Delivered'),
('Delivered');


/* Create the venuepickup table */
CREATE TABLE IF NOT EXISTS venuePickUp(
	deliveryId INT PRIMARY KEY,
    pickUpLocation VARCHAR(50) NOT NULL,
    CONSTRAINT fk_venue_delivery FOREIGN KEY (deliveryId) 
		REFERENCES ticketDeliveries(deliveryId)
) ENGINE=INNODB;

/* Insert data into the venuepickup table */
INSERT INTO venuePickUp(deliveryId, pickUpLocation) values
(1, 'Exeter, Cathedral Square'),
(3, 'Exeter, Exeter Phoenix'),
(4, 'Exeter, Cathedral Square'),
(8, 'Exeter, Albert Gallery');


/* Create the emaildelivery table */
CREATE TABLE IF NOT EXISTS emailDelivery(
	deliveryId INT PRIMARY KEY,
    emailAddress VARCHAR(255) NOT NULL,
    CONSTRAINT fk_email_delivery FOREIGN KEY (deliveryId) 
		REFERENCES ticketDeliveries(deliveryId)
) ENGINE=INNODB;

/* Insert data into the emaildelivery table */
INSERT INTO emailDelivery(deliveryId, emailAddress) values
(2, 'alicesmith@gmail.com'),
(5, 'bobjones@gmail.com'),
(6, 'bobjones@gmail.com'),
(7, 'marywilliams@gmail.com'),
(9, 'marywilliams@gmail.com');


/* Create the bookings table */
CREATE TABLE IF NOT EXISTS bookings(
	referenceCode INT AUTO_INCREMENT PRIMARY KEY ,
    bookingDate DATETIME DEFAULT NOW(),
    -- 1 for success (true), 0 - false (successful if exists payment that has this referenceCode)
    isSuccessful TINYINT(1) NOT NULL,
    -- eligible if eventStartDate > NOW() and isSuccessful = true
    eligibleForRefund TINYINT(1) NOT NULL,
    refundDate DATETIME DEFAULT NULL,
    refundReason TEXT DEFAULT NULL,
    eventId INT,
    ticketDeliveryWay INT,
    CONSTRAINT fk_b_event FOREIGN KEY (eventId) 
		REFERENCES events(eventId) ON DELETE SET NULL, -- !!!!!!!!!
	CONSTRAINT fk_b_delivery FOREIGN KEY (ticketDeliveryWay) 
		REFERENCES ticketDeliveries(deliveryId) ON DELETE SET NULL -- !!!!!!!!!
	-- CHECK ((isSuccessful = 0 AND ticketDeliveryWay IS NULL AND eligibleForRefund = 0) OR (isSuccessful = 1 AND ticketDeliveryWay IS NOT NULL))
    -- check eligibleForRefund 1 when isSuccessful is 1
) ENGINE=INNODB;

/* Start incrementing booking id from 100 */
ALTER TABLE bookings AUTO_INCREMENT=100;

/* Insert data into the bookings table */
INSERT INTO bookings(bookingDate, isSuccessful, eligibleForRefund, eventId, ticketDeliveryWay) values
('2023-05-10 10:00:00', 1, 0, 1, 1),
('2023-06-01 16:31:00', 1, 0, 2, 2),
('2023-10-17 20:03:00', 0, 0, 5, NULL),
('2023-11-01 07:11:00', 1, 1, 7, 3),
('2023-04-08 08:00:00', 1, 0, 1, 4),
('2023-05-21 21:01:00', 1, 0, 2, 5),
('2023-03-21 17:02:00', 1, 1, 3, 6),
('2023-10-20 08:00:00', 0, 0, 6, NULL),
('2023-06-23 16:31:00', 1, 0, 2, 7),
('2023-06-14 22:07:00', 1, 0, 4, 8),
('2023-05-04 03:22:00', 1, 0, 7, 9);


/* Create the tickets table */
CREATE TABLE IF NOT EXISTS tickets(
	ticketId INT AUTO_INCREMENT PRIMARY KEY,
    ticketType VARCHAR(30) NOT NULL,
    bookingId INT,
    eventId INT,
    CONSTRAINT fk_t_booking FOREIGN KEY (bookingId) 
		REFERENCES bookings(referenceCode),
    CONSTRAINT fk_t_ticket_type FOREIGN KEY (ticketType) 
		REFERENCES ticketTypes(ticketType) ON DELETE CASCADE, -- !!!!!!!!!!!
	CONSTRAINT fk_t_event FOREIGN KEY (eventId) 
		REFERENCES events(eventId) ON DELETE CASCADE -- !!!!!!!!!!!
) ENGINE=INNODB;

/* Insert data into the tickets table */
INSERT INTO tickets(ticketType, bookingId, eventId) values
('Adult',100,1),
('Adult',100,1),
('Child',100,1),
('Silver',101,2),
('Gold',101,2),
('Bronze',101,2),
('Bronze',101,2),
('Bronze',101,2),
('Standard',102,5),
('Standard',102,5),
('Friends',102,5),
('Standard',103,7),
('Standard',103,7),
('Adult',104,1),
('Gold',105,2),
('Silver',105,2),
('Silver',105,2),
('Bronze',105,2),
('Premium',106,3),
('VIP',106,3),
('Premium',106,3),
('Adult',107,4),
('Adult',107,6),
('Adult',107,6),
('Child',107,6),
('Bronze',108,2),
('Bronze',108,2),
('Adult',109,4),
('Student',109,4),
('Standard',110,7);


/* Create the cards table */
CREATE TABLE IF NOT EXISTS cards(
	-- need to specify there are 16 digits
	cardNumber BIGINT PRIMARY KEY,
    cardType VARCHAR(10) NOT NULL,
    securityCode INT NOT NULL,
    expiryDate VARCHAR(7) NOT NULL,
    cardHolder INT,
    CONSTRAINT fk_c_customer FOREIGN KEY (cardHolder) 
		REFERENCES customers(customerId)
) ENGINE=INNODB;

/* Insert data into the cards table */
INSERT INTO cards(cardNumber, cardType, securityCode, expiryDate, cardHolder) values
(4111111111111111,'Visa',323,'2029-07',1),
(5431111111111111,'Mastercard',643,'2027-11',2),
(371111111111114,'Amex', 927,'2025-05',3);


/* Create the vouchers table */
CREATE TABLE IF NOT EXISTS vouchers(
	code VARCHAR(50) PRIMARY KEY,
    -- change to percentage
    discountAmount DECIMAL(10,2) NOT NULL UNIQUE CHECK (discountAmount >= 0),
    voucherStatus VARCHAR(30) DEFAULT 'Not applied',
    eventId INT,
    -- appliedPayment
    CONSTRAINT fk_v_event FOREIGN KEY (eventId) 
		REFERENCES events(eventId) ON DELETE CASCADE -- !!!!!!!!!!!
) ENGINE=INNODB;

/* Insert data into the vouchers table */
INSERT INTO vouchers(code, discountAmount, eventId) values
('SAUSAGEDAY', 15.00, 7),
('FAN10', 5.00, 3);


/* Create the payments table */
CREATE TABLE IF NOT EXISTS payments(
	paymentId INT AUTO_INCREMENT PRIMARY KEY,
    totalAmountToPay DECIMAL(10,2) NOT NULL UNIQUE CHECK (totalAmountToPay >= 0),
    paymentTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cardNumber BIGINT,
    bookingId INT NOT NULL,
    voucherCode VARCHAR(50),
    CONSTRAINT fk_p_cardNum FOREIGN KEY (cardNumber) 
		REFERENCES cards(cardNumber),
    CONSTRAINT fk_p_booking FOREIGN KEY (bookingId) 
		REFERENCES bookings(referenceCode),
    CONSTRAINT fk_p_voucher FOREIGN KEY (voucherCode) 
		REFERENCES vouchers(code)
) ENGINE=INNODB;

/* Insert data into the payments table */
INSERT INTO payments(totalAmountToPay, paymentTime, cardNumber, bookingId) values
(60.00,'2023-05-10 20:00:00',4111111111111111,100),
(305.00,'2023-06-01 16:33:00',4111111111111111,101),
(16.00,'2023-11-02 09:13:00',4111111111111111,103),
(25.00,'2023-04-08 10:01:00',5431111111111111,104),
(285.00,'2023-05-22 11:21:00',5431111111111111,105),
(1000.00,'2023-04-18 14:16:00',5431111111111111,106),
(90.00,'2023-06-23 21:13:00',371111111111114,108),
(48.00,'2023-06-15 01:19:00',371111111111114,109),
(8.00,'2023-05-04 13:26:00',371111111111114,110);


/* Create the bookingcreations table */
CREATE TABLE IF NOT EXISTS bookingCreations(
	customerId INT,
    eventId INT,
    bookingId INT,
    totalPrice DECIMAL(10,2),
    PRIMARY KEY (eventId, bookingId),
    CONSTRAINT fk_bc_customer FOREIGN KEY (customerId) 
		REFERENCES customers(customerId),
    CONSTRAINT fk_bc_event FOREIGN KEY (eventId) 
		REFERENCES events(eventId) ON DELETE CASCADE, -- !!!!!!!!!!!
    CONSTRAINT fk_bc_booking FOREIGN KEY (bookingId) 
		REFERENCES bookings(referenceCode),
	CONSTRAINT unique_booking UNIQUE (customerId, eventId, bookingId)
) ENGINE=INNODB;

/* Insert data into the bookingcreations table */
INSERT INTO bookingCreations(customerId, eventId, bookingId, totalPrice) values
(1,1,100,60.00),
(1,2,101,305.00),
(1,5,102,45.00),
(1,7,103,16.00),
(2,1,104,25.00),
(2,2,105,285.00),
(2,3,106,1000.00),
(2,4,107,50.00),
(3,2,108,90.00),
(3,4,109,48.00),
(3,7,110,8.00);