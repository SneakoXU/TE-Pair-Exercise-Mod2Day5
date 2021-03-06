--PART 1
--Assumptions:
--      Pets can have multiple owners
--      Owners can have multiple pets
--      One pet/owner per visit
--      Hospital only has resources/knowledge to treat dogs, cats, birds, lizards, rabbits, and horses
--      Hospital has only 20 procedures to perform

BEGIN TRANSACTION;

DROP TABLE IF EXISTS visit;
DROP TABLE IF EXISTS pet_owner;
DROP TABLE IF EXISTS pet;
DROP TABLE IF EXISTS owner;

CREATE TABLE pet (
        pet_id serial NOT NULL,
        name varchar(64) NOT NULL,
        age int NOT NULL,
        type varchar(16) NOT NULL,
        CONSTRAINT pk_pet_id PRIMARY KEY (pet_id),
        CONSTRAINT ck_pet_type CHECK (type IN ('DOG', 'CAT', 'BIRD', 'LIZARD', 'HORSE', 'RABBIT')),
        CONSTRAINT ck_pet_age CHECK (age > 0)
);
CREATE TABLE owner (
        owner_id serial NOT NULL,
        first_name varchar(16) NOT NULL,
        last_name varchar(16) NOT NULL,
        CONSTRAINT pk_owner_id PRIMARY KEY (owner_id)
);
CREATE TABLE visit (
        visit_id serial NOT NULL,
        pet_id integer NOT NULL,
        owner_id integer NOT NULL,
        procedure varchar(32) NOT NULL,
        visit_date date NOT NULL,
        CONSTRAINT pk_visit_id PRIMARY KEY (visit_id),
        CONSTRAINT ck_visit_procedure CHECK (procedure IN ('01 - RABIES VACCINATION',
                                                           '02 - HEARTWORM TEST',
                                                           '03 - SPAY/NEUTER',
                                                           '04 - NAIL TRIMMING',
                                                           '05 - EAR INFECTION',
                                                           '06 - OPEN HEART SURGERY',
                                                           '07 - ALLERGY TEST',
                                                           '08 - TETANUS VACCINATION',
                                                           '09 - KIDNEY TEST',
                                                           '10 - EXAMINE and TREAT WOUND',
                                                           '11 - NUTRITION EVALUATION',
                                                           '12 - EYE WASH',
                                                           '13 - FLEA TREATMENT',
                                                           '14 - BROKEN BONE',
                                                           '15 - BITTEN BY CAT',
                                                           '16 - FEATHER MITE TREATMENT',
                                                           '17 - PROSTHESIS FITTING',
                                                           '18 - JUST WANTED TO SAY HI',
                                                           '19 - FUNERAL SERVICES',
                                                           '20 - ANNUAL CHECKUP'))
);
CREATE TABLE pet_owner (
        pet_id   integer NOT NULL,
        owner_id integer NOT NULL,
        CONSTRAINT pk_pet_owner PRIMARY KEY (pet_id, owner_id)
);

ALTER TABLE pet_owner ADD FOREIGN KEY (pet_id)   REFERENCES pet(pet_id);
ALTER TABLE pet_owner ADD FOREIGN KEY (owner_id) REFERENCES owner(owner_id);
ALTER TABLE visit ADD FOREIGN KEY (pet_id) REFERENCES pet(pet_id);
ALTER TABLE visit ADD FOREIGN KEY (owner_id) REFERENCES owner(owner_id);

COMMIT;

--TESTS

INSERT INTO pet (name, age, type) VALUES ('Ernest', 8, 'CAT');
INSERT INTO pet (name, age, type) VALUES ('Bert', 8, 'CAT');
INSERT INTO pet (name, age, type) VALUES ('Luna', 15, 'CAT');
--should fail
INSERT INTO pet (name, age, type) VALUES ('Betty', 8, 'CHICKEN');

INSERT INTO owner (first_name, last_name) VALUES ('Peter', 'Marchetti');

INSERT INTO pet_owner (pet_id, owner_id) VALUES (
       (SELECT pet_id FROM pet WHERE name = 'Luna'),
       (SELECT owner_id FROM owner WHERE first_name = 'Peter' AND last_name = 'Marchetti'));
INSERT INTO pet_owner (pet_id, owner_id) VALUES (
       (SELECT pet_id FROM pet WHERE name = 'Ernest'),
       (SELECT owner_id FROM owner WHERE first_name = 'Peter' AND last_name = 'Marchetti'));
INSERT INTO pet_owner (pet_id, owner_id) VALUES (
       (SELECT pet_id FROM pet WHERE name = 'Bert'),
       (SELECT owner_id FROM owner WHERE first_name = 'Peter' AND last_name = 'Marchetti'));
--should fail
INSERT INTO pet_owner (pet_id, owner_id) VALUES (
       (SELECT pet_id FROM pet WHERE name = 'Betty'),
       (SELECT owner_id FROM owner WHERE first_name = 'Peter' AND last_name = 'Marchetti'));

INSERT INTO visit (pet_id, owner_id, visit_date, procedure) VALUES (
       (SELECT pet_id FROM pet WHERE name = 'Luna'),
       (SELECT owner_id FROM owner WHERE first_name = 'Peter' AND last_name = 'Marchetti'),
        current_date,
        '05 - EAR INFECTION');

--PART 2
--Assumptions:
--      No longer assuming a procedure list, as in part 1
--      Invoices are not necessarily issued on the date of a given visit
--      Default tax rate is 8%, but it isn't set in stone.
--Notes:
--      Invoices keep separate track of totals/post-tax totals so that reports needing them (but not caring about
--      line items) can get away with only accessing one table.

BEGIN TRANSACTION;

DROP TABLE IF EXISTS visit;
DROP TABLE IF EXISTS invoice;
DROP TABLE IF EXISTS pet_owner;
DROP TABLE IF EXISTS pet;
DROP TABLE IF EXISTS invoice_item;
DROP TABLE IF EXISTS procedure;
DROP TABLE IF EXISTS owner;

CREATE TABLE pet (
        pet_id serial NOT NULL,
        name varchar(64) NOT NULL,
        age int NOT NULL,
        type varchar(16) NOT NULL,
        CONSTRAINT pk_pet_id PRIMARY KEY (pet_id),
        CONSTRAINT ck_pet_type CHECK (type IN ('DOG', 'CAT', 'BIRD', 'LIZARD', 'HORSE', 'RABBIT')),
        CONSTRAINT ck_pet_age CHECK (age > 0)
);
CREATE TABLE owner (
        owner_id serial NOT NULL,
        first_name varchar(16) NOT NULL,
        last_name varchar(16) NOT NULL,
        address varchar(32) NOT NULL,
        city varchar(32) NOT NULL,
        district varchar(2) NOT NULL,
        postal_code varchar(16) NOT NULL,
        CONSTRAINT pk_owner_id PRIMARY KEY (owner_id)
);
CREATE TABLE visit (
        visit_id serial NOT NULL,
        pet_id integer NOT NULL,
        owner_id integer NOT NULL,
        procedure_id int NOT NULL,
        visit_date date NOT NULL,
        CONSTRAINT pk_visit_id PRIMARY KEY (visit_id)
);
CREATE TABLE pet_owner (
        pet_id   integer NOT NULL,
        owner_id integer NOT NULL,
        CONSTRAINT pk_pet_owner PRIMARY KEY (pet_id, owner_id)
);

CREATE TABLE procedure (
        procedure_id serial NOT NULL,
        number int NOT NULL,
        procedure_name varchar(32) NOT NULL,
        CONSTRAINT pk_procedure PRIMARY KEY (procedure_id)
);

CREATE TABLE invoice (
        invoice_number serial NOT NULL,
        invoice_date date NOT NULL,
        total money NOT NULL,
        tax_rate int DEFAULT 8 NOT NULL,
        total_charge money NOT NULL,
        owner_id int,
        CONSTRAINT pk_invoice PRIMARY KEY (invoice_number)         
);

CREATE TABLE invoice_item (
        invoice_item_id serial NOT NULL,
        pet_id int NOT NULL,
        procedure_id int NOT NULL,
        amount money NOT NULL,
        CONSTRAINT pk_invoice_item PRIMARY KEY (invoice_item_id)
);                

ALTER TABLE pet_owner ADD FOREIGN KEY (pet_id)   REFERENCES pet(pet_id);
ALTER TABLE pet_owner ADD FOREIGN KEY (owner_id) REFERENCES owner(owner_id);
ALTER TABLE visit ADD FOREIGN KEY (pet_id) REFERENCES pet(pet_id);
ALTER TABLE visit ADD FOREIGN KEY (owner_id) REFERENCES owner(owner_id);
ALTER TABLE visit ADD FOREIGN KEY (procedure_id) REFERENCES procedure(procedure_id);
ALTER TABLE invoice ADD FOREIGN KEY (owner_id) REFERENCES owner(owner_id);
ALTER TABLE invoice_item ADD FOREIGN KEY (procedure_id) REFERENCES procedure(procedure_id);
ALTER TABLE invoice_item ADD FOREIGN KEY (pet_id) REFERENCES pet(pet_id);

COMMIT;
