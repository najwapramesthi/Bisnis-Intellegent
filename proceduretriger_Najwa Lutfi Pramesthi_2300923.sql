CREATE TABLE mahasiswa 
(id_mahasiswa INT PRIMARY KEY, nama_mahasiswa VARCHAR(100) NOT NULL);

CREATE TABLE matakuliah 
(id_matakuliah INT PRIMARY KEY, nama_matakuliah VARCHAR(100) NOT NULL);

CREATE TABLE nilai 
(id_nilai INT PRIMARY KEY AUTO_INCREMENT, id_mahasiswa INT, id_matakuliah INT, nilai INT, 
FOREIGN KEY (id_mahasiswa) REFERENCES Mahasiswa(id_mahasiswa), 
FOREIGN KEY (id_matakuliah) REFERENCES MataKuliah(id_matakuliah));


INSERT INTO mahasiswa (id_mahasiswa, nama_mahasiswa) VALUES 
(1, 'Budi'), (2, 'Siti'), (3, 'Agus');

INSERT INTO matakuliah (id_matakuliah, nama_matakuliah) VALUES 
(1, 'Matematika'), (2, 'Fisika'), (3, 'Kimia');

INSERT INTO nilai (id_mahasiswa, id_matakuliah, nilai) VALUES 
(1, 1, 85), (2, 1, 90), (3, 2, 78);

CREATE PROCEDURE tambah_nilai (
    IN p_id_mahasiswa INT,
    IN p_id_matakuliah INT,
    IN p_nilai INT
)
BEGIN
    INSERT INTO nilai (id_mahasiswa, id_matakuliah, nilai)
    VALUES (p_id_mahasiswa, p_id_matakuliah, p_nilai);
end;

CALL tambah_nilai(1, 2, 88);
SELECT * FROM nilai;

CREATE PROCEDURE update_nilai (
    IN p_id_mahasiswa INT,
    IN p_id_matakuliah INT,
    IN p_nilai INT
)
BEGIN
    UPDATE nilai
    SET nilai = p_nilai
    WHERE id_mahasiswa = p_id_mahasiswa
      AND id_matakuliah = p_id_matakuliah;
END
CALL update_nilai (2, 100, );
SELECT * FROM nilai;

CREATE PROCEDURE delete_nilai (
    IN p_id_nilai INT
)
BEGIN
    DELETE FROM nilai
    WHERE id_nilai = p_id_nilai;
END;
CALL delete_nilai(3);
SELECT * FROM nilai;

CREATE OR REPLACE FUNCTION hitung_rata_rata (p_id_mahasiswa INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE rata_rata DECIMAL(5,2);

    SELECT AVG(nilai)
    INTO rata_rata
    FROM nilai
    WHERE id_mahasiswa = p_id_mahasiswa;

    RETURN COALESCE(rata_rata, 0);
END //
SELECT hitung_rata_rata(1);

CREATE FUNCTION get_nama_matakuliah(
    p_id_matakuliah INT
) RETURNS VARCHAR(100)
DETERMINISTIC 
begin 
    DECLARE nama VARCHAR(100);
    SELECT nama_matakuliah INTO nama
    FROM matakuliah 
    WHERE id_matakuliah = p_id_matakuliah;
    RETURN COALESCE (nama, 'Tidak Diketahui');
end;
SELECT get_nama_matakuliah(2)

CREATE FUNCTION get_jumlah_mahasiswa()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM mahasiswa;
    RETURN total;
END //
SELECT get_jumlah_mahasiswa();


CREATE PROCEDURE cek_status_mahasiswa(
    IN p_id_mahasiswa INT,
    OUT p_status VARCHAR(50)
)
BEGIN 
    DECLARE p_nilai_rata DECIMAL(5,2);

    SELECT AVG(nilai) INTO p_nilai_rata 
    FROM nilai
    WHERE id_mahasiswa = p_id_mahasiswa;

    IF p_nilai_rata >= 85 THEN
        SET p_status = 'sangat baik';
    ELSEIF p_nilai_rata >= 70 THEN
        SET p_status = 'baik';
    ELSE 
        SET p_status = 'perlu perbaikan';
    END if;
END;

CREATE PROCEDURE kategori_mahasiswa(
    IN p_id_mahasiswa INT,
    OUT p_kategori VARCHAR(50)
)
BEGIN 
    DECLARE p_nilai_rata DECIMAL(5,2);

    SELECT AVG(nilai) INTO p_nilai_rata 
    FROM nilai
    WHERE id_mahasiswa = p_id_mahasiswa;

    SET p_kategori = CASE
        WHEN p_nilai_rata >= 85 THEN 'A'
        WHEN p_nilai_rata >= 70 THEN 'B'
        ELSE 'Perlu peningkatan'
    END;
END;

call kategori_mahasiswa(1, @kategori);
SELECT @kategori;

CREATE PROCEDURE hitung_total_nilai(
    IN p_id_mahasiswa INT,
    OUT p_total_nilai INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nilai INT;
    DECLARE cur CURSOR FOR
        SELECT nilai
        FROM nilai
        WHERE id_mahasiswa = p_id_mahasiswa;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET done = TRUE;

    SET p_total_nilai = 0;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO nilai;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET p_total_nilai = p_total_nilai + nilai;
    END LOOP;
    CLOSE cur;
END;

CALL hitung_total_nilai(3, @total_nilai);
SELECT @total_nilai;

SELECT * FROM mahasiswa;

CREATE TABLE log_nilai (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_mahasiswa INT,
    id_matakuliah INT,
    nilai INT,
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TRIGGER after_insert_nilai
AFTER INSERT ON nilai
FOR EACH ROW 
BEGIN
    INSERT INTO log_nilai (id_mahasiswa, id_matakuliah, nilai)
    VALUES (NEW.id_mahasiswa, NEW.id_matakuliah, NEW.nilai);
END;

INSERT INTO log_nilai (id_mahasiswa, id_matakuliah, nilai)
    VALUES (1, 1, 0);

SELECT * FROM log_nilai

SELECT * FROM nilai

CREATE TRIGGER before_insert_nilai
AFTER INSERT ON nilai
FOR EACH ROW 
BEGIN
    IF NEW.nilai < 0 OR NEW.nilai > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nilai harus berada direntang 0-100';
    END IF;
END;
SELECT * FROM nilai

SELECT * FROM log_nilai

ALTER TABLE mahasiswa ADD rata_rata DECIMAL(5, 2);

CREATE TRIGGER before_update_nilai
AFTER UPDATE ON nilai
FOR EACH ROW 
BEGIN
    DECLARE rata_rata DECIMAL(5,2);
    SELECT avg(nilai) INTO rata_rata
    FROM nilai
    WHERE id_mahasiswa = NEW.id_mahasiswa;

    UPDATE mahasiswa
    SET rata_rata = rata_rata
    WHERE id_mahasiswa = NEW.id_mahasiswa;
END;

UPDATE nilai SET nilai = 95 WHERE id_nilai = 9;
SELECT *FROM mahasiswa;
#Latihan Kondisional
DELIMITER //

CREATE PROCEDURE cek_kelulusan (
    IN p_id_mahasiswa INT,
    OUT p_status VARCHAR(50)
)
BEGIN
    DECLARE rata_rata DECIMAL(5,2);

    -- Hitung rata-rata nilai mahasiswa
    SELECT AVG(nilai)
    INTO rata_rata
    FROM nilai
    WHERE id_mahasiswa = p_id_mahasiswa;

    -- Kondisi kelulusan
    IF rata_rata >= 75 THEN
        SET p_status = 'Lulus';
    ELSE
        SET p_status = 'Tidak Lulus';
    END IF;
END //

DELIMITER ;
CALL cek_kelulusan(1, @status);
SELECT @status AS Status_Kelulusan;

#Latihan Looping
DELIMITER //

CREATE PROCEDURE total_nilai_semua_mahasiswa (
    OUT p_total_nilai INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nilai INT;

    DECLARE cur_nilai CURSOR FOR
        SELECT nilai FROM nilai;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET p_total_nilai = 0;

    OPEN cur_nilai;

    read_loop: LOOP
        FETCH cur_nilai INTO v_nilai;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET p_total_nilai = p_total_nilai + v_nilai;
    END LOOP;

    CLOSE cur_nilai;
END //

DELIMITER ;
CALL total_nilai_semua_mahasiswa(@total);
SELECT @total AS Total_Nilai_Semua_Mahasiswa;

#Latihan Error Handling
DELIMITER //

CREATE PROCEDURE cari_nama_matakuliah (
    IN p_id_matakuliah INT,
    OUT p_nama_matakuliah VARCHAR(100)
)
BEGIN
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET p_nama_matakuliah = 'Mata kuliah tidak ditemukan';

    SELECT nama_matakuliah
    INTO p_nama_matakuliah
    FROM matakuliah
    WHERE id_matakuliah = p_id_matakuliah;
END //

DELIMITER ;
CALL cari_nama_matakuliah(5, @nama_mk);
SELECT @nama_mk AS Nama_Mata_Kuliah;
# Trigger memblokir penghapusan data dari tabel nilai jika nilai < 50
DELIMITER $$

CREATE TRIGGER before_delete_nilai
BEFORE DELETE ON nilai
FOR EACH ROW
BEGIN
    IF OLD.nilai < 50 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data nilai di bawah 50 tidak boleh dihapus';
    END IF;
END$$

DELIMITER ;

# Trigger AFTER DELETE untuk mencatat data yang dihapus ke tabel log_nilai
SHOW TABLES;

DELIMITER $$

CREATE TRIGGER after_delete_nilai
AFTER DELETE ON nilai
FOR EACH ROW
BEGIN
    INSERT INTO log_nilai (id_mahasiswa, id_matakuliah, nilai)
    VALUES (OLD.id_mahasiswa, OLD.id_matakuliah, OLD.nilai);
END$$

DELIMITER ;

#Trigger BEFORE UPDATE untuk menambahkan kolom total_nilai di tabel mahasiswa
ALTER TABLE mahasiswa
ADD total_nilai INT;

DELIMITER $$

CREATE TRIGGER before_update_nilai_total
BEFORE UPDATE ON nilai
FOR EACH ROW
BEGIN
    DECLARE total INT;

    SELECT SUM(nilai)
    INTO total
    FROM nilai
    WHERE id_mahasiswa = NEW.id_mahasiswa;

    UPDATE mahasiswa
    SET total_nilai = total
    WHERE id_mahasiswa = NEW.id_mahasiswa;
END$$

DELIMITER ;