const mysql = require('mysql2');

const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'db_toko',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

db.getConnection((error, connection) => {
    if (error) {
        console.error('Koneksi database gagal:', error);
        return;
    }

    console.log('Database berhasil terhubung');
    connection.release();
});

module.exports = db;