USE [Medicine]

--1. Добавить внешние ключи
ALTER TABLE [production] 
ADD FOREIGN KEY (id_medicine) REFERENCES [medicine] (id_medicine);

ALTER TABLE [production]
ADD FOREIGN KEY (id_company) REFERENCES [company] (id_company);

ALTER TABLE [dealer] 
ADD FOREIGN KEY (id_company) REFERENCES [company] (id_company);

ALTER TABLE [order] 
ADD FOREIGN KEY (id_production) REFERENCES [production] (id_production);

ALTER TABLE [order] 
ADD FOREIGN KEY (id_dealer) REFERENCES [dealer] (id_dealer);

ALTER TABLE [order] 
ADD FOREIGN KEY (id_pharmacy) REFERENCES [pharmacy] (id_pharmacy);

--2. Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов
SELECT * FROM [order]
LEFT JOIN [pharmacy] ON [order].id_pharmacy = [pharmacy].id_pharmacy
LEFT JOIN [production] ON [order].id_production = [production].id_production
LEFT JOIN [company] ON [production].id_company = [company].id_company
LEFT JOIN [medicine] ON [production].id_medicine = [medicine].id_medicine
WHERE [medicine].name = 'Кордерон' AND [company].name = 'Аргус';

--3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января
SELECT DISTINCT [medicine].name FROM [medicine]
INNER JOIN [production] ON [medicine].id_medicine = [production].id_medicine
INNER JOIN [company] ON [company].id_company = [production].id_company
WHERE [company].name = 'Фарма' AND [production].id_production NOT IN (
	SELECT [order].id_production FROM [order]
	WHERE [order].date < '2019-01-25')
GROUP BY [medicine].id_medicine, [medicine].name;

--4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов
SELECT [company].name, MIN(rating) AS min_rate, MAX(rating) AS max_rate
FROM [production]
LEFT JOIN [order] ON [production].id_production = [order].id_production
LEFT JOIN [company] ON [production].id_company = [company].id_company
GROUP BY [production].id_company, [company].name
HAVING COUNT([order].id_order) >= 120;

--5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”. Если у дилера нет заказов, в названии аптеки проставить NULL
SELECT [pharmacy].name, [dealer].name, [dealer].id_dealer FROM [dealer]
LEFT JOIN [order] ON [dealer].id_dealer = [order].id_dealer
LEFT JOIN [pharmacy] ON [order].id_pharmacy = [pharmacy].id_pharmacy
LEFT JOIN [company] ON [dealer].id_company = [company].id_company
WHERE [company].name = 'AstraZeneca'
ORDER BY [dealer].id_dealer


--6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней
UPDATE [production]
SET [production].price = [production].price * 0.8
WHERE [production].id_medicine IN ( 
SELECT [production].id_medicine FROM [production]
LEFT JOIN [medicine] ON [production].id_medicine = [medicine].id_medicine
WHERE [medicine].cure_duration <= 7 AND [production].price > 3000);
SELECT * FROM [production];

--7. Добавить необходимые индексы
CREATE NONCLUSTERED INDEX [IX_dealer_id_company] ON [dbo].[dealer]
(
	[id_company] ASC
)

CREATE NONCLUSTERED INDEX [IX_production_id_company] ON [dbo].[production]
(
	[id_company] ASC
)

CREATE NONCLUSTERED INDEX [IX_production_id_medicine] ON [dbo].[production]
(
	[id_medicine] ASC
)

CREATE NONCLUSTERED INDEX [IX_production_rating] ON [dbo].[production]
(
	[rating] ASC
)

CREATE NONCLUSTERED INDEX [IX_company_name] ON [dbo].[company]
(	
	[name] ASC
)

CREATE NONCLUSTERED INDEX [IX_medicine_name] ON [dbo].[medicine]
(
	[name] ASC
)

CREATE NONCLUSTERED INDEX [IX_order_date] ON [dbo].[order]
(
	[date] ASC
)

CREATE NONCLUSTERED INDEX [IX_order_id_production] ON [dbo].[order]
(
	[id_production] ASC
)

CREATE NONCLUSTERED INDEX [IX_order_id_dealer] ON [dbo].[order]
(
	[id_dealer] ASC
)

CREATE NONCLUSTERED INDEX [IX_order_id_pharmacy] ON [dbo].[order]
(
	[id_pharmacy] ASC
)