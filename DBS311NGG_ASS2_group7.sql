--1
CREATE OR REPLACE PROCEDURE find_customer(customer_id IN NUMBER, found OUT NUMBER) AS
BEGIN
    SELECT COUNT(*) INTO found FROM customers WHERE customer_id = find_customer.customer_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        found := 0;
    WHEN TOO_MANY_ROWS THEN
        -- Handle multiple rows found (if necessary)
        DBMS_OUTPUT.PUT_LINE('Multiple customers found with the same ID.');
    WHEN OTHERS THEN
        -- Handle any other errors
        DBMS_OUTPUT.PUT_LINE('Error occurred while finding customer.');
END find_customer;


--2

CREATE OR REPLACE PROCEDURE find_product(productId IN NUMBER, 
                                          price OUT products.list_price%TYPE,
                                          productName OUT products.product_name%TYPE,
                                          categoryName OUT product_categories.category_name%TYPE) AS
BEGIN
    SELECT p.product_name, 
           p.list_price,
           c.category_name
    INTO productName, price, categoryName
    FROM products p
    JOIN product_categories c ON p.category_id = c.category_id
    WHERE p.product_id = find_product.productId;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        price := 0;
    WHEN TOO_MANY_ROWS THEN
        -- Handle multiple rows found (if necessary)
        DBMS_OUTPUT.PUT_LINE('Multiple products found with the same ID.');
    WHEN OTHERS THEN
        -- Handle any other errors
        DBMS_OUTPUT.PUT_LINE('Error occurred while finding product.');
END find_product;


--3

CREATE OR REPLACE PROCEDURE add_order(customer_id IN NUMBER, new_order_id OUT NUMBER) AS
BEGIN
    -- Generate new order ID
    new_order_id := generate_order_id();
    
    -- Insert new order into orders table
    INSERT INTO orders (order_id, customer_id, status, salesman_id, order_date)
    VALUES (new_order_id, customer_id, 'Shipped', 56, SYSDATE);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Handle any errors
        DBMS_OUTPUT.PUT_LINE('Error occurred while adding order.');
END add_order;


--4

CREATE OR REPLACE FUNCTION generate_order_id RETURN NUMBER IS
    new_order_id NUMBER;
BEGIN
    SELECT MAX(order_id) + 1 INTO new_order_id FROM orders;
    RETURN new_order_id;
END generate_order_id;


--5

CREATE OR REPLACE PROCEDURE add_order_item(orderId IN order_items.order_id%TYPE,
                                           itemId IN order_items.item_id%TYPE, 
                                           productId IN order_items.product_id%TYPE, 
                                           quantity IN order_items.quantity%TYPE,
                                           price IN order_items.unit_price%TYPE) AS
BEGIN
    INSERT INTO order_items (order_id, item_id, product_id, quantity, unit_price)
    VALUES (orderId, itemId, productId, quantity, price);
END add_order_item;


--6

CREATE OR REPLACE PROCEDURE customer_order(customerId IN NUMBER, orderId IN OUT NUMBER) AS
BEGIN
    SELECT order_id INTO orderId FROM orders WHERE customer_id = customer_order.customerId AND order_id = customer_order.orderId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            orderId := 0;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error occurred while checking customer order.');
END customer_order;


--7

CREATE OR REPLACE PROCEDURE display_order_status(orderId IN NUMBER, status OUT orders.status%TYPE) AS
BEGIN
    -- Retrieve order status for the given order ID
    SELECT status INTO status
    FROM orders
    WHERE order_id = orderId;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case where order does not exist
        status := NULL;
    WHEN OTHERS THEN
        -- Handle any other errors
        DBMS_OUTPUT.PUT_LINE('Error occurred while retrieving order status.');
END display_order_status;


--8

CREATE OR REPLACE PROCEDURE cancel_order(orderId IN NUMBER, cancelStatus OUT NUMBER) AS
    orderStatus orders.status%TYPE;
BEGIN
    SELECT status INTO orderStatus FROM orders WHERE order_id = cancel_order.orderId;
    
    IF orderStatus IS NULL THEN
        cancelStatus := 0; -- Order does not exist
    ELSIF orderStatus = 'Canceled' THEN
        cancelStatus := 1; -- Order has been already canceled
    ELSIF orderStatus = 'Shipped' THEN
        cancelStatus := 2; -- Order is shipped and cannot be canceled
    ELSE
        UPDATE orders SET status = 'Canceled' WHERE order_id = cancel_order.orderId;
        cancelStatus := 3; -- Order is canceled successfully
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        cancelStatus := 0; -- Order does not exist
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred while canceling order.');
END cancel_order;
