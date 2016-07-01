#!/bin/bash -eu

function checkEnv() {
  set +eu
  local error=false

  INITIALIZED=false

  INIT_FILE=$(ls ${ORACLE_BASE}/data/init*.ora 2>/dev/null)

  if [ -z "$INIT_FILE" ]; then
    INITIALIZED=false
  else
    INITIALIZED=true
    ORACLE_SID=$(basename ${INIT_FILE} | cut -f 1 -d"." | cut -b5-)
  fi

  if [ -z ${ORACLE_SID} ]; then
    echo "[ERROR] You need to specify the desired ORACLE_SID"
    error=true
  fi

  if ! $INITIALIZED; then
    if [ -z ${ORACLE_DATABASE} ]; then
      echo "[ERROR] You need to specify the desired ORACLE_DATABASE (8 chars max)"
      error=true
    fi

    if [ -z ${ORACLE_USER} ]; then
      echo "[ERROR] You need to specify the desired ORACLE_USER"
      error=true
    fi

    if [ -z ${ORACLE_PASSWORD} ]; then
      echo "[ERROR] Uou need to specify the desired ORACLE_PASSWORD"
      error=true
    fi

    if [ -z ${ORACLE_DBA_PASSWORD} ]; then
      echo "[ERROR] You need to specify the desired ORACLE_DBA_PASSWORD"
      error=true
    fi
  fi

  if ${error}; then
    exit 1
  fi
  set -eu
}

function startOrCreateDatabase() {
  if $INITIALIZED; then
    echo "[INFO] Database already initialized, just starting it"
    cp -v ${ORACLE_BASE}/data/init${ORACLE_SID}.ora ${ORACLE_HOME}/dbs 
    cp -v ${ORACLE_BASE}/data/tnsnames.ora ${ORACLE_HOME}/network/admin

    startDatabase
    return
  fi

  $ORACLE_HOME/bin/dbca -silent -createdatabase -templatename ${ORACLE_HOME}/database.dbc -gdbname "${ORACLE_SID}" -sid "${ORACLE_SID}" -syspassword "${ORACLE_DBA_PASSWORD}" -systempassword "${ORACLE_DBA_PASSWORD}" -dbsnmppassword "${ORACLE_DBA_PASSWORD}" -initParams PROCESSES=150
  createUser

  cp ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora ${ORACLE_BASE}/data
  cp ${ORACLE_HOME}/network/admin/tnsnames.ora ${ORACLE_BASE}/data
}

function startDatabase() {
  ${ORACLE_HOME}/bin/sqlplus / as sysdba << EOF
  startup;
  exit;
EOF

}

function createUser() {
  echo "create user ${ORACLE_USER} identified by ${ORACLE_PASSWORD};" | ${ORACLE_HOME}/bin/sqlplus / as sysdba
  echo "GRANT ALL PRIVILEGES to ${ORACLE_USER};" | ${ORACLE_HOME}/bin/sqlplus / as sysdba
}

function startListener() {
  printf "LISTENER=(DESCRIPTION_LIST=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=0.0.0.0)(PORT=1521))(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1521))))\n" > $ORACLE_HOME/network/admin/listener.ora
  $ORACLE_HOME/bin/lsnrctl start
}

checkEnv

startListener

startOrCreateDatabase

tail -F /dev/null
