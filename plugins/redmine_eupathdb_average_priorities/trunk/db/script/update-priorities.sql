/*
This is a script that is meant to be run one time only. The purpose of the script
is to set individual PI values to the value of PIs, for any issues with a value
for PIs. Since the valid values for inividual PI priorities are limited to
numbers in increments of 0.5, we first have to map the values of PIs to such a
values.

We will be updating the table custom_values:

mysql> desc custom_fields;
+-----------------+--------------+------+-----+---------+----------------+
| Field           | Type         | Null | Key | Default | Extra          |
+-----------------+--------------+------+-----+---------+----------------+
| id              | int(11)      | NO   | PRI | NULL    | auto_increment | 
| type            | varchar(30)  | NO   |     |         |                | 
| name            | varchar(30)  | NO   |     |         |                | 
| field_format    | varchar(30)  | NO   |     |         |                | 
| possible_values | text         | YES  |     | NULL    |                | 
| regexp          | varchar(255) | YES  |     |         |                | 
| min_length      | int(11)      | NO   |     | 0       |                | 
| max_length      | int(11)      | NO   |     | 0       |                | 
| is_required     | tinyint(1)   | NO   |     | 0       |                | 
| is_for_all      | tinyint(1)   | NO   |     | 0       |                | 
| is_filter       | tinyint(1)   | NO   |     | 0       |                | 
| position        | int(11)      | YES  |     | 1       |                | 
| searchable      | tinyint(1)   | YES  |     | 0       |                | 
| default_value   | text         | YES  |     | NULL    |                | 
| editable        | tinyint(1)   | YES  |     | 1       |                | 
| visible         | tinyint(1)   | NO   |     | 1       |                | 
| multiple        | tinyint(1)   | YES  |     | 0       |                | 
+-----------------+--------------+------+-----+---------+----------------+
17 rows in set (0.01 sec)

mysql> desc custom_values;
+-----------------+-------------+------+-----+---------+----------------+
| Field           | Type        | Null | Key | Default | Extra          |
+-----------------+-------------+------+-----+---------+----------------+
| id              | int(11)     | NO   | PRI | NULL    | auto_increment | 
| customized_type | varchar(30) | NO   | MUL |         |                | 
| customized_id   | int(11)     | NO   |     | 0       |                | 
| custom_field_id | int(11)     | NO   | MUL | 0       |                | 
| value           | text        | YES  |     | NULL    |                | 
+-----------------+-------------+------+-----+---------+----------------+
5 rows in set (0.00 sec)



STEP 1: Update PIs values based on mapping
STEP 2: Set individual PI values to that of PIs
*/

/*
    UPDATE PIs field according to mapping:
    1   -> 1.0
    1.2 -> 1.0
    1.3 -> 1.0

    1.5 -> 1.5
    1.7 -> 1.5
    1.8 -> 1.5

    2   -> 2.0
    2.3 -> 2.0

    2.5 -> 2.5
    2.7 -> 2.5
    2.8 -> 2.5

    3   -> 3.0

    3.3 -> 3.5
    3.5 -> 3.5

    3.7 -> 4.0
    3.8 -> 4.0
    4   -> 4.0

    4.x -> 4.5

    TRANSLATION
    IF(v > 1.3,
        IF(v > 1.8,
            IF(v > 2.3,
                IF(v > 2.8,
                    IF(v > 3,
                        IF(v > 3.5,
                            IF(v > 4,
                                4.5,
                            4.0),
                        3.5),
                    3.0),
                2.5),
            2.0),
        1.5),
    1.0)

*/

/* For each issue, I want the priorities
SELECT * FROM
(
    SELECT cv.customized_id as Issue,
    jk.value as JK,
    cs.value as CS,
    dr.value as DR,
    pis.value as PIs
    FROM custom_values cv, custom_fields cf,
    (
        SELECT value, customized_id from custom_values, custom_fields
        WHERE custom_values.custom_field_id = custom_fields.id
        AND customized_type = "Issue"
        AND custom_fields.name = "JK"
    ) jk,
    (
        SELECT value, customized_id from custom_values, custom_fields
        WHERE custom_values.custom_field_id = custom_fields.id
        AND customized_type = "Issue"
        AND custom_fields.name = "CS"
    ) cs,
    (
        SELECT value, customized_id from custom_values, custom_fields
        WHERE custom_values.custom_field_id = custom_fields.id
        AND customized_type = "Issue"
        AND custom_fields.name = "DR"
    ) dr,
    (
        SELECT value, customized_id from custom_values, custom_fields
        WHERE custom_values.custom_field_id = custom_fields.id
        AND customized_type = "Issue"
        AND custom_fields.name = "PIs"
    ) pis
    WHERE cv.custom_field_id = cf.id
    AND jk.customized_id = cv.customized_id
    AND cs.customized_id = cv.customized_id
    AND dr.customized_id = cv.customized_id
    AND pis.customized_id = cv.customized_id
    AND pis.value <> ''
    AND cf.name in ("JK", "CS", "DR", "PIs")
    GROUP BY Issue
    ORDER BY PIs
) p
;
*/

/* STEP 1 */
UPDATE custom_values
SET value = IF(value > 1.3,
    IF(value > 1.8,
        IF(value > 2.3,
            IF(value > 2.8,
                IF(value > 3,
                    IF(value > 3.5,
                        IF(value > 4,
                            4.5,
                        4.0),
                    3.5),
                3.0),
            2.5),
        2.0),
    1.5),
1.0)
WHERE custom_field_id = (
    SELECT id FROM custom_fields
    WHERE name = "PIs"
    AND type = "IssueCustomField"
)
AND value <> '';

/* STEP 2 */

UPDATE custom_values cv, custom_values pis
SET cv.value = pis.value
WHERE cv.customized_id = pis.customized_id
AND cv.custom_field_id IN (
    SELECT id FROM custom_fields
    WHERE name IN ("JK", "CS", "DR")
    AND type = "IssueCustomField"
)
AND pis.custom_field_id = (
    SELECT id FROM custom_fields
    WHERE name = "PIs"
    AND type = "IssueCustomField"
)
AND pis.value <> '';
