--1 Quantos chamados foram abertos no dia 01/04/2023?

SELECT COUNT(*) as chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE date(data_inicio) = '2023-04-01'

Resultado : 1756 chamados


-- 2 Qual o tipo de chamado que teve mais teve chamados abertos no dia 01/04/2023?

SELECT tipo, COUNT(*) as total_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE date(data_inicio) = '2023-04-01'
GROUP BY tipo
ORDER BY total_chamados DESC
LIMIT 1;

Resultado : Estacionamento irregular com 366 chamados.


--3 Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?

SELECT a.nome, COUNT(*) as total   
FROM `datario.dados_mestres.bairro` as a
JOIN `datario.adm_central_atendimento_1746.chamado` as b
ON a.id_bairro = b.id_bairro
WHERE date(data_inicio) = '2023-04-01'
GROUP BY a.nome
ORDER BY total desc
LIMIT 3

Resultado: Campo Grande 113
	   Tijuca 89
           Barra da Tijuca 59


--4 Qual o nome da subprefeitura com mais chamados abertos nesse dia?

SELECT a.subprefeitura, COUNT(*) as total   
FROM `datario.dados_mestres.bairro` as a
JOIN `datario.adm_central_atendimento_1746.chamado` as b
ON a.id_bairro = b.id_bairro
WHERE date(data_inicio) = '2023-04-01'
GROUP BY a.subprefeitura
ORDER BY total desc
LIMIT 1

Resultado: Zona Norte 510


--5 Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros? Se sim, por que isso acontece?

SELECT *   
FROM `datario.dados_mestres.bairro` as a
JOIN `datario.adm_central_atendimento_1746.chamado` as b
ON a.id_bairro = b.id_bairro
WHERE date(data_inicio) = '2023-04-01'
AND
(a.nome is null
OR
a.subprefeitura is null
OR
b.id_chamado is null
)

Resultado: 

Neste caso, checamos se existem valores nulos nas colunas nome, subprefeitura e id_chamado. Caso exista, isso acontece por conta de alguma falha do tipo: dados incompletos
ou incorretos, perda de informações, problemas técnicos.


--6 Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?

SELECT COUNT(*) as chamado
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE date(data_inicio) between '2022-01-01' AND '2023-12-31'
AND subtipo = 'Perturbação do sossego'
LIMIT 1

Resultado : 42830 chamados


-- 7 Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).

SELECT c.*
FROM `datario.adm_central_atendimento_1746.chamado` c
JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` e
ON date(data_inicio) between '2022-01-01' AND '2023-12-31'
WHERE c.subtipo = 'Perturbação do sossego'
AND e.evento IN ('Reveillon', 'Carnaval', 'Rock in Rio');

Resultado: Ao final da pesquisa, foram encontrados 171320 chamados deste subtipo.


--8 Quantos chamados desse subtipo foram abertos em cada evento?


SELECT
    e.evento,
    COUNT(c.id_chamado) AS total_chamados
FROM
    `datario.adm_central_atendimento_1746.chamado` c
JOIN
    `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` e
ON
    c.subtipo = 'Perturbação do sossego'
GROUP BY
    e.evento
ORDER BY
    total_chamados DESC;

Resultado : Rock in Rio 181644
            Carnaval 90832
            Reveillon 90832


--9 Qual evento teve a maior média diária de chamados abertos desse subtipo?

WITH ChamadosPorEvento AS (
    SELECT
        e.evento,
        DATE(c.data_inicio) AS data_chamado,
        COUNT(c.id_chamado) AS total_chamados
    FROM
        `datario.adm_central_atendimento_1746.chamado` c
    JOIN
        `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` e
    ON
        c.subtipo = 'Perturbação do sossego'
    GROUP BY
        e.evento, DATE(c.data_inicio)
)

SELECT
    evento,
    AVG(total_chamados) AS media_diaria_chamados
FROM
    ChamadosPorEvento
GROUP BY
    evento
ORDER BY
    media_diaria_chamados DESC
LIMIT 1;

Resultado: Rock in Rio 103,10


-- 10 Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2023.

WITH ChamadosPorEvento AS (
    SELECT
        e.evento,
        DATE(c.data_inicio) AS data_chamado,
        COUNT(c.id_chamado) AS total_chamados
    FROM
        `datario.adm_central_atendimento_1746.chamado` c
    JOIN
        `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` e
    ON
        DATE(c.data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
    WHERE
        c.subtipo = 'Perturbação do sossego'
    GROUP BY
        e.evento, DATE(c.data_inicio)
)

SELECT
    evento,
    AVG(total_chamados) AS media_diaria_chamados
FROM
    ChamadosPorEvento
GROUP BY
    evento
ORDER BY
    media_diaria_chamados DESC
LIMIT 10;

Resultado: Rock in Rio 123,96
           Carnaval 61,98
           Reveillon 61,98


