USE Online_ticket_booking;


-- Queries (ticket_query.sql) --
-- 1 -- 
SELECT e.eventId, e.eventName, e.eventDescription, e.startDateTime, e.endDateTime, e.city, e.country, e.venue, t.ticketType, t.seatsTotal
FROM events e, ticketTypes t
WHERE e.eventName = 'Exeter Food Festival 2023'
AND e.eventId = t.eventId;

-- 2 --
SELECT e.eventId, e.eventName
FROM events e
WHERE (e.startDateTime >= '2023-07-01 00:00:00') AND (e.startDateTime <= '2023-07-10 23:59:59');

-- 3 --
-- Try to add Bronze but for another event
SELECT t.ticketType, (t.seatsTotal - COALESCE((
        SELECT COUNT(ticketId)
        FROM tickets
        WHERE ticketType = 'Bronze'
        GROUP BY ticketType
    ), 0)) AS availableSeats, t.basePrice
FROM ticketTypes t
WHERE t.ticketType = 'Bronze' AND t.eventId = (SELECT eventId FROM events WHERE events.eventName = 'Exmouth Music Festival 2023');

-- 4 -- 
SELECT c.fName, c.lName, COUNT(t.ticketId) AS 'Gold Tickets Booked'
FROM customers c
INNER JOIN bookingCreations bc ON c.customerId = bc.customerId
INNER JOIN tickets t ON bc.bookingId = t.bookingId
INNER JOIN ticketTypes tt ON t.ticketType = tt.ticketType AND t.eventId = tt.eventId
INNER JOIN events e ON t.eventId = e.eventId
WHERE tt.ticketType = 'Gold'
AND e.eventName = 'Exmouth Music Festival 2023'
GROUP BY c.customerId, c.fName, c.lName;

-- 5 --
SELECT e.eventName, COUNT(t.ticketId) AS TicketsSold
FROM events e
LEFT JOIN tickets t ON e.eventId = t.eventId
GROUP BY e.eventId, e.eventName
ORDER BY TicketsSold DESC;

-- 6 --   
SELECT 
bc.bookingId,
CONCAT(c.fName, ' ', c.lName) AS CustomerName,
b.bookingDate AS BookingTime,
e.eventName AS EventTitle,
CASE
	WHEN ed.deliveryId IS NOT NULL THEN 'email delivery'
	WHEN vp.deliveryId IS NOT NULL THEN 'venue pick up'
	ELSE 'Unknown'
END AS DeliveryOption,
tt.ticketType,
COUNT(t.ticketId) AS NumberOfTickets,
SUM(tt.basePrice) AS TotalPriceForTicketType,
(payment.TotalPayment IS NOT NULL) AS TotalPayment 
FROM 
    bookingCreations bc
LEFT JOIN customers c ON bc.customerId = c.customerId
LEFT JOIN bookings b ON bc.bookingId = b.referenceCode
LEFT JOIN tickets t ON b.referenceCode = t.bookingId
LEFT JOIN ticketTypes tt ON t.ticketType = tt.ticketType AND t.eventId = tt.eventId
LEFT JOIN events e ON t.eventId = e.eventId
LEFT JOIN ticketDeliveries td ON b.ticketDeliveryWay = td.deliveryId
LEFT JOIN emailDelivery ed ON td.deliveryId = ed.deliveryId
LEFT JOIN venuePickUp vp ON td.deliveryId = vp.deliveryId
LEFT JOIN (
    SELECT bookingId, SUM(totalAmountToPay) AS TotalPayment
    FROM payments
    GROUP BY bookingId
) AS payment ON b.referenceCode = payment.bookingId
WHERE 
    bc.bookingId = 101
GROUP BY 
    bc.bookingId, 
    CustomerName, 
    BookingTime, 
    EventTitle, 
    DeliveryOption, 
    tt.ticketType;

-- 7 --
-- To print out the number of tickets purchased, add this at the end of SELECT: COUNT(t.ticketId) AS 'Number of tickets purchased'
SELECT e.eventName, SUM(tt.basePrice) AS 'Total income'
FROM tickets t
LEFT JOIN ticketTypes tt ON t.ticketType = tt.ticketType AND t.eventId = tt.eventId
LEFT JOIN events e ON t.eventId = e.eventId
WHERE t.bookingId IS NOT NULL
GROUP BY t.eventId
HAVING SUM(tt.basePrice) = (
    SELECT MAX(sum_basePrice)
    FROM (
        SELECT SUM(tt1.basePrice) AS sum_basePrice
        FROM tickets t1
        LEFT JOIN ticketTypes tt1 ON t1.ticketType = tt1.ticketType AND t1.eventId = tt1.eventId
        WHERE t1.bookingId IS NOT NULL
        GROUP BY t1.eventId
    ) AS max_prices
);