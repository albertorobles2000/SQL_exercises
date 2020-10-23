/*
Nombre: Alberto Robles Hernández
Correo: alberto.robles.hernandez@gmail.com
Grupo: B-2
*/

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

/*1. Crear las tablas clase, barcos, batalla y participa */

CREATE TABLE clase (
    NomClase VARCHAR2(30) CHECK (NomClase IN ('Goleta','Carabela','Fragata','Galeón')),
    Tipo VARCHAR2(30) NOT NULL,
    NCanones NUMBER DEFAULT 4 CHECK (NCanones>=4 and NCanones<=16),
    Calibre NUMBER,
    Tonelaje NUMBER NOT NULL
    PRIMARY KEY(NomClase)
);

CREATE TABLE barcos (
    NomBarco VARCHAR2(30) PRIMARY KEY,
    NomClase REFERENCES clase(NomClase),
    FechaCons DATE,
    Pais VARCHAR2(15)
);

CREATE TABLE batalla (
    NomBatalla VARCHAR2(30) PRIMARY KEY,
    Localizacion VARCHAR2(30)
);

CREATE TABLE participa (
    NomBatalla REFERENCES batalla(NomBatalla),
    NomBarco REFERENCES barcos(NomBarco),
    Estado VARCHAR2(30) CHECK (Estado IN ('Hundido','Indemne','Perjudicado'))
    PRIMARY KEY(NomBatalla,NomBarco)
);

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

/*2. Listar los nombres de las goletas que participaron en una sola batalla. */

SELECT barcos.NomBarco FROM participa, barcos WHERE barcos.NomClase='Goleta' AND paricipa.NomBarco=barcos.NomBarco;
MINUS
SELECT p1.NomBarco FROM participa p1, participa p2 WHERE p1.NomBarco=p2.NomBarco AND p1.NomBatalla <> p2.NomBatalla;


SELECT Nombarco FROM barcos,participa WHERE barcos.NomClase='Goleta' AND barcos.Nombarco=participa.NomBarco
GROUP BY NomBarco
HAVING count(distinct NomBatalla)=1

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

/*3. Mostrar los datos completos de las batallas localizadas en el Pacífico en las que participaron todos los barcos de más de 10 cañones. */

SELECT batalla.NomBatalla, batalla.Localizacion
FROM batalla
WHERE Localizacion='Pacífico' and NOT EXISTS (
  (SELECT NomBarco
    FROM  barcos,clase
    WHERE  barcos.NomBarco=clase.NomBarco and NCanones > 10)
  MINUS
  (SELECT NomBarco
    FROM participa
    WHERE participa.NomBatalla = batalla.NomBatalla)
);

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

/*4. Mostar las batallas en las que se hundieron más de 10 barcos. */

SELECT batalla.NomBatalla FROM batalla WHERE 10 < (SELECT count(paticipa.NomBarco) FROM participa WHERE
batalla.NomBatalla=paticipa.NomBatalla AND participa.Estado='Hundido' GROUP BY batalla.NomBatalla);


SELECT NomBatalla FROM Participa WHERE Estado='Hundido' GROUP BY NomBatalla HAVING count(NomBarco) > 10

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

/*5. Crear una vista que muestre el número de barcos construidos por cada país cada año. */

Create view barcos_pais as
SELECT count(barcos.NomBarco), Pais, FechaCons FROM Barcos GROUP BY Pais, FechaCons;
SELECT pais, to_char(fechacons, 'YYYY') Año, count(*) NBarcos 
FROM barcos GROUP BY pais, to_char(fechacons, 'YYYY') 
ORDER BY pais, to_char(fechacons, 'YYYY')
