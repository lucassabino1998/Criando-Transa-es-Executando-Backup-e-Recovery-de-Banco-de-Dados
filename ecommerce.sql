show databases;
use ecommerce;
show tables;

select * from clientpj ;

select * from product;

-- Desliga o safe update para evitar erro 1175
SET SQL_SAFE_UPDATES = 0;

-- Desabilita autocommit
SET autocommit = 0;

-- Inicia a transação
START TRANSACTION;

-- Exemplo 1: aumento de avaliação dos produtos da categoria Eletrônico
UPDATE product 
SET avaliação = avaliação + 2 
WHERE category = 'Eletrônico';

-- Exemplo 2: diminuição da classificação de produtos da categoria Brinquedos
UPDATE product 
SET classification_kids = classification_kids - 1 
WHERE category = 'Brinquedos';

-- Confirma a transação
COMMIT;

-- Restaura safe updates
SET SQL_SAFE_UPDATES = 1;


DELIMITER //

CREATE PROCEDURE atualizarEstoqueProduto (
    IN p_id INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_estoque_atual INT;

    -- Handler de erro para rollback total
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Ponto de recuperação
    SAVEPOINT antes_update;

    -- Atualiza estoque
    UPDATE product 
    SET estoque = estoque - p_quantidade 
    WHERE id = p_id;

    -- Valida se ficou negativo
    SELECT estoque INTO v_estoque_atual
    FROM product
    WHERE id = p_id;

    IF v_estoque_atual < 0 THEN
        -- Rollback parcial (volta ao SAVEPOINT)
        ROLLBACK TO antes_update;
    END IF;

    -- Finaliza
    COMMIT;
END //

DELIMITER ;

