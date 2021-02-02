
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