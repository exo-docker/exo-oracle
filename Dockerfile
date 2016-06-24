FROM oraclelinux:7.2
MAINTAINER eXo Platform <docker@exoplatform.com>

COPY installer/linuxamd64_12102_database_1of2.zip /installer/linuxamd64_12102_database_2of2.zip /installer/
COPY db_install.rsp /u01/app/oracle/

ENV ORACLE_BASE=/u01/app/oracle
ENV ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1

RUN yum -y install oracle-rdbms-server-12cR1-preinstall perl unzip && \
         mkdir -p /u01/app/oracle && chown oracle:oinstall /u01/app/oracle && \
         chown -R oracle:oinstall ${ORACLE_BASE}/db_install.rsp /installer 
 

COPY oraInst.loc /etc/

WORKDIR /installer

USER oracle

RUN unzip linuxamd64_12102_database_1of2.zip && unzip linuxamd64_12102_database_2of2.zip && \ 
    /installer/database/runInstaller -ignoresysprereqs -ignoreprereq -waitforcompletion -force -silent ORACLE_HOME=${ORACLE_HOME} ORACLE_HOME_NAME=orcl -responseFile ${ORACLE_BASE}/db_install.rsp  DECLINE_SECURITY_UPDATES=true ORACLE_BASE=${ORACLE_BASE} && \
    rm -rf /installer/* && \
    echo "# fix $ORACLE_HOME/bin/oracle command empty file" && \
    if [ ! -s ${ORACLE_HOME}/bin/oracl ]; then make -f ${ORACLE_HOME}/rdbms/lib/ins_rdbms.mk javavm_setup_default_jdk; ${ORACLE_HOME}/bin/relink as_installed; fi

USER root

RUN $ORACLE_HOME/root.sh

COPY database.dbc ${ORACLE_HOME}
COPY entrypoint.sh /entrypoint.sh

RUN chown oracle:dba /entrypoint.sh && chmod u+x /entrypoint.sh

USER oracle

WORKDIR ${ORACLE_HOME}
ENTRYPOINT ["/entrypoint.sh"]

VOLUME [${ORACLE_BASE}/data]

EXPOSE 1521
