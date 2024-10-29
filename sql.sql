Query() {
sqlplus -s / <<eof
set serveroutput on;
set time on;
set timing on;
spool $data/temp/bgtrupdation.txt
declare
CURSOR BGTR_CURSOR IS SELECT *  FROM BGTR WHERE  INST_NO = '003' AND NEXT_DATE = (SELECT TO_CHAR(TO_DATE($date1,'YYYYMMDD'),'J')-2415020 FROM DUAL);
BEGIN
        FOR C1 IN BGTR_CURSOR
        LOOP
            IF(C1.FREQUENCY = 'D' )
            THEN
                    BEGIN
                        UPDATE BGTR SET LAST_RUN_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date((TO_CHAR(TO_DATE($date1,'YYYYMMDD'))),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual ), NEXT_DATE = ((SELECT TO_CHAR(TO_DATE($date1,'YYYYMMDD'),'J')-2415020 FROM DUAL) + 1) where FREQUENCY = 'D';
                        COMMIT;
                    END;
            END IF;
            IF(C1.FREQUENCY = 'W' )
                THEN
                BEGIN
                    UPDATE BGTR SET LAST_RUN_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date((TO_CHAR(TO_DATE($date1,'YYYYMMDD'))),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual ),NEXT_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date(next_day((TO_CHAR(TO_DATE($date1,'YYYYMMDD'))),'SUNDAY'),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual ) where FREQUENCY = 'W';
                        COMMIT;
                END;
            END IF;
            IF(C1.FREQUENCY = 'M' )
                THEN
                BEGIN
                    UPDATE BGTR SET LAST_RUN_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date((TO_CHAR(TO_DATE($date1,'YYYYMMDD'))),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual ),NEXT_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date(add_months(last_day((TO_CHAR(TO_DATE($date1,'YYYYMMDD')))),1),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual  ) where FREQUENCY = 'M';
                        COMMIT;
                END;
            END IF;
            IF(C1.FREQUENCY = 'Q' )
                THEN
                BEGIN
                    UPDATE BGTR SET LAST_RUN_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date((TO_CHAR(TO_DATE($date1,'YYYYMMDD'))),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual ),NEXT_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date(add_months(last_day((TO_CHAR(TO_DATE($date1,'YYYYMMDD')))),3),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual  )where FREQUENCY = 'Q';
                        COMMIT;
                END;
            END IF;
            IF(C1.FREQUENCY = 'H' )
                THEN
                BEGIN
                    UPDATE BGTR SET LAST_RUN_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date((TO_CHAR(TO_DATE($date1,'YYYYMMDD'))),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual ),NEXT_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date(add_months(last_day((TO_CHAR(TO_DATE($date1,'YYYYMMDD')))),6),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual  ) where FREQUENCY = 'H';
                        COMMIT;
                END;
            END IF;
            IF(C1.FREQUENCY = 'Y' )
                THEN
                BEGIN
                    UPDATE BGTR SET LAST_RUN_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date((TO_CHAR(TO_DATE($date1,'YYYYMMDD'))),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual ),NEXT_DATE = ( select TO_CHAR(TO_DATE(TO_CHAR(to_date(add_months(last_day((TO_CHAR(TO_DATE($date1,'YYYYMMDD')))),12),'DD-MON-YY'),'YYYYMMDD'),'YYYYMMDD'),'J')-2415020 from dual  ) where FREQUENCY = 'Y';
                        COMMIT;
                END;
            END IF;

        END LOOP;
END;
/
show sqlcode;
set time off;
spool off;
eof
}

date1=`cat $data/file/MFLAGS | cut -c 9-16`
Query
export sqlCode=`grep sqlcode $data/temp/bgtrupdation.txt| awk '{print $2}'`
if [ $sqlCode -ne 0 ]; then
     echo "[`date|awk '{print $2\" \"$3\" \"$4}'`] `hostname` : Error updating BGTR table. Please resolve the  problem." >> $sysout/zerobyte.log
     exit 19;
fi
