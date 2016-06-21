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

function checkOrCreateDatabase() {
  if [ -e ${ORACLE_HOME}/oradata/${ORACLE_SID} ]; then
    echo "[INFO] Database already initialized, creation aborted"
    return
  fi

  $ORACLE_HOME/bin/dbca -silent -createdatabase -templatename General_Purpose.dbc -gdbname "${ORACLE_SID}" -sid "${ORACLE_SID}" -syspassword "${ORACLE_DBA_PASSWORD}" -systempassword "${ORACLE_DBA_PASSWORD}" -dbsnmppassword "${ORACLE_DBA_PASSWORD}"
}

function startDatabase() {
  ${ORACLE_HOME}/bin/sqlplus / as sysdba << EOF
  startup;
  exit;
EOF
}

function createUser() {
  echo "create user ${DATABASE_USER} identified by ${DATABASE_PASSWORD}; exit;" | ${ORACLE_HOME}/bin/sqlplus / as sysdba
  echo "GRANT ALL PRIVILEGES on ${DATABASE_USER} to ${DATABASE}; exit;" | ${ORACLE_HOME}/bin/sqlplus / as sysdba
}

checkEnv

checkOrCreateDatabase
startDatabase
createUser

echo "[INFO] Starting oracle listener"
$ORACLE_HOME/bin/netca /silent /responseFile $ORACLE_HOME/network/install/netca_typ.rsp

tail -F /dev/null
