CREATE OR REPLACE PACKAGE ing_party_pkg AS

    FUNCTION get_partida_in_long (
        period   NUMBER DEFAULT NULL,
        period_m NUMBER DEFAULT NULL,
        spa      VARCHAR2 DEFAULT NULL,
        clo      VARCHAR2 DEFAULT NULL,
        cle      VARCHAR2 DEFAULT NULL,
        fons     VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 SQL_MACRO;

    FUNCTION get_partida_in_long_all (
        period   NUMBER DEFAULT NULL,
        period_m NUMBER DEFAULT NULL,
        spa      VARCHAR2 DEFAULT NULL,
        clo      VARCHAR2 DEFAULT NULL,
        cle      VARCHAR2 DEFAULT NULL,
        fons     VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 SQL_MACRO;

END ing_party_pkg;
/

CREATE OR REPLACE PACKAGE BODY ing_party_pkg AS

    FUNCTION get_partida_in_long (
        period   NUMBER DEFAULT NULL,
        period_m NUMBER DEFAULT NULL,
        spa      VARCHAR2 DEFAULT NULL,
        clo      VARCHAR2 DEFAULT NULL,
        cle      VARCHAR2 DEFAULT NULL,
        fons     VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 SQL_MACRO IS
    BEGIN
        RETURN q'{
   SELECT CA_IN_LONG.REF_PERIOD,
          CA_IN_LONG.REF_PERIOD_M,
          CA_IN_LONG.CL_SPA,
          CA_IN_LONG.ECO_CLO,
          CA_IN_LONG.ECO_CLE,
          CA_IN_LONG.ECO_FONS,
          CA_IN_LONG.CONS,
          CA_IN_LONG.DIMENSION_TYPE,
          CA_IN_LONG.OBS_VALUE
   FROM CA_IN_LONG
   WHERE (get_partida_in_long.PERIOD IS NULL
          OR CA_IN_LONG.REF_PERIOD = get_partida_in_long.PERIOD)
     AND (get_partida_in_long.PERIOD_M IS NULL
          OR CA_IN_LONG.REF_PERIOD_M = get_partida_in_long.PERIOD_M)
     AND (get_partida_in_long.SPA IS NULL
          OR CA_IN_LONG.CL_SPA LIKE get_partida_in_long.SPA)
     AND (get_partida_in_long.CLO IS NULL
          OR CA_IN_LONG.ECO_CLO LIKE get_partida_in_long.CLO)
     AND (get_partida_in_long.CLE IS NULL
          OR CA_IN_LONG.ECO_CLE LIKE get_partida_in_long.CLE)
     AND (get_partida_in_long.FONS IS NULL
          OR CA_IN_LONG.ECO_FONS LIKE get_partida_in_long.FONS)
  }';
    END;

    FUNCTION get_partida_in_long_all (
        period   NUMBER DEFAULT NULL,
        period_m NUMBER DEFAULT NULL,
        spa      VARCHAR2 DEFAULT NULL,
        clo      VARCHAR2 DEFAULT NULL,
        cle      VARCHAR2 DEFAULT NULL,
        fons     VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 SQL_MACRO IS
    BEGIN
        RETURN q'{
   SELECT REF_PERIOD,
          REF_PERIOD_M,
          CL_SPA,
          ECO_CLO,
          ECO_CLE,
          ECO_FONS,
          CONS,
          NVL(PR_INI, 0) AS PR_INI,
          NVL(PR_MOD, 0) AS PR_MOD,
          NVL(PR_INI, 0) + NVL(PR_MOD, 0) AS PR_DEF,
          NVL(CON_INT, 0) AS CON_INT,
          NVL(CON_ANU, 0) AS CON_ANU,
          NVL(CON_INT, 0) - NVL(CON_ANU, 0) AS CON_LIQ,
          NVL(OTRAS_DAT, 0) AS OTRAS_DAT,	  
          NVL(REC_INT, 0) AS REC_INT,
          NVL(REC_DEV, 0) AS REC_DEV,
          NVL(REC_INT, 0) - NVL(REC_DEV, 0) AS REC_LIQ,
          NVL(CON_INT, 0) - NVL(CON_ANU, 0) - NVL(REC_INT, 0) + NVL(REC_DEV, 0) AS PEN_COB
	  FROM (SELECT * 
                FROM ing_party_pkg.get_partida_in_long(period => get_partida_in_long_all.PERIOD,
                                         period_m => get_partida_in_long_all.PERIOD_M,
                                         spa => get_partida_in_long_all.SPA,
                                         clo => get_partida_in_long_all.CLO,
                                         cle => get_partida_in_long_all.CLE,
                                         fons => get_partida_in_long_all.FONS)
                PIVOT (SUM(OBS_VALUE) FOR DIMENSION_TYPE IN ('PR_INI' AS PR_INI,
                                                             'PR_MOD' AS PR_MOD,
                                                             'CON_INT' AS CON_INT,
                                                             'CON_ANU' AS CON_ANU,
                                                             'OTRAS_DAT' AS OTRAS_DAT,
                                                             'REC_INT' AS REC_INT,
                                                             'REC_DEV' AS REC_DEV)))
  }';
    END;

END ing_party_pkg;
/

SELECT
    *
  FROM
    ing_party_pkg.get_partida_in_long_all(period => 2008,
                                          period_m => 12,
                                          spa => 'SSIB',
                                          clo => '60001',
                                          cle => '75000',
                                          fons => '00000');

SELECT
    *
  FROM
    ing_party_pkg.get_partida_in_long_all(period => 2016,
                                          period_m => 12,
                                          clo => '14%',
                                          cle => '3%',
                                          fons => '00000');
