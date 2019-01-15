#!/bin/bash

execute_spring_jar(){

    className=$1;
    logbackFile=$2;

    EXECUTABLE_JAR=$(ls ${PROJECT_HOME}/lib/*.jar);

    echo $EXECUTABLE_JAR

    JAVA_OPTS="${JAVA_PRE_OPTS} -DAJSC_HOME=$PROJECT_HOME";
    JAVA_OPTS="$JAVA_OPTS -DBUNDLECONFIG_DIR=resources";
    JAVA_OPTS="$JAVA_OPTS -Daai.home=$PROJECT_HOME ";
    JAVA_OPTS="$JAVA_OPTS -Dhttps.protocols=TLSv1.1,TLSv1.2";
    JAVA_OPTS="$JAVA_OPTS -Dloader.main=${className}";
    JAVA_OPTS="$JAVA_OPTS -Dloader.path=${PROJECT_HOME}/resources";
    JAVA_OPTS="$JAVA_OPTS -Dlogback.configurationFile=${logbackFile}";

    export SOURCE_NAME=$(grep '^schema.source.name=' ${PROJECT_HOME}/resources/application.properties | cut -d"=" -f2-);
    # Needed for the schema ingest library beans
    eval $(grep '^schema\.' ${PROJECT_HOME}/resources/application.properties | \
     sed 's/^\(.*\)$/JAVA_OPTS="$JAVA_OPTS -D\1"/g' | \
     sed 's/${server.local.startpath}/${PROJECT_HOME}\/resources/g'| \
     sed 's/${schema.source.name}/'${SOURCE_NAME}'/g'\
    )

    JAVA_OPTS="${JAVA_OPTS} ${JAVA_POST_OPTS}";

    ${JAVA_HOME}/bin/java ${JVM_OPTS} ${JAVA_OPTS} -jar ${EXECUTABLE_JAR} 
}

execute_spring_jar org.onap.aai.schema.GenTester ${PROJECT_HOME}/resources/logback.xml
