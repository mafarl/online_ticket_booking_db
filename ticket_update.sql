DROP TABLE IF EXISTS Online_ticket_booking;
USE Online_ticket_booking;


-- 1 --
UPDATE ticketTypes
SET seatsTotal = seatsTotal + 100
WHERE ticketType = 'Adult' AND eventId = (SELECT eventId FROM events WHERE events.eventName = 'Exeter Food Festival 2023');


-- 2 --
/* Inserting the initial data into the DB (customer, voucher)*/
INSERT INTO customers (fName,lName,email,phone,addressLine,city,postalCode,country) values
('Ian','Cooper','iancooper@icloud.com','+375292323244','vul.Peramogi 11','Mazyr','247760','Belarus');
INSERT INTO vouchers (code, discountAmount, voucherStatus, eventID) values
('FOOD10', 10.00, 'Applied', 1);

/* Creating a booking in the bookigns table and specifying the delivery way*/
INSERT INTO ticketDeliveries (deliveryStatus)
VALUES ('Pending');

-- Insert ticket info into bookings
INSERT INTO bookings (bookingDate, isSuccessful, eligibleForRefund, eventId, ticketDeliveryWay) values
(NOW(), 1, 0, (SELECT eventId FROM events WHERE eventName = 'Exeter Food Festival 2023'), (SELECT MAX(deliveryId) FROM ticketDeliveries));

-- Insert this ticket delivery id into email (delivery way selected)
INSERT INTO emailDelivery(deliveryId, emailAddress) values
((SELECT MAX(deliveryId) FROM ticketDeliveries), (SELECT email FROM customers WHERE fName = 'Ian' AND lName = 'Cooper' AND phone = '+375292323244'));

-- Insert booking creation details
INSERT INTO bookingCreations (customerId, eventId, bookingId, totalPrice)
VALUES (
    (SELECT customerId FROM customers WHERE fName = 'Ian' AND lName = 'Cooper' AND phone = '+375292323244'),
    (SELECT eventId FROM events WHERE eventName = 'Exeter Food Festival 2023'),
    (SELECT MAX(referenceCode) FROM bookings), -- Assuming auto-increment for bookingId
    (
        SELECT 
            (SUM(CASE WHEN ticketType = 'Adult' THEN basePrice ELSE 0 END) * 2) +
            (SUM(CASE WHEN ticketType = 'Child' THEN basePrice ELSE 0 END) * 1)
        FROM ticketTypes WHERE eventId = (SELECT eventId FROM events WHERE eventName = 'Exeter Food Festival 2023')
    ) * (1.00 - (SELECT discountAmount FROM vouchers WHERE code = 'FOOD10' AND eventId = 1)/100.00) -- Apply voucher discount (write the command rather than the number itself)
);
/* Update voucher status */
UPDATE vouchers SET voucherStatus = 'Applied' WHERE code = 'FOOD10';

-- Insert tickets for the booking
INSERT INTO tickets (ticketType, bookingId, eventId)
SELECT ticketType, (SELECT MAX(bookingId) FROM bookingCreations), (SELECT eventId FROM events WHERE eventName = 'Exeter Food Festival 2023')
FROM ticketTypes 
WHERE eventId = (SELECT eventId FROM events WHERE eventName = 'Exeter Food Festival 2023') AND ticketType IN ('Adult', 'Child');

INSERT INTO cards (cardNumber, cardType, securityCode, expiryDate, cardHolder) values
('4111111134111111', 'Visa', '587', '12/28', (SELECT customerId FROM customers WHERE fName = 'Ian' AND lName = 'Cooper' AND phone = '+375292323244'));

-- Insert payment details
INSERT INTO payments (totalAmountToPay, cardNumber, bookingId, voucherCode)
VALUES (
    (
        SELECT totalPrice
        FROM bookingCreations 
        WHERE eventId = (SELECT eventId FROM events WHERE eventName = 'Exeter Food Festival 2023') AND bookingId = (SELECT MAX(bookingId) FROM bookingCreations)
    ),
    4111111134111111,
    (SELECT MAX(bookingId) FROM bookingCreations),
    'FOOD10'
);


-- 3 --
-- Update bookings --
/* The booking ID given here is 108.
Also, all of the customers who booked tickets for this event get the update
*/
/* Delete the event from the events table, because of ON DELETE CASCADE rows with this eventId will be deleted from:
1) ticketTypes
2) tickets
3) vouchers
4) bookingCreations
In bookings: will state that cancelled + details of the refund (need to update that bookings are eligible for refund)
Delete the payment that belongs to the booking being refunded
Delete the ticket delivery rather than update the status (before: Update ticketDeliveries to state 'Cancelled')
 */
USE Online_ticket_booking;
DELETE FROM events WHERE eventId = (SELECT eventId FROM bookings WHERE referenceCode = 108);

/* Now update a specific booking requested to indicate the refund*/
UPDATE bookings SET isSuccessful = 1, eligibleForRefund = 0, refundDate = NOW(), refundReason = 'Cancelled'
WHERE referenceCode = 108;

-- Remove payments
DELETE FROM payments WHERE bookingId = 108;

-- Remove ticket deliveries
DELETE FROM ticketDeliveries WHERE deliveryId = (SELECT ticketDeliveryWay FROM bookings WHERE referenceCode = 108);


-- 4 -- 
-- Add one more voucher code for the Exmouth Music Festival 2023, the code is ‘SUMMER20’, with 20% off discount
INSERT INTO vouchers (code, discountAmount, eventId) values
('SUMMER20', 20.00, (SELECT eventId FROM events WHERE eventName = 'Exmouth Music Festival 2023'));