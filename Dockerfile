FROM oraclelinux:7.2
MAINTAINER eXo Platform <docker@exoplatform.com>

COPY installer/linuxx64_12201_database.zip /installer/
COPY db_install.rsp /u01/app/oracle/

ENV ORACLE_BASE=/u01/app/oracle
ENV ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/dbhome_1

RUN yum -y install oracle-database-server-12cR2-preinstall perl unzip && \
         mkdir -p /u01/app/oracle && chown oracle:oinstall /u01/app/oracle && \ 
         chown -R oracle:oinstall ${ORACLE_BASE}/db_install.rsp /installer 
 

COPY oraInst.loc /etc/

WORKDIR /installer 

USER oracle

RUN unzip linuxx64_12201_database.zip && \
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

EXPOSE 1521

ENV ORACLE_SGA_TARGET=512m
ENV ORACLE_PGA_TARGET=512m
