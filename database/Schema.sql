-- 1. Student Table
CREATE TABLE Student (
    reg_no VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    class VARCHAR(50) NOT NULL,
    dept VARCHAR(50) NOT NULL,
    year INT NOT NULL
) ENGINE=InnoDB;

-- 2. Mentor Table
CREATE TABLE Mentor (
    mentor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dept VARCHAR(50) NOT NULL,
    class VARCHAR(50) NOT NULL,
    year INT NOT NULL
) ENGINE=InnoDB;

-- 3. OD Form Table
CREATE TABLE OD_Form (
    app_id INT PRIMARY KEY AUTO_INCREMENT,
    reg_no VARCHAR(20) NOT NULL,
    purpose TEXT NOT NULL,
    type ENUM('internal', 'external') NOT NULL,
    system_needed BOOLEAN DEFAULT FALSE,
    bonafide_needed BOOLEAN DEFAULT FALSE,
    duration_hours INT,
    duration_days INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reg_no) REFERENCES Student(reg_no)
) ENGINE=InnoDB;

-- 4. Mentor Approval Table
CREATE TABLE Mentor_Approval (
    id INT PRIMARY KEY AUTO_INCREMENT,
    app_id INT NOT NULL,
    mentor_id INT NOT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    remarks TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (app_id) REFERENCES OD_Form(app_id) ON DELETE CASCADE,
    FOREIGN KEY (mentor_id) REFERENCES Mentor(mentor_id)
) ENGINE=InnoDB;

-- 5. HOD Approval Table
CREATE TABLE HOD_Approval (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reg_no VARCHAR(20) NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    class VARCHAR(50) NOT NULL,
    dept VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    app_id INT NOT NULL,
    purpose TEXT NOT NULL,
    type ENUM('internal', 'external') NOT NULL,
    system_needed BOOLEAN DEFAULT FALSE,
    bonafide_needed BOOLEAN DEFAULT FALSE,
    duration_hours INT,
    duration_days INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mentor_approvals TEXT NOT NULL,
    hod_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    hod_remarks TEXT,
    hod_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (app_id) REFERENCES OD_Form(app_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. Principal Approval Table
CREATE TABLE Principal_Approval (
    id INT PRIMARY KEY AUTO_INCREMENT,
    app_id INT NOT NULL,
    reg_no VARCHAR(20) NOT NULL,
    student_name VARCHAR(100) NOT NULL,  
    dept VARCHAR(50) NOT NULL,
    class VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    purpose TEXT NOT NULL,
    type ENUM('internal','external') NOT NULL,
    system_needed BOOLEAN,
    bonafide_needed BOOLEAN,
    duration_hours INT,
    duration_days INT,
    hod_status ENUM('pending','approved','rejected') DEFAULT 'pending',
    principal_status ENUM('pending','approved','rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (app_id) REFERENCES OD_Form(app_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES Student(reg_no)
) ENGINE=InnoDB;

-- 7. Technician Approval Table
CREATE TABLE Technician_Approval (
    tech_approval_id INT PRIMARY KEY AUTO_INCREMENT,
    app_id INT NOT NULL,
    reg_no VARCHAR(20) NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    dept VARCHAR(50) NOT NULL,
    class VARCHAR(50) NOT NULL,
    purpose TEXT NOT NULL,
    system_needed BOOLEAN,
    mentor_status ENUM('pending', 'approved', 'rejected') NOT NULL,
    hod_status ENUM('pending', 'approved', 'rejected') NOT NULL,
    technician_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    FOREIGN KEY (app_id) REFERENCES OD_Form(app_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8. CA/JA Dashboard View
CREATE VIEW CA_JA_Dashboard AS
SELECT 
    f.app_id,
    f.reg_no,
    s.name AS student_name,
    s.dept,
    s.class,
    s.year,
    f.purpose,
    f.type,
    f.system_needed,
    f.bonafide_needed,
    f.duration_hours,
    f.duration_days,
    m.status AS mentor_status,
    h.hod_status,
    p.principal_status
FROM OD_Form f
JOIN Student s ON f.reg_no = s.reg_no
LEFT JOIN Mentor_Approval m ON f.app_id = m.app_id
LEFT JOIN HOD_Approval h ON f.app_id = h.app_id
LEFT JOIN Principal_Approval p ON f.app_id = p.app_id;

-- 9. Student Dashboard View
CREATE VIEW Student_Dashboard AS
SELECT 
    o.app_id,
    o.reg_no,
    s.name AS student_name,
    s.year,
    s.dept,
    s.class,
    o.purpose,
    o.type,
    o.system_needed,
    o.bonafide_needed,
    m.status AS mentor_status,
    h.hod_status,
    p.principal_status,
    t.technician_status
FROM OD_Form o
JOIN Student s ON o.reg_no = s.reg_no
LEFT JOIN Mentor_Approval m ON o.app_id = m.app_id
LEFT JOIN HOD_Approval h ON o.app_id = h.app_id
LEFT JOIN Principal_Approval p ON o.app_id = p.app_id
LEFT JOIN Technician_Approval t ON o.app_id = t.app_id;
