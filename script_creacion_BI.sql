USE [GD1C2022]
GO

--DROP PREVENTIVO DE FUNCIONES------------------------------------------------------------

--DROP PREVENTIVO DE TABLAS------------------------------------------------------------

--DROP PREVENTIVO DE PROCEDURES---------------------------------------------------------------
IF EXISTS(SELECT [name] FROM sys.procedures WHERE [name] = 'MIGRATE_BI_CIRCUITO')
DROP PROCEDURE  GRUPO_9800.MIGRATE_BI_CIRCUITO
IF EXISTS(SELECT [name] FROM sys.procedures WHERE [name] = 'MIGRATE_BI_PARADAS')
DROP PROCEDURE  GRUPO_9800.MIGRATE_BI_PARADAS
IF EXISTS(SELECT [name] FROM sys.procedures WHERE [name] = 'MIGRATE_BI_INCIDENTE')
DROP PROCEDURE  GRUPO_9800.MIGRATE_BI_INCIDENTE
IF EXISTS(SELECT [name] FROM sys.procedures WHERE [name] = 'MIGRAR_BI_TIEMPO')
DROP PROCEDURE  GRUPO_9800.MIGRAR_BI_TIEMPO


CREATE PROCEDURE [GRUPO_9800].CREATE_BI_TABLES
AS
BEGIN
    IF NOT EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'GRUPO_9800.BI_PARADAS')
    BEGIN
        CREATE TABLE GRUPO_9800.BI_CIRCUITO (
            ID_BI_CIRCUITO INT IDENTITY PRIMARY KEY,
            TIPO_SECTOR INT REFERENCES TIPO_SECTOR,
            TELE_AUTO_COD INT REFERENCES GRUPO_9800.TELEMETRIA_AUTO,
            NEUMATICO_NRO_SERIE NVARCHAR(255),
            FRENO_NRO_SERIE NVARCHAR(255),
            CAJA_NRO_SERIE NVARCHAR(255),
            MOTOR_NRO_SERIE NVARCHAR(255),
            DESGASTE_NUEVO_NEUMATICO DECIMAL(18,6),
            DESGASTE_VIEJO_NEUMATICO DECIMAL(18,6),
            DESGASTE_NUEVO_FRENO DECIMAL(18,2),
            DESGASTE_VIEJO_FRENO DECIMAL(18,2),
            POTENCIA_VIEJA_MOTOR NUMERIC(18,6),
            POTENCIA_NUEVA_MOTOR NUMERIC(18,6),
            DESGASTE_VIEJO_CAJA NUMERIC(18,2),
            DESGASTE_NUEVO_CAJA NUMERIC(18,2),
            VEHICULO INT,
            COD_ESCUDERIA INT,
            NUMERO_VUELTA NUMERIC(18,0),
            CIRCUITO_CODIGO INT,
            TIEMPO_VUELTA NUMERIC(18,10),
            COMBUSTIBLE_CONSUMIDO DECIMAL(18,2),
            VELOCIDAD DECIMAL(18,2),
            SECTOR INT
        );

        ALTER TABLE GRUPO_9800.BI_CIRCUITO
		ADD CONSTRAINT FK_BICircuito_Neumatico
		FOREIGN KEY(TELE_AUTO_COD, NEUMATICO_NRO_SERIE) REFERENCES GRUPO_9800.TELEMETRIA_NEUMATICO(TELE_AUTO_COD, NEUMATICO_NRO_SERIE);

        ALTER TABLE GRUPO_9800.BI_CIRCUITO
		ADD CONSTRAINT FK_BICircuito_Freno
		FOREIGN KEY(TELE_AUTO_COD, FRENO_NRO_SERIE ) REFERENCES GRUPO_9800.TELEMETRIA_FRENO(TELE_AUTO_COD, FRENO_NRO_SERIE );

        ALTER TABLE GRUPO_9800.BI_CIRCUITO
		ADD CONSTRAINT FK_BICircuito_Caja
		FOREIGN KEY(TELE_AUTO_COD, CAJA_NRO_SERIE) REFERENCES GRUPO_9800.TELEMETRIA_CAJA(TELE_AUTO_COD, CAJA_NRO_SERIE);

        ALTER TABLE GRUPO_9800.BI_CIRCUITO
		ADD CONSTRAINT FK_BICircuito_Motor
		FOREIGN KEY(TELE_AUTO_COD, MOTOR_NRO_SERIE) REFERENCES GRUPO_9800.TELEMETRIA_MOTOR(TELE_AUTO_COD, MOTOR_NRO_SERIE);
    END


    IF NOT EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'GRUPO_9800.BI_PARADAS')
    BEGIN
        CREATE TABLE GRUPO_9800.BI_PARADAS (
            ID_BI_CIRCUITO INT IDENTITY PRIMARY KEY,
            COD_ESCUDERIA INT REFERENCES GRUPO_9800.ESCUDERIA,
            CIRCUITO_CODIGO INT REFERENCES GRUPO_9800.CIRCUITO,
            COD_PARADA_BOX INT REFERENCES GRUPO_9800.PARADA_BOX,
            TIEMPO_PARADA_BOX NUMERIC(18,2)
        );
    END

    IF NOT EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'GRUPO_9800.BI_INCIDENTE')
    BEGIN
        CREATE TABLE GRUPO_9800.BI_INCIDENTE (
            ID_BI_INCIDENTE INT IDENTITY PRIMARY KEY,
            COD_INCIDENTE INT REFERENCES GRUPO_9800.INCIDENTE,
            ID_TIPO_SECTOR INT REFERENCES GRUPO_9800.TIPO_SECTOR,
            COD_ESCUDERIA INT REFERENCES GRUPO_9800.ESCUDERIA,
            CIRCUITO_CODIGO INT REFERENCES GRUPO_9800.CIRCUITO
        );
    END

    IF NOT EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'GRUPO_9800.BI_TIEMPO')
    BEGIN
        CREATE TABLE GRUPO_9800.BI_TIEMPO(
            COD_TIEMPO INT IDENTITY PRIMARY KEY,
            ANIO INT not null,
            MES INT not null,
            DIA INT not null
        );
    END
    
END
GO


/*MIGRACIÓN*/

CREATE PROCEDURE [GRUPO_9800].MIGRATE_BI_CIRCUITO /*CAMBIAR/COMPLETAR*/
AS
BEGIN
    INSERT INTO GRUPO_9800.BI_CIRCUITO (TIPO_SECTOR,TELE_AUTO_COD,NEUMATICO_NRO_SERIE,FRENO_NRO_SERIE,CAJA_NRO_SERIE,MOTOR_NRO_SERIE,
                                        DESGASTE_NUEVO_NEUMATICO,DESGASTE_VIEJO_NEUMATICO,DESGASTE_NUEVO_FRENO,DESGASTE_VIEJO_FRENO, /*NO SE COMO SACAR EL DESGASTE*/
                                        POTENCIA_VIEJA_MOTOR,POTENCIA_NUEVA_MOTOR,DESGASTE_VIEJO_CAJA,
                                        DESGASTE_NUEVO_CAJA,VEHICULO,COD_ESCUDERIA,NUMERO_VUELTA,CIRCUITO_CODIGO,TIEMPO_VUELTA,
                                        COMBUSTIBLE_CONSUMIDO,VELOCIDAD,SECTOR)
    SELECT ts.id_tipo_sector, ta.tele_auto_cod, tn.neumatico_nro_serie,tf.freno_nro_serie,tc.caja_nro_serie,tm.motor_nro_serie,


    FROM GRUPO_9800.telemetria_auto ta JOIN GRUPO_9800.sector s ON (ta.codigo_sector = s.codigo_sector)
                                        JOIN GRUPO_9800.tipo_sector ts ON (s.id_tipo_sector = ts.id_tipo_sector)
                                        JOIN GRUPO_9800.telemetria_neumatico tn ON (ta.tele_auto_cod = tn.tele_auto_cod)
                                        JOIN GRUPO_9800.telemetria_freno tf ON (ta.tele_auto_cod = tf.tele_auto_cod)
                                        JOIN GRUPO_9800.telemetria_caja tc ON (ta.tele_auto_cod = tc.tele_auto_cod)
                                        JOIN GRUPO_9800.telemetria_motor tm ON (ta.tele_auto_cod = tm.tele_auto_cod)
                                        

END
    GO

CREATE PROCEDURE [GRUPO_9800].MIGRATE_BI_PARADAS /*CAMBIAR*/
AS
BEGIN
    INSERT INTO GRUPO_9800.BI_PARADAS (COD_ESCUDERIA,CIRCUITO_CODIGO,COD_PARADA_BOX,TIEMPO_PARADA_BOX)
    SELECT e.cod_escuderia, ci.circuito_codigo, pbv.cod_parada_box,pb.parada_box_tiempo
    FROM GRUPO_9800.parada_box_por_vehiculo pbv JOIN GRUPO_9800.parada_box pb ON (pbv.cod_parada_box = pb.cod_parada_box)
                                                JOIN GRUPO_9800.escuderia e ON (pbv.cod_escuderia = e.cod_escuderia)
                                                JOIN GRUPO_9800.carrera ca ON (pbv.codigo_carrera = ca.codigo_carrera)
                                                JOIN GRUPO_9800.circuito ci ON (ca.circuito_codigo = ci.circuito_codigo)
END
    GO

CREATE PROCEDURE [GRUPO_9800].MIGRATE_BI_INCIDENTE /*CAMBIAR*/
AS
BEGIN
    INSERT INTO GRUPO_9800.BI_INCIDENTE (COD_INCIDENTE,ID_TIPO_SECTOR,COD_ESCUDERIA,CIRCUITO_CODIGO)
    SELECT i.cod_incidente, ts.id_tipo_sector,e.cod_escuderia,i.circuito_codigo
    FROM GRUPO_9800.incidente i JOIN GRUPO_9800.sector s ON (i.codigo_sector = s.codigo_sector)
                                JOIN GRUPO_9800.tipo_sector ts ON (s.id_tipo_sector = ts.id_tipo_sector)
                                JOIN GRUPO_9800.incidente_por_auto ia ON (i.cod_incidente = ia.cod_incidente)
                                JOIN GRUPO_9800.escuderia e ON (ia.cod_escuderia = e.cod_escuderia)
END
    GO

CREATE PROCEDURE GRUPO_9800.MIGRAR_BI_TIEMPO
AS
BEGIN
	DECLARE date_cursor CURSOR FOR SELECT CARRERA_FECHA FROM GRUPO_9800.CARRERA
	
	DECLARE @Date DATETIME
	DECLARE @ANIO INT
	DECLARE @Mes INT
	DECLARE @Dia INT

	OPEN date_cursor
	FETCH NEXT FRIOM date_cursor into @Date

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
			SET @Anio = YEAR(@Date)
			SET @Mes = MONTH(@Date)
			SET @Dia = DAY(@Date)

			IF NOT EXISTS (SELECT 1 FROM GRUPO_9800.BI_TIEMPO WHERE (ANIO = @Anio AND MES = @Mes AND DIA = @Dia))
				INSERT INTO GRUPO_9800.BI_tiempo (ANIO, MES, DIA) VALUES (@Anio, @Mes, @Dia)
			
			FETCH NEXT date_cursor into @Date
	END

	CLOSE date_cursor
	DEALLOCATE date_cursor
END
GO