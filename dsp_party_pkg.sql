CREATE OR REPLACE PACKAGE dsp_party_pkg AS

FUNCTION get_partida_dp_long(PERIOD NUMBER default NULL,
                                               PERIOD_M NUMBER default NULL,
                                               SPA VARCHAR2 default NULL,
                                               CLO VARCHAR2 default NULL,
                                               CLF VARCHAR2 default NULL,
                                               CLE VARCHAR2 default NULL,
                                               AREA VARCHAR2 default NULL,
                                               FONS VARCHAR2 default NULL) return VARCHAR2 SQL_MACRO;
					       
FUNCTION get_partida_dp_long_all(PERIOD NUMBER default NULL,
                                                   PERIOD_M NUMBER default NULL,
                                                   SPA VARCHAR2 default NULL,
                                                   CLO VARCHAR2 default NULL,
                                                   CLF VARCHAR2 default NULL,
                                                   CLE VARCHAR2 default NULL,
                                                   AREA VARCHAR2 default NULL,
                                                   FONS VARCHAR2 default NULL) return VARCHAR2 SQL_MACRO;

END dsp_party_pkg;
/

CREATE OR REPLACE PACKAGE BODY dsp_party_pkg AS

FUNCTION get_partida_dp_long(PERIOD NUMBER default NULL,
                                               PERIOD_M NUMBER default NULL,
                                               SPA VARCHAR2 default NULL,
                                               CLO VARCHAR2 default NULL,
                                               CLF VARCHAR2 default NULL,
                                               CLE VARCHAR2 default NULL,
                                               AREA VARCHAR2 default NULL,
                                               FONS VARCHAR2 default NULL) return VARCHAR2 SQL_MACRO is
BEGIN
  RETURN q'[
   SELECT CA_DP_LONG.REF_PERIOD,
          CA_DP_LONG.REF_PERIOD_M,
          CA_DP_LONG.CL_SPA,
          CA_DP_LONG.ECO_CLO,
          CA_DP_LONG.ECO_CLF,
          CA_DP_LONG.ECO_CLE,
          CA_DP_LONG.REF_AREA,
          CA_DP_LONG.ECO_FONS,
          CA_DP_LONG.CONS,
          CA_DP_LONG.DIMENSION_TYPE,
          CA_DP_LONG.OBS_VALUE
   FROM CA_DP_LONG
   WHERE (get_partida_dp_long.PERIOD IS NULL
          OR CA_DP_LONG.REF_PERIOD = get_partida_dp_long.PERIOD)
     AND (get_partida_dp_long.PERIOD_M IS NULL
          OR CA_DP_LONG.REF_PERIOD_M = get_partida_dp_long.PERIOD_M)
     AND (get_partida_dp_long.SPA IS NULL
          OR CA_DP_LONG.CL_SPA LIKE get_partida_dp_long.SPA)
     AND (get_partida_dp_long.CLO IS NULL
          OR CA_DP_LONG.ECO_CLO LIKE get_partida_dp_long.CLO)
     AND (get_partida_dp_long.CLF IS NULL
          OR CA_DP_LONG.ECO_CLF LIKE get_partida_dp_long.CLF)
     AND (get_partida_dp_long.CLE IS NULL
          OR CA_DP_LONG.ECO_CLE LIKE get_partida_dp_long.CLE)
     AND (get_partida_dp_long.AREA IS NULL
          OR CA_DP_LONG.REF_AREA LIKE get_partida_dp_long.AREA)
     AND (get_partida_dp_long.FONS IS NULL
          OR CA_DP_LONG.ECO_FONS LIKE get_partida_dp_long.FONS)
  ]';
END;

FUNCTION get_partida_dp_long_all(PERIOD NUMBER default NULL,
                                                   PERIOD_M NUMBER default NULL,
                                                   SPA VARCHAR2 default NULL,
                                                   CLO VARCHAR2 default NULL,
                                                   CLF VARCHAR2 default NULL,
                                                   CLE VARCHAR2 default NULL,
                                                   AREA VARCHAR2 default NULL,
                                                   FONS VARCHAR2 default NULL) return VARCHAR2 SQL_MACRO is
BEGIN
  RETURN q'{
   SELECT REF_PERIOD,
          REF_PERIOD_M,
          CL_SPA,
          ECO_CLO,
          ECO_CLF,
          ECO_CLE,
          REF_AREA,
          ECO_FONS,
          CONS,
          NVL(CR_INI, 0) AS CR_INI,
          NVL(CR_MOD, 0) AS CR_MOD,
          NVL(CR_INI, 0) + NVL(CR_MOD, 0) AS CR_DEF,
          NVL(CR_RES, 0) AS CR_RES,
          NVL(CR_RES, 0) - NVL(CR_AUT, 0) AS CR_PEND_AUT,
          NVL(CR_AUT, 0) AS CR_AUT,
          NVL(CR_AUT, 0) - NVL(CR_DISP, 0) AS CR_PEND_DISP,
          NVL(CR_DISP, 0) AS CR_DISP,
          NVL(CR_DISP, 0) - NVL(CR_ORD, 0) AS CR_PEND_ORD,
          NVL(CR_ORD, 0) AS CR_ORD,
          NVL(CR_PAG, 0) AS CR_PAG,
          NVL(CR_ORD, 0) - NVL(CR_PAG, 0) AS CR_PEND_PAG,
          NVL(PAG_OT_EJ, 0) AS PAG_OT_EJ,
          NVL(CR_INI, 0) + NVL(CR_MOD, 0) - NVL(CR_RES, 0) AS CR_DISPON
	  FROM (SELECT * 
                FROM dsp_party_pkg.get_partida_dp_long(period => get_partida_dp_long_all.PERIOD,
                                         period_m => get_partida_dp_long_all.PERIOD_M,
                                         spa => get_partida_dp_long_all.SPA,
                                         clo => get_partida_dp_long_all.CLO,
                                         clf => get_partida_dp_long_all.CLF,
                                         cle => get_partida_dp_long_all.CLE,
                                         area => get_partida_dp_long_all.AREA,
                                         fons => get_partida_dp_long_all.FONS)
                PIVOT (SUM(OBS_VALUE) FOR DIMENSION_TYPE IN ('CR_INI' AS CR_INI,
                                                             'CR_MOD' AS CR_MOD,
                                                             'CR_RES' AS CR_RES,
                                                             'CR_AUT' AS CR_AUT,
                                                             'CR_DISP' AS CR_DISP,
                                                             'CR_ORD' AS CR_ORD,
                                                             'CR_PAG' AS CR_PAG,
                                                             'PAG_OT_EJ' AS PAG_OT_EJ)))
  }';
END;

END dsp_party_pkg;
/
