#!/bin/bash -eu

function checkEnv() {
  set +e
  local error=false

  if [ -z ${ORACLE_SID} ]; then
    echo "[ERROR] You need to specify the desired ORACLE_SID"
    error=true
  fi

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

  if ${error}; then
    exit 1
  fi
  set -e
}

function startOrCreateDatabase() {
  if [ -e ${ORACLE_BASE}/oradata/${ORACLE_SID} ]; then
    echo "[INFO] Database already initialized, just starting it"

    startDatabase
    return
  fi

  $ORACLE_HOME/bin/dbca -silent -createdatabase -templatename General_Purpose.dbc -gdbname "${ORACLE_SID}" -sid "${ORACLE_SID}" -syspassword "${ORACLE_DBA_PASSWORD}" -systempassword "${ORACLE_DBA_PASSWORD}" -dbsnmppassword "${ORACLE_DBA_PASSWORD}"
  createUser
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
