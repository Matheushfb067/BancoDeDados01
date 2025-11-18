DROP DATABASE IF EXISTS biblioteca;
CREATE DATABASE biblioteca;

USE biblioteca;

CREATE TABLE Usuario(
    id_usuario INT,
    nome VARCHAR(45),
    email VARCHAR(100),
    telefone VARCHAR(45),
    data DATE,

    PRIMARY KEY (id_usuario)
);

CREATE TABLE Autor(
    id_autor INT,
    nome_autor VARCHAR(45),
    nascionalidade VARCHAR(45),

    PRIMARY KEY (id_autor)
);

CREATE TABLE Livro(
    id_livro INT,
    titulo VARCHAR(45),
    ano INT,

    PRIMARY KEY (id_livro)
);

CREATE TABLE Autor_has_Livro(
    id_autor INT,
    id_livro INT,

    PRIMARY KEY (id_autor, id_livro),

    FOREIGN KEY (id_autor) REFERENCES Autor(id_autor),
    FOREIGN KEY (id_livro) REFERENCES Livro(id_livro)
);

CREATE TABLE Categoria(
    livro_usuario VARCHAR(45),
    nomeCategoria VARCHAR(45),
    descricao TEXT,

    PRIMARY KEY (livro_usuario)
);

CREATE TABLE Emprestimo(
    id_emprestimo INT,
    id_usuario INT,
    dataEmprestimo DATE,
    dataDevolucao DATE,
    status BIT, -- Entregue ou não entregue

    PRIMARY KEY (id_emprestimo, id_usuario),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

INSERT INTO Usuario VALUES
(1, 'Matheus', 'matheus@inatel.br', '(95) 9875-4521', '2025-08-03'),
(2, 'Solange', 'sol@inatel.br', '(22) 7954-6344', '2023-12-16'),
(3, 'Warley', 'warley@inatel.br', '(67) 5347-7733', '2020-06-22');

INSERT INTO Autor VALUES
(1, 'Edgar Allan Poe', 'Estados Unidos'),
(2, 'Machado de Assis', 'Brasil'),
(3, 'Monteiro Lobato', 'Brasil');

INSERT INTO Livro VALUES
(84, 'O Gato Preto', 1843),
(26, 'Memorias Postumas de Brás Cubas', 1881),
(44, 'Reinações de Narizinho', 1931);

INSERT INTO Categoria VALUES
('O Gato Preto', 'Terror', 'Um conto sombrio de Edgar Allan Poe que explora a loucura, a culpa e o peso da consciência humana.'),
('Memorias Postumas de Brás Cubas', 'Romance', 'Uma narrativa irônica e filosófica em que um defunto narra sua própria vida e critica a sociedade do século XIX.'),
('Reinações de Narizinho', 'Infanto-juvenil', 'Uma encantadora história infantil de Monteiro Lobato que mistura fantasia, imaginação e personagens do Sítio do Picapau Amarelo.');

INSERT INTO Emprestimo VALUES
(12, 1, '2025-09-03', '2025-10-03', 1),
(25, 2, '2024-01-01', '2024-02-01', 0),
(66, 3, '2021-10-23', '2025-11-23', 0);

-- Atualizar o e-mail de um usuário
UPDATE Usuario
SET email = 'matheus.henrique@inatel.edu.br'
WHERE id_usuario = 1;

-- Atualizar o status de um empréstimo (livro devolvido)
UPDATE Emprestimo
SET status = 1
WHERE id_emprestimo = 25 AND id_usuario = 2;

-- Deletar um livro (exemplo de remoção total)
DELETE FROM Livro
WHERE id_livro = 84; -- "O Gato Preto"

-- Deletar um autor (exemplo de exclusão completa)
DELETE FROM Autor
WHERE id_autor = 3; -- "Monteiro Lobato"

ALTER TABLE Usuario
ADD cpf VARCHAR(14);

DROP TABLE Autor_has_Livro;

-- Criar um novo usuário
-- Conceder privilégios para o usuário
-- Atualiza imediatamente os privilégios
DROP USER IF EXISTS 'bibliotecario'@'localhost';
CREATE USER 'bibliotecario'@'localhost' IDENTIFIED BY 'senha123';
GRANT ALL PRIVILEGES ON *.* TO 'bibliotecario'@'localhost';
FLUSH PRIVILEGES;

-- Function: calculando o total de emprestimos
DELIMITER //
CREATE FUNCTION totalEmprestimos(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Emprestimo
    WHERE id_usuario = id;
    RETURN total;
END //
DELIMITER ;

SELECT totalEmprestimos(1) AS 'Total de empréstimos de Matheus';

-- Cadastrando um novo livro
DELIMITER //
CREATE PROCEDURE cadastrarLivro(
    IN p_id_livro INT,
    IN p_titulo VARCHAR(45),
    IN p_ano INT,
    IN p_nomeCategoria VARCHAR(45),
    IN p_descricao TEXT
)
BEGIN
    INSERT INTO Livro (id_livro, titulo, ano)
    VALUES (p_id_livro, p_titulo, p_ano);

    INSERT INTO Categoria (livro_usuario, nomeCategoria, descricao)
    VALUES (p_titulo, p_nomeCategoria, p_descricao);
END //
DELIMITER ;

CALL cadastrarLivro(99, 'O Alienista', 1882, 'Sátira', 'Uma crítica bem-humorada à loucura e à sociedade da época.');

-- Lista todos os emprestimos - VIEW
CREATE VIEW vw_emprestimos_detalhados AS
SELECT
    e.id_emprestimo,
    u.nome AS nome_usuario,
    e.dataEmprestimo,
    e.dataDevolucao,
    CASE
        WHEN e.status = 1 THEN 'Entregue'
        ELSE 'Pendente'
    END AS status_livro
FROM Emprestimo e
JOIN Usuario u ON e.id_usuario = u.id_usuario;

SELECT * FROM vw_emprestimos_detalhados;