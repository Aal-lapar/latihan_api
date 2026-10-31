const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

const port = 3000;

const db = require('./config/database');

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = 'mundurgaks';

// ==================================================
// MIDDLEWARE VERIFY TOKEN
// ==================================================

function verifyToken(req, res, next) {
    console.log('VERIFY TOKEN:', req.method, req.originalUrl);

    const authHeader = req.headers.authorization;

    if (!authHeader) {
        console.log('TOKEN TIDAK ADA');

        return res.status(401).json({
            status: false,
            message: 'Token tidak ditemukan'
        });
    }

    const parts = authHeader.trim().split(/\s+/);

    if (
        parts.length !== 2 ||
        parts[0] !== 'Bearer' ||
        !parts[1]
    ) {
        console.log('FORMAT TOKEN SALAH');

        return res.status(401).json({
            status: false,
            message: 'Format token tidak valid'
        });
    }

    const token = parts[1];

    try {
        const decoded = jwt.verify(token, JWT_SECRET);

        console.log('TOKEN VALID:', decoded);

        req.user = decoded;

        next();

    } catch (error) {
        console.log('JWT ERROR:', error.message);

        return res.status(401).json({
            status: false,
            message: 'Token tidak valid atau sudah expired'
        });
    }
}

// ======================================================
// VALIDASI EMAIL
// ======================================================

const EMAIL_REGEX =
    /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

function isValidEmail(email) {
    return EMAIL_REGEX.test(email);
}

// ======================================================
// PRODUCT
// ======================================================

// GET SEMUA PRODUCT
app.get('/product', verifyToken, async (req, res) => {
    try {
        const sql = 'SELECT * FROM products';

        const [rows] = await db.promise().query(sql);

        res.status(200).json(rows);

    } catch (error) {
        console.error('Error retrieving products:', error);

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan'
        });
    }
});

// ======================================================
// GET PRODUCT BERDASARKAN ID
// ======================================================

app.get('/product/:id', verifyToken, async (req, res) => {
    const productsId = req.params.id;

    try {
        const sql = 'SELECT * FROM products WHERE id = ?';

        const [rows] = await db.promise().query(
            sql,
            [productsId]
        );

        if (rows.length === 0) {
            return res.status(404).json({
                status: false,
                message: 'Product tidak ditemukan'
            });
        }

        res.status(200).json(rows[0]);

    } catch (error) {
        console.error(error);

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan'
        });
    }
});

// ======================================================
// POST PRODUCT
// ======================================================

app.post('/product/post', verifyToken, async (req, res) => {
    const {
        nama,
        harga,
        stok,
        kategori
    } = req.body;

    // VALIDASI NAMA
    if (!nama || nama.trim() === '') {
        return res.status(400).json({
            status: false,
            message: 'Nama tidak boleh kosong'
        });
    }

    // VALIDASI HARGA
    if (
        harga === undefined ||
        harga === null ||
        harga === '' ||
        isNaN(harga) ||
        Number(harga) <= 0
    ) {
        return res.status(400).json({
            status: false,
            message: 'Harga harus berupa angka dan lebih dari 0'
        });
    }

    // VALIDASI STOK
    if (
        stok === undefined ||
        stok === null ||
        stok === '' ||
        isNaN(stok) ||
        Number(stok) < 0
    ) {
        return res.status(400).json({
            status: false,
            message: 'Stok harus berupa angka dan tidak boleh negatif'
        });
    }

    // VALIDASI KATEGORI
    if (!kategori || kategori.trim() === '') {
        return res.status(400).json({
            status: false,
            message: 'Kategori tidak boleh kosong'
        });
    }

    try {
        const sql = `
            INSERT INTO products
            (nama, harga, stok, kategori)
            VALUES (?, ?, ?, ?)
        `;

        const values = [
            nama.trim(),
            Number(harga),
            Number(stok),
            kategori.trim()
        ];

        const [result] = await db.promise().query(sql, values);

        res.status(201).json({
            status: true,
            message: 'Data berhasil ditambahkan',
            data: {
                id: result.insertId,
                nama: nama.trim(),
                harga: Number(harga),
                stok: Number(stok),
                kategori: kategori.trim()
            }
        });

    } catch (error) {
        console.error('Gagal insert:', error);

        res.status(500).json({
            status: false,
            message: 'Gagal menyimpan data',
            error: error.message
        });
    }
});

// ======================================================
// PUT PRODUCT
// ======================================================

app.put('/product/put/:id', verifyToken, async (req, res) => {
    const productsId = req.params.id;

    const {
        nama,
        harga,
        stok,
        kategori
    } = req.body;

    // VALIDASI NAMA
    if (!nama || nama.trim() === '') {
        return res.status(400).json({
            status: false,
            message: 'Nama tidak boleh kosong'
        });
    }

    // VALIDASI HARGA
    if (
        harga === undefined ||
        harga === null ||
        harga === '' ||
        isNaN(harga) ||
        Number(harga) <= 0
    ) {
        return res.status(400).json({
            status: false,
            message: 'Harga harus berupa angka dan lebih dari 0'
        });
    }

    // VALIDASI STOK
    if (
        stok === undefined ||
        stok === null ||
        stok === '' ||
        isNaN(stok) ||
        Number(stok) < 0
    ) {
        return res.status(400).json({
            status: false,
            message: 'Stok harus berupa angka dan tidak boleh negatif'
        });
    }

    // VALIDASI KATEGORI
    if (!kategori || kategori.trim() === '') {
        return res.status(400).json({
            status: false,
            message: 'Kategori tidak boleh kosong'
        });
    }

    try {
        const sql = `
            UPDATE products
            SET
                nama = ?,
                harga = ?,
                stok = ?,
                kategori = ?
            WHERE id = ?
        `;

        const values = [
            nama.trim(),
            Number(harga),
            Number(stok),
            kategori.trim(),
            productsId
        ];

        const [result] = await db.promise().query(sql, values);

        if (result.affectedRows === 0) {
            return res.status(404).json({
                status: false,
                message: 'Product tidak ditemukan'
            });
        }

        res.status(200).json({
            status: true,
            message: 'Data berhasil diupdate'
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan'
        });
    }
});

// ======================================================
// DELETE PRODUCT
// ======================================================

app.delete('/product/delete/:id', verifyToken, async (req, res) => {
    const productsId = req.params.id;

    try {
        const sql = 'DELETE FROM products WHERE id = ?';

        const [result] = await db.promise().query(
            sql,
            [productsId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                status: false,
                message: 'Product tidak ditemukan'
            });
        }

        res.status(200).json({
            status: true,
            message: 'Data berhasil dihapus'
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan'
        });
    }
});


// ======================================================
// SISWA CRUD
// ======================================================

// GET SEMUA SISWA
app.get('/siswa', verifyToken, async (req, res) => {
    try {
        const sql = 'SELECT * FROM siswa ORDER BY id DESC';
        const [rows] = await db.promise().query(sql);

        res.status(200).json({
            status: true,
            message: 'Data siswa berhasil diambil',
            data: rows
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan pada server'
        });
    }
});


// GET SISWA BERDASARKAN ID
app.get('/siswa/:id', verifyToken, async (req, res) => {
    try {
        const sql = 'SELECT * FROM siswa WHERE id = ?';
        const [rows] = await db.promise().query(sql, [req.params.id]);

        if (rows.length === 0) {
            return res.status(404).json({
                status: false,
                message: 'Siswa tidak ditemukan'
            });
        }

        res.status(200).json({
            status: true,
            message: 'Data siswa berhasil diambil',
            data: rows[0]
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan pada server'
        });
    }
});


// POST TAMBAH SISWA
app.post('/siswa', verifyToken, async (req, res) => {
    const { nipd, nama, jenis_kelamin, kelas, jurusan, alamat } = req.body;

    if (!nipd || !nama || !jenis_kelamin || !kelas || !jurusan || !alamat) {
        return res.status(400).json({
            status: false,
            message: 'Semua data siswa wajib diisi'
        });
    }

    try {
        const sql = `
            INSERT INTO siswa (nipd, nama, jenis_kelamin, kelas, jurusan, alamat)
            VALUES (?, ?, ?, ?, ?, ?)
        `;

        const [result] = await db.promise().query(sql, [
            nipd.trim(),
            nama.trim(),
            jenis_kelamin.trim(),
            kelas.trim(),
            jurusan.trim(),
            alamat.trim()
        ]);

        res.status(201).json({
            status: true,
            message: 'Data siswa berhasil ditambahkan',
            data: {
                id: result.insertId,
                nipd,
                nama,
                jenis_kelamin,
                kelas,
                jurusan,
                alamat
            }
        });
    } catch (error) {
        console.error(error);

        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                status: false,
                message: 'NIPD sudah digunakan'
            });
        }

        res.status(500).json({
            status: false,
            message: 'Gagal menambahkan data siswa'
        });
    }
});

// PUT UPDATE SISWA
app.put('/siswa/:id', verifyToken, async (req, res) => {
    const { nipd, nama, jenis_kelamin, kelas, jurusan, alamat } = req.body;

    if (!nipd || !nama || !jenis_kelamin || !kelas || !jurusan || !alamat) {
        return res.status(400).json({
            status: false,
            message: 'Semua data siswa wajib diisi'
        });
    }

    try {
        const sql = `
            UPDATE siswa
            SET nipd = ?, nama = ?, jenis_kelamin = ?, kelas = ?, jurusan = ?, alamat = ?
            WHERE id = ?
        `;

        const [result] = await db.promise().query(sql, [
            nipd.trim(),
            nama.trim(),
            jenis_kelamin.trim(),
            kelas.trim(),
            jurusan.trim(),
            alamat.trim(),
            req.params.id
        ]);

        if (result.affectedRows === 0) {
            return res.status(404).json({
                status: false,
                message: 'Siswa tidak ditemukan'
            });
        }

        res.status(200).json({
            status: true,
            message: 'Data siswa berhasil diupdate'
        });
    } catch (error) {
        console.error(error);

        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                status: false,
                message: 'NIPD sudah digunakan siswa lain'
            });
        }

        res.status(500).json({
            status: false,
            message: 'Gagal mengupdate data siswa'
        });
    }
});


// DELETE SISWA
app.delete('/siswa/:id', verifyToken, async (req, res) => {
    try {
        const sql = 'DELETE FROM siswa WHERE id = ?';

        const [result] = await db.promise().query(sql, [req.params.id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({
                status: false,
                message: 'Siswa tidak ditemukan'
            });
        }

        res.status(200).json({
            status: true,
            message: 'Data siswa berhasil dihapus'
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({
            status: false,
            message: 'Gagal menghapus data siswa'
        });
    }
});


// ======================================================
// USER CRUD
// ======================================================

// ======================================================
// CREATE USER
// ======================================================

app.post('/user', verifyToken, async (req, res) => {
    const {
        nama,
        email,
        password,
        status
    } = req.body;

    // VALIDASI NAMA
    if (
        !nama ||
        !/^[a-zA-Z\s]+$/.test(nama.trim())
    ) {
        return res.status(400).json({
            status: false,
            message: 'Nama wajib diisi dan hanya boleh menggunakan huruf'
        });
    }

    // VALIDASI EMAIL
    if (!email || !isValidEmail(email.trim())) {
        return res.status(400).json({
            status: false,
            message: 'Email tidak valid. Contoh: nama@gmail.com'
        });
    }

    // VALIDASI PASSWORD
    if (!password || password.length < 6) {
        return res.status(400).json({
            status: false,
            message: 'Password wajib diisi minimal 6 karakter'
        });
    }

    // VALIDASI STATUS
    const userStatus = status || 'Aktif';

    if (
        userStatus !== 'Aktif' &&
        userStatus !== 'Nonaktif'
    ) {
        return res.status(400).json({
            status: false,
            message: 'Status harus Aktif atau Nonaktif'
        });
    }

    try {
        // CEK EMAIL DUPLIKAT
        const checkSql = `
            SELECT id
            FROM users
            WHERE email = ?
        `;

        const [existingUser] = await db.promise().query(
            checkSql,
            [email.trim()]
        );

        if (existingUser.length > 0) {
            return res.status(409).json({
                status: false,
                message: 'Email sudah digunakan'
            });
        }

        // HASH PASSWORD
        const hashedPassword = await bcrypt.hash(password, 10);

        // INSERT USER
        const sql = `
            INSERT INTO users
            (
                nama,
                email,
                password,
                status
            )
            VALUES (?, ?, ?, ?)
        `;

        const [result] = await db.promise().query(
            sql,
            [
                nama.trim(),
                email.trim(),
                hashedPassword,
                userStatus
            ]
        );

        res.status(201).json({
            status: true,
            message: 'User berhasil ditambahkan',
            data: {
                id: result.insertId,
                nama: nama.trim(),
                email: email.trim(),
                status: userStatus
            }
        });

    } catch (error) {
        console.error(error);

        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                status: false,
                message: 'Email sudah digunakan'
            });
        }

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan pada server'
        });
    }
});

// ======================================================
// GET STATISTIK USER (AKTIF & NONAKTIF)
// ======================================================

app.get('/users/stats', verifyToken, async (req, res) => {
    try {
        const sql = `
            SELECT
                COUNT(*) AS total,
                SUM(CASE WHEN status = 'Aktif' THEN 1 ELSE 0 END) AS aktif,
                SUM(CASE WHEN status = 'Nonaktif' THEN 1 ELSE 0 END) AS nonaktif
            FROM users
        `;

        const [rows] = await db.promise().query(sql);

        res.status(200).json({
            status: true,
            message: 'Statistik user berhasil diambil',
            data: {
                total: Number(rows[0].total) || 0,
                aktif: Number(rows[0].aktif) || 0,
                nonaktif: Number(rows[0].nonaktif) || 0
            }
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan pada server'
        });
    }
});

// ======================================================
// GET SEMUA USER
// ======================================================

app.get('/getuser', verifyToken, async (req, res) => {
    try {
        const sql = `
            SELECT
                id,
                nama,
                email,
                status
            FROM users
            ORDER BY id DESC
        `;

        const [rows] = await db.promise().query(sql);

        res.status(200).json({
            status: true,
            message: 'Data user berhasil diambil',
            data: rows
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan pada server'
        });
    }
});

// ======================================================
// GET USER BERDASARKAN ID
// ======================================================

app.get('/user/:id', verifyToken, async (req, res) => {
    const userId = req.params.id;

    try {
        const sql = `
            SELECT
                id,
                nama,
                email,
                status
            FROM users
            WHERE id = ?
        `;

        const [rows] = await db.promise().query(
            sql,
            [userId]
        );

        if (rows.length === 0) {
            return res.status(404).json({
                status: false,
                message: 'User tidak ditemukan'
            });
        }

        res.status(200).json({
            status: true,
            message: 'Data user berhasil diambil',
            data: rows[0]
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan pada server'
        });
    }
});

// ======================================================
// UPDATE USER
// ======================================================

app.put('/user/:id', verifyToken, async (req, res) => {
    const userId = req.params.id;

    const {
        nama,
        email,
        password,
        status
    } = req.body;

    // VALIDASI NAMA
    if (
        !nama ||
        !/^[a-zA-Z\s]+$/.test(nama.trim())
    ) {
        return res.status(400).json({
            status: false,
            message: 'Nama wajib diisi dan hanya boleh menggunakan huruf'
        });
    }

    // VALIDASI EMAIL
    if (!email || !isValidEmail(email.trim())) {
        return res.status(400).json({
            status: false,
            message: 'Email tidak valid. Contoh: nama@gmail.com'
        });
    }

    // VALIDASI PASSWORD
    // Hanya dicek kalau password diisi
    if (password && password.length < 6) {
        return res.status(400).json({
            status: false,
            message: 'Password minimal 6 karakter'
        });
    }

    // VALIDASI STATUS
    const userStatus = status || 'Aktif';

    if (
        userStatus !== 'Aktif' &&
        userStatus !== 'Nonaktif'
    ) {
        return res.status(400).json({
            status: false,
            message: 'Status harus Aktif atau Nonaktif'
        });
    }

    try {
        // CEK USER
        const userSql = `
            SELECT id
            FROM users
            WHERE id = ?
        `;

        const [userRows] = await db.promise().query(
            userSql,
            [userId]
        );

        if (userRows.length === 0) {
            return res.status(404).json({
                status: false,
                message: 'User tidak ditemukan'
            });
        }

        // CEK EMAIL DUPLIKAT
        const emailSql = `
            SELECT id
            FROM users
            WHERE email = ?
            AND id != ?
        `;

        const [emailRows] = await db.promise().query(
            emailSql,
            [
                email.trim(),
                userId
            ]
        );

        if (emailRows.length > 0) {
            return res.status(409).json({
                status: false,
                message: 'Email sudah digunakan oleh user lain'
            });
        }

        // UPDATE DENGAN PASSWORD
        if (password && password.length > 0) {
            const hashedPassword = await bcrypt.hash(password, 10);

            const sql = `
                UPDATE users
                SET
                    nama = ?,
                    email = ?,
                    password = ?,
                    status = ?
                WHERE id = ?
            `;

            await db.promise().query(
                sql,
                [
                    nama.trim(),
                    email.trim(),
                    hashedPassword,
                    userStatus,
                    userId
                ]
            );

        } else {
            // UPDATE TANPA PASSWORD
            const sql = `
                UPDATE users
                SET
                    nama = ?,
                    email = ?,
                    status = ?
                WHERE id = ?
            `;

            await db.promise().query(
                sql,
                [
                    nama.trim(),
                    email.trim(),
                    userStatus,
                    userId
                ]
            );
        }

        res.status(200).json({
            status: true,
            message: 'Data user berhasil diupdate',
            data: {
                id: Number(userId),
                nama: nama.trim(),
                email: email.trim(),
                status: userStatus
            }
        });

    } catch (error) {
        console.error(error);

        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                status: false,
                message: 'Email sudah digunakan'
            });
        }

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan pada server'
        });
    }
});

// ======================================================
// RESET PASSWORD BERDASARKAN ID USER
// ======================================================

app.put('/reset-password/:id', async (req, res) => {
    const userId = req.params.id;
    const { password } = req.body;

    try {
        // CEK USER BERDASARKAN ID
        const [users] = await db.promise().query(
            'SELECT id FROM users WHERE id = ?',
            [userId]
        );

        if (users.length === 0) {
            return res.status(404).json({
                status: false,
                message: 'User tidak ditemukan'
            });
        }

        // HASH PASSWORD BARU
        const hashedPassword = await bcrypt.hash(
            String(password ?? ''),
            10
        );

        // UPDATE PASSWORD
        await db.promise().query(
            'UPDATE users SET password = ? WHERE id = ?',
            [hashedPassword, userId]
        );

        res.status(200).json({
            status: true,
            message: 'Password berhasil diubah'
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            status: false,
            message: 'Gagal mengubah password'
        });
    }
});

// ======================================================
// DELETE USER
// ======================================================

app.delete('/user/:id', verifyToken, async (req, res) => {
    const userId = req.params.id;

    try {
        const sql = 'DELETE FROM users WHERE id = ?';

        const [result] = await db.promise().query(
            sql,
            [userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                status: false,
                message: 'User tidak ditemukan'
            });
        }

        res.status(200).json({
            status: true,
            message: 'User berhasil dihapus'
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            status: false,
            message: 'Terjadi kesalahan pada server'
        });
    }
});

// ======================================================
// LOGIN
// ======================================================

app.post('/login', async (req, res) => {
    const {
        email,
        password
    } = req.body;

    if (!email || !password) {
        return res.status(400).json({
            status: false,
            message: 'email dan password wajib diisi'
        });
    }

    // VALIDASI EMAIL LOGIN
    if (!isValidEmail(email.trim())) {
        return res.status(400).json({
            status: false,
            message: 'Format email tidak valid'
        });
    }

    try {
        const sql = 'SELECT * FROM users WHERE email = ?';

        const [rows] = await db.promise().query(
            sql,
            [email.trim()]
        );

        if (rows.length === 0) {
            return res.status(401).json({
                status: false,
                message: 'email atau password salah'
            });
        }

        const user = rows[0];

        // CEK STATUS USER
        if (user.status === 'Nonaktif') {
            return res.status(403).json({
                status: false,
                message: 'Akun sedang nonaktif. Silakan hubungi administrator.'
            });
        }

        // CEK PASSWORD
        const passwordmatch = await bcrypt.compare(
            password,
            user.password
        );

        if (!passwordmatch) {
            return res.status(401).json({
                status: false,
                message: 'email atau password salah'
            });
        }

        // MEMBUAT TOKEN JWT
        const token = jwt.sign(
            {
                id: user.id,
                email: user.email
            },
            JWT_SECRET,
            {
                expiresIn: '1h'
            }
        );

        res.status(200).json({
            status: true,
            message: 'login berhasil',
            data: {
                id: user.id,
                nama: user.nama,
                email: user.email,
                status: user.status,
                token: token
            }
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            status: false,
            message: 'terjadi kesalahan pada server'
        });
    }
});

// ======================================================
// START SERVER
// ======================================================

app.listen(port, () => {
    console.log(`Server berjalan di http://localhost:${port}`);
});