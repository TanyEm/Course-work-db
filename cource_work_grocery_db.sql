
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