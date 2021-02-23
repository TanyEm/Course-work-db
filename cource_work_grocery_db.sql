
CREATE DATABASE grocery
--employee

CREATE SCHEMA employees_info
GO

CREATE TABLE employees_info.employee
(
    id INT NOT NULL PRIMARY KEY,
    first_name CHAR(20) NOT NULL,
    second_name CHAR(20) NOT NULL,
    position CHAR(20) NOT NULL,
    passport INT,
    address CHAR(80),
    phone_number CHAR(80)
) ON [PRIMARY]
GO

INSERT INTO grocery.employees_info.employee (id, first_name, second_name, position, passport, address, phone_number)
VALUES (1, 'Tatiana', 'Podlesnykh', 'Seller', 143341, 'Saint-Petersburg', '+7(911)123-45-67')

--category

CREATE SCHEMA product_category
GO

CREATE TABLE product_category.category
(
    id INT NOT NULL PRIMARY KEY,
    name CHAR(20) NOT NULL,
)
GO

INSERT INTO grocery.product_category.category (id, name)
VALUES (1, 'Fruit')
INSERT INTO grocery.product_category.category (id, name)
VALUES (2, 'Vegetables')

--products

CREATE SCHEMA products_info
GO

CREATE TABLE products_info.products_warehouse
(
    id INT NOT NULL PRIMARY KEY,
    product_name CHAR(70) NOT NULL,
    category_id INT
        CONSTRAINT products_warehouse_category_id_fk 
        REFERENCES product_category.category,
    price MONEY,
    dimension CHAR(500),
    quantity INT NOT NULL,
)
GO

INSERT INTO grocery.products_info.products_warehouse (id, product_name, category_id, price, dimension, quantity)
VALUES (1, 'Apple', 1, 65.00, 'kg', 20);
INSERT INTO grocery.products_info.products_warehouse (id, product_name, category_id, price, dimension, quantity)
VALUES (2, 'Tomato', 2, 37.00, 'kg', 40);

--------- supplies

CREATE SCHEMA suppliers_info
GO

CREATE TABLE suppliers_info.supplies
(
    id INT NOT NULL
    CONSTRAINT supplies_pk PRIMARY KEY NONCLUSTERED,
    provider CHAR(35) NOT NULL,
    date DATETIME NOT NULL,
    employ_id INT
    CONSTRAINT supplies_employees_id_fk REFERENCES employees_info.employee --кто принимает
)
GO

-----------------

INSERT INTO grocery.suppliers_info.supplies (id, provider, date, employ_id)
VALUES (1, 'Company 1', '2021-01-20 13:11:05.000', 1)
INSERT INTO grocery.suppliers_info.supplies (id, provider, date, employ_id)
VALUES (2, 'Company 1', '2021-01-15 13:20:00.000', 1)
INSERT INTO grocery.suppliers_info.supplies (id, provider, date, employ_id)
VALUES (3, 'Company 2', '2021-01-20 12:00:00.000', 1)

CREATE TABLE suppliers_info.supplied_grocery
(
    id INT NOT NULL 
        CONSTRAINT supplied_grocery_pk PRIMARY KEY NONCLUSTERED,
    product_id INT NOT NULL 
        CONSTRAINT supplied_grocery_products_warehouse_id_fk
        REFERENCES products_info.products_warehouse,
    amount INT NOT NULL,
    unit_price MONEY NOT NULL,
    supplied_id INT 
        CONSTRAINT supplied_grocery_supplies_id_fk 
        REFERENCES suppliers_info.supplies
)
GO

--add warehouse quantity
CREATE TRIGGER increment_warehouse_quantity
    ON grocery.suppliers_info.supplied_grocery
    FOR INSERT
    AS
    DECLARE
        @product_id INT,
        @amount INT
SET @product_id = (SELECT product_id
                       FROM inserted)
SET @amount = (SELECT amount
               FROM inserted)
BEGIN
    UPDATE grocery.products_info.products_warehouse
    SET quantity = (SELECT quantity FROM products_info.products_warehouse WHERE id = @product_id) +
                   @amount
    WHERE id = @product_id
END
GO

INSERT INTO grocery.suppliers_info.supplied_grocery (id, product_id, amount, unit_price, supplied_id)
VALUES (1, 1, 100, 35.00, 1)
INSERT INTO grocery.suppliers_info.supplied_grocery (id, product_id, amount, unit_price, supplied_id)
VALUES (2, 2, 50, 45.00, 2)

-------------

CREATE SCHEMA receipts
GO

CREATE TABLE receipts.receipt
(
    id INT NOT NULL PRIMARY KEY,
    invoice MONEY NOT NULL,
    data DATETIME NOT NULL,
    employ_id   INT
        CONSTRAINT orders_employees_id_fk 
        REFERENCES employees_info.employee,
    customer_id INT
)
GO

INSERT INTO grocery.receipts.receipt (id, invoice, data, employ_id, customer_id)
VALUES (1, 195.00, '2021-01-26 19:11:00.000', 1, 1);
INSERT INTO grocery.receipts.receipt (id, invoice, data, employ_id, customer_id)
VALUES (2, 320.00, '2021-01-27 13:19:00.000', 1, 2);
INSERT INTO grocery.receipts.receipt (id, invoice, data, employ_id, customer_id)
VALUES (3, 195.00, '2021-01-26 19:11:00.000', 1, 3);
INSERT INTO grocery.receipts.receipt (id, invoice, data, employ_id, customer_id)
VALUES (4, 320.00, '2021-01-27 13:19:00.000', 1, 4);

------------------------------
CREATE TABLE receipts.purchased_products
(
    id INT NOT NULL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL
        CONSTRAINT purchased_products_warehouse_id_fk
        REFERENCES products_info.products_warehouse,
    quantity INT NOT NULL,
    customer_id INT
)
GO

CREATE TRIGGER decrement_warehouse_quantity
    ON grocery.receipts.purchased_products
    FOR INSERT
    AS
    DECLARE
        @product_id INT,
        @quantity       INT
SET @product_id = (SELECT product_id
                       FROM inserted)
SET @quantity = (SELECT quantity
                 FROM inserted)
BEGIN
    UPDATE grocery.products_info.products_warehouse
    SET quantity = ((SELECT quantity FROM products_info.products_warehouse WHERE id = @product_id) -
                    @quantity)
    WHERE id = @product_id
END
GO

------------------------------


CREATE TABLE receipts.groceries_in_internet_order
(
    id INT NOT NULL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL
        CONSTRAINT groceries_in_internet_order_products_warehouse_id_fk
        REFERENCES products_info.products_warehouse,
    quantity INT NOT NULL,
    customer_id INT
)
GO

CREATE TRIGGER decrement_warehouse_quantity_by_internet
    ON grocery.receipts.groceries_in_internet_order
    FOR INSERT
    AS
    DECLARE
        @product_id INT,
        @quantity       INT
SET @product_id = (SELECT product_id
                       FROM inserted)
SET @quantity = (SELECT quantity
                 FROM inserted)
BEGIN
    UPDATE grocery.products_info.products_warehouse
    SET quantity = ((SELECT quantity FROM products_info.products_warehouse WHERE id = @product_id) -
                    @quantity)
    WHERE id = @product_id
END
GO

INSERT INTO grocery.receipts.groceries_in_internet_order (id, order_id, product_id, quantity, customer_id)
VALUES (1, 1, 2, 13, 1)
INSERT INTO grocery.receipts.groceries_in_internet_order (id, order_id, product_id, quantity, customer_id)
VALUES (2, 2, 1, 1,2)
INSERT INTO grocery.receipts.groceries_in_internet_order (id, order_id, product_id, quantity, customer_id)
VALUES (3, 3, 2, 30,3)
INSERT INTO grocery.receipts.groceries_in_internet_order (id, order_id, product_id, quantity, customer_id)
VALUES (4, 1, 2, 13,4)
INSERT INTO grocery.receipts.groceries_in_internet_order (id, order_id, product_id, quantity, customer_id)
VALUES (5, 2, 1, 1,5)
INSERT INTO grocery.receipts.groceries_in_internet_order (id, order_id, product_id, quantity, customer_id)
VALUES (6, 3, 2, 30, 6)

-------------
CREATE VIEW receipts.avarage_invoice AS
SELECT 
    ord.id, 
    ord.employ_id,
    AVG(ord.invoice) as avrg_invoice 
FROM (SELECT 
        receipts.receipt.id, 
        receipts.receipt.employ_id, 
        receipts.receipt.invoice
    FROM receipts.receipt 
    INNER JOIN receipts.groceries_in_internet_order ON receipt.id = receipts.groceries_in_internet_order.customer_id) AS ord
GROUP BY ord.id, ord.employ_id, ord.customer_id
GO

CREATE VIEW receipts.max_invoice AS
SELECT 
    ord.id, 
    ord.employ_id,
    ord.customer_id,
    MAX(ord.invoice) as max_invoice 
FROM (SELECT 
        receipts.receipt.id, 
        receipts.receipt.employ_id, 
        receipts.receipt.customer_id,
        receipts.receipt.invoice
    FROM receipts.receipt 
    INNER JOIN receipts.groceries_in_internet_order ON receipt.id = receipts.groceries_in_internet_order.customer_id) AS ord
GROUP BY ord.id, ord.employ_id, ord.customer_id
GO

CREATE PROCEDURE employees_info.employ_sale_per_month @employ_id int, @month_count int
AS
SELECT SUM(invoice)
FROM receipts.receipt
WHERE employ_id = @employ_id
  AND data >= dateadd(month, 0 - @month_count, getdate())
    RETURN;
------------------
--check view
SELECT * FROM receipts.max_invoice;

INSERT INTO grocery.receipts.receipt (id, invoice, data, employ_id, customer_id)
VALUES (9, 3020.00, GETDATE(), 1, 9);
INSERT INTO grocery.receipts.groceries_in_internet_order (id, order_id, product_id, quantity, customer_id)
VALUES (9, 4, 1, 4, 9)


SELECT * FROM receipts.max_invoice;

SELECT * FROM consumer_information.avarage_invoice;

INSERT INTO grocery.order_info.orders(id, consumer_id, invoice, employ_id)
VALUES (7, 1, 1, 1);
INSERT INTO grocery.order_info.grocerys_in_orders (id, order_id, product_id, quantity)
VALUES (13, 4, 2, 2);

SELECT * FROM consumer_information.avarage_invoice;

-- check increment products warehouse
SELECT quantity FROM products_info.products_warehouse WHERE id = 2;

INSERT INTO grocery.suppliers_info.supplies (id, provider, date, employ_id)
VALUES (9, 'Tomato OAO', GETDATE(), 1);
INSERT INTO grocery.suppliers_info.supplied_grocery (id, product_id, amount, unit_price, supplied_id)
VALUES (7, 2, 17, 45.00, 9);

SELECT quantity FROM products_info.products_warehouse WHERE id = 2;

-- check decrement products warehouse
SELECT quantity FROM products_info.products_warehouse WHERE id = 2;

INSERT INTO grocery.receipts.receipt (id, invoice, data, employ_id, customer_id)
VALUES (6, 1320.00, GETDATE(), 1, 5);
INSERT INTO grocery.receipts.purchased_products (id, order_id, product_id, quantity, customer_id)
VALUES (7, 3, 2, 2, 7)

SELECT quantity FROM products_info.products_warehouse WHERE id = 2;

-- increment
SELECT quantity FROM products_info.products_warehouse WHERE id = 2;

INSERT INTO grocery.suppliers_info.supplies (id, provider, date, employ_id)
VALUES (9, 'Tomato OAO', GETDATE(), 1);
INSERT INTO grocery.suppliers_info.supplied_grocery (id, product_id, amount, unit_price, supplied_id)
VALUES (7, 2, 17, 45.00, 9);

SELECT quantity FROM products_info.products_warehouse WHERE id = 2;

--с сайта decrement
SELECT quantity FROM products_info.products_warehouse WHERE id = 1;

INSERT INTO grocery.receipts.receipt (id, invoice, data, employ_id, customer_id)
VALUES (7, 1320.00, GETDATE(), 1, 6);
INSERT INTO grocery.receipts.groceries_in_internet_order (id, order_id, product_id, quantity, customer_id)
VALUES (7, 4, 1, 4, 7)