USE [Hotels];

-- 1. Добавить внешние ключи.
ALTER TABLE room 
ADD FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel);

ALTER TABLE room 
ADD FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category);

ALTER TABLE room_in_booking
ADD FOREIGN KEY (id_booking) REFERENCES booking (id_booking);

ALTER TABLE room_in_booking
ADD FOREIGN KEY (id_room) REFERENCES room (id_room);

ALTER TABLE booking
ADD FOREIGN KEY (id_client) REFERENCES client (id_client);

-- 2. Выдать информацию о клиентах гостиницы "Космос", проживающих в номерах категории "Люкс" на 1 апреля 2019г. 
SELECT client.id_client, client.name, client.phone FROM room_in_booking
LEFT JOIN room ON room_in_booking.id_room = room.id_room
LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
LEFT JOIN booking ON booking.id_booking = room_in_booking.id_booking
LEFT JOIN client ON client.id_client = booking.id_client
WHERE hotel.name = 'Космос' AND room_category.name = 'Люкс' AND 
	('2019-04-01' >= room_in_booking.checkin_date AND '2019-04-01' < room_in_booking.checkout_date);

-- 3. Дать список свободных номеров всех гостиниц на 22 апреля. 
SELECT * FROM room WHERE id_room NOT IN (
	SELECT room.id_room FROM room_in_booking 
	RIGHT JOIN room ON room.id_room = room_in_booking.id_room
	WHERE '2019-04-22' >= room_in_booking.checkin_date AND '2019-04-22' <= room_in_booking.checkout_date
)
ORDER BY id_room, id_hotel;

-- 4. Дать количество проживающих в гостинице "Космос" на 23 марта по каждой категории номеров	
SELECT COUNT(room_in_booking.id_room) AS residents, room_category.name FROM room_category
INNER JOIN room ON room_category.id_room_category = room.id_room_category
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_in_booking ON room.id_room = room_in_booking.id_room
WHERE hotel.name = 'Космос' AND 
	('2019-03-23' >= room_in_booking.checkin_date AND '2019-03-23' < room_in_booking.checkout_date)
GROUP BY room_category.name;

-- 5. Дать список последних проживавших клиентов по всем комнатам гостиницы "Космос", выехавшим в апреле с указанием даты выезда. 

SELECT client.name, room.id_room, room_in_booking.checkout_date
FROM room_in_booking
	LEFT JOIN room ON room.id_room = room_in_booking.id_room
	LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
	LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
	LEFT JOIN booking ON booking.id_booking = room_in_booking.id_booking
	LEFT JOIN client ON client.id_client = booking.id_client
	LEFT JOIN (SELECT room_in_booking.id_room, MAX(room_in_booking.checkout_date) AS last_date 
	FROM (SELECT * FROM room_in_booking WHERE checkout_date >='2019-04-01' AND checkout_date <= '2019-04-30') AS room_in_booking 
	GROUP BY room_in_booking.id_room) AS room_in_booking_2 ON room_in_booking_2.id_room =  room_in_booking.id_room
WHERE hotel.name = 'Космос' AND room_in_booking_2.last_date = room_in_booking.checkout_date
GROUP BY room.id_room, client.name, room_in_booking.checkout_date;

-- 6. Продлить на 2 дня дату проживания в гостинице "Космос" всем клиентам комнат категории "Бизнес", которые заселились 10 мая.
UPDATE room_in_booking
SET room_in_booking.checkout_date = DATEADD(day, 2, checkout_date)
FROM room
	INNER JOIN hotel ON room.id_hotel = hotel.id_hotel
	INNER JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE hotel.name = 'Космос' AND room_category.name = 'Бизнес' AND room_in_booking.checkin_date = '2019-05-10';
SELECT * FROM [room_in_booking]

--7. Найти все "пересекающиеся" варианты проживания.
SELECT *
FROM room_in_booking booking_1, room_in_booking booking_2
WHERE booking_1.id_room = booking_2.id_room AND booking_1.id_room_in_booking != booking_2.id_room_in_booking AND
	(booking_1.checkin_date <= booking_2.checkin_date AND booking_1.checkout_date > booking_2.checkin_date )
ORDER BY booking_1.id_room_in_booking;

-- 8. Создать бронирование в транзакции
BEGIN TRANSACTION
	INSERT INTO booking (id_client, booking_date) VALUES(7, '2022-03-17');  

	DECLARE @IdBooking INT;
	SELECT @IdBooking = id_booking FROM booking WHERE id_booking = SCOPE_IDENTITY();

	INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
	VALUES (@IdBooking, 7, '2022-03-17', '2022-05-20');
rollback;
SELECT * FROM [room_in_booking]
WHERE checkin_date = '2022-03-17'
SELECT * FROM [booking]
WHERE booking_date = '2022-03-17'

-- 9. Добавить необходимые индексы для всех таблиц
CREATE NONCLUSTERED INDEX [IX_room_id_booking_checkin_date-checkout_date] ON [dbo].[room_in_booking]
(
	[checkin_date] ASC,
	[checkout_date] ASC
)

CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_room-id_booking] ON [dbo].[room_in_booking]
(
	[id_room] ASC,
	[id_booking] ASC
)

CREATE NONCLUSTERED INDEX [IX_room_id_hotel-id_room_category] ON [dbo].[room]
(
	[id_hotel] ASC,
	[id_room_category] ASC
)

CREATE NONCLUSTERED INDEX [IX_booking_id_client] ON [dbo].[booking]
(
	[id_client] ASC
)

CREATE UNIQUE NONCLUSTERED INDEX [IX_client_phone] ON [dbo].[client]
(
	[phone] ASC
)

CREATE NONCLUSTERED INDEX [IX_hotel_name] ON [dbo].[hotel]
(
	[name] ASC
)

CREATE NONCLUSTERED INDEX [IX_room_category_name] ON [dbo].[room_category]
(
	[name] ASC
)
