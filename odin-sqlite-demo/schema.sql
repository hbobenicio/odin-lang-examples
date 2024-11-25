CREATE TABLE conta_corrente (
    id INTEGER PRIMARY KEY,
    email TEXT UNIQUE,
    saldo REAL DEFAULT 0.0,
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
