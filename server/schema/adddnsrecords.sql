CREATE OR REPLACE FUNCTION AddDnsRecords(
	zonename varchar,
	records varchar[][],
	out record_id int
) RETURNS SETOF int AS $$
DECLARE
	record_label_id int;
	record_zone_id int;
BEGIN
	FOR i IN array_lower(records, 1) .. array_upper(records, 1) LOOP

		SELECT label.id INTO record_label_id FROM zone INNER JOIN label ON zone.id = zone_id WHERE name = zonename AND label = records[i][2];
		IF NOT FOUND THEN
			SELECT id INTO record_zone_id FROM zone WHERE name = zonename;
			IF NOT FOUND THEN
				RAISE EXCEPTION 'zone % not found', zonename;
			ELSE
				INSERT INTO label (zone_id, label) VALUES (record_zone_id, records[i][2]);
				record_label_id := currval('label_id_seq');
			END IF;
		END IF;

		IF records[i][1] IS NOT NULL AND records[i][1] != '' AND records[i][1] != '-1' THEN
			INSERT INTO record (id, label_id, ttl, class, type, rdata) VALUES (records[i][1]::int, record_label_id, 
					records[i][4]::int, records[i][3]::dnsclass,  records[i][5],  records[i][6]);
			record_id := records[i][1]::int;
			
		ELSE
			INSERT INTO record (label_id, ttl, class, type, rdata) VALUES (record_label_id, 
					records[i][4]::int, records[i][3]::dnsclass,  records[i][5],  records[i][6]);
			record_id := currval('record_id_seq');
		END IF;
		RETURN NEXT;
	END LOOP;
END; $$ LANGUAGE plpgsql;
