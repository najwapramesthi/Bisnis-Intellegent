SELECT s.student_name, d.dept_name
FROM students s
INNER JOIN departments d ON s.dept_id = d.dept_id;
SELECT c.class_id, cr.course_title, l.lect_name
FROM classes c
JOIN courses cr ON c.course_id = cr.course_id
JOIN lecturers l ON c.lect_id = l.lect_id;
SELECT s.student_name, cr.course_title
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN courses cr ON c.course_id = cr.course_id
JOIN students s ON e.student_id = s.student_id
WHERE cr.course_id = 1002;
SELECT cr.course_title, sc.day_of_week, sc.start_time, sc.end_time, r.room_name
FROM schedules sc
JOIN classes c ON sc.class_id = c.class_id
JOIN courses cr ON c.course_id = cr.course_id
JOIN rooms r ON sc.room_id = r.room_id;
SELECT d.dept_name, COUNT(DISTINCT e.student_id) AS jumlah_mahasiswa
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN students s ON e.student_id = s.student_id
JOIN departments d ON s.dept_id = d.dept_id
WHERE c.semester = '2025-1'
GROUP BY d.dept_name;
SELECT c.class_id, l.lect_name, cr.course_title
FROM classes c
JOIN lecturers l ON c.lect_id = l.lect_id
JOIN courses cr ON c.course_id = cr.course_id
WHERE l.dept_id = cr.dept_id;
SELECT DISTINCT s.student_name, cr.course_title, d2.dept_name AS course_dept
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN courses cr ON c.course_id = cr.course_id
JOIN students s ON e.student_id = s.student_id
JOIN departments d2 ON cr.dept_id = d2.dept_id
WHERE s.dept_id = 10 AND cr.dept_id <> 10;
SELECT c.course_title AS mata_kuliah, p.course_title AS prasyarat
FROM prerequisites pr
JOIN courses c ON pr.course_id = c.course_id
JOIN courses p ON pr.prereq_id = p.course_id;
SELECT l.lect_name AS dosen, s.lect_name AS pembina
FROM lecturer_supervisions ls
JOIN lecturers l ON ls.lect_id = l.lect_id
JOIN lecturers s ON ls.supervisor_id = s.lect_id;
SELECT DISTINCT c.class_id, cr.course_title
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN courses cr ON c.course_id = cr.course_id
WHERE e.grade IS NULL;
SELECT s.student_name
FROM students s
WHERE s.dept_id = (
  SELECT dept_id FROM courses WHERE course_id = 1006
)
AND s.student_id NOT IN (
  SELECT e.student_id
  FROM enrollments e
  JOIN classes c ON e.class_id = c.class_id
  WHERE c.course_id = 1006
);
SELECT sc.day_of_week,
       COUNT(DISTINCT sc.class_id) AS jumlah_kelas,
       SUM(r.capacity) AS total_kapasitas
FROM schedules sc
JOIN rooms r ON sc.room_id = r.room_id
GROUP BY sc.day_of_week;
SELECT s.student_name, SUM(cr.credits) AS total_sks
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN courses cr ON c.course_id = cr.course_id
JOIN students s ON e.student_id = s.student_id
GROUP BY s.student_name;
SELECT c.class_id, cr.course_title, l.lect_name,
       cr.dept_id AS course_dept, l.dept_id AS lecturer_dept
FROM classes c
JOIN courses cr ON c.course_id = cr.course_id
JOIN lecturers l ON c.lect_id = l.lect_id
WHERE cr.dept_id <> l.dept_id;
SELECT c.class_id, cr.course_title,
       COUNT(e.student_id) AS jumlah_peserta,
       r.capacity,
       CASE
           WHEN COUNT(e.student_id) >= r.capacity THEN 'PENUH'
           ELSE 'TERSEDIA'
       END AS status
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN schedules sc ON c.class_id = sc.class_id
JOIN rooms r ON sc.room_id = r.room_id
JOIN courses cr ON c.course_id = cr.course_id
GROUP BY c.class_id, cr.course_title, r.capacity;
SELECT s.student_name, cr.course_code, cr.course_title, c.semester, e.grade
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN courses cr ON c.course_id = cr.course_id
JOIN students s ON e.student_id = s.student_id
WHERE c.semester = '2025-1'
ORDER BY s.student_name, cr.course_code;
SELECT DISTINCT p.course_title AS mata_kuliah_prasyarat
FROM prerequisites pr
JOIN courses p ON pr.prereq_id = p.course_id;
SELECT s.lect_name AS dosen_pembina,
       COUNT(l.lect_id) AS jumlah_binaan
FROM lecturer_supervisions ls
JOIN lecturers l ON ls.lect_id = l.lect_id
JOIN lecturers s ON ls.supervisor_id = s.lect_id
GROUP BY s.lect_name;
SELECT s.student_name, cr.course_title, r.room_name, sc.day_of_week
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN schedules sc ON c.class_id = sc.class_id
JOIN rooms r ON sc.room_id = r.room_id
JOIN courses cr ON c.course_id = cr.course_id
JOIN students s ON e.student_id = s.student_id
WHERE sc.day_of_week = 'Monday';
SELECT DISTINCT s.student_name, cr.course_title
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN courses cr ON c.course_id = cr.course_id
JOIN students s ON e.student_id = s.student_id
WHERE s.dept_id <> cr.dept_id;
SELECT l.lect_name, c.class_id, cr.course_title
FROM lecturers l
LEFT JOIN classes c ON l.lect_id = c.lect_id
LEFT JOIN courses cr ON c.course_id = cr.course_id;
SELECT cr.course_title, c.class_id, c.semester
FROM courses cr
LEFT JOIN classes c ON cr.course_id = c.course_id
     AND c.semester = '2025-1';
SELECT c.course_title AS mata_kuliah, p.course_title AS prasyarat
FROM courses c
LEFT JOIN prerequisites pr ON c.course_id = pr.course_id
LEFT JOIN courses p ON pr.prereq_id = p.course_id;
SELECT DISTINCT s.student_name, l.lect_name AS dosen_pengajar, spv.lect_name AS dosen_pembina
FROM enrollments e
JOIN classes c ON e.class_id = c.class_id
JOIN lecturers l ON c.lect_id = l.lect_id
JOIN lecturer_supervisions ls ON l.lect_id = ls.lect_id
JOIN lecturers spv ON ls.supervisor_id = spv.lect_id
JOIN students s ON e.student_id = s.student_id;
SELECT a.schedule_id AS jadwal1, b.schedule_id AS jadwal2,
       a.day_of_week, a.room_id
FROM schedules a
JOIN schedules b
  ON a.room_id = b.room_id
 AND a.day_of_week = b.day_of_week
 AND a.schedule_id < b.schedule_id
 AND (a.start_time BETWEEN b.start_time AND b.end_time
      OR b.start_time BETWEEN a.start_time AND a.end_time);