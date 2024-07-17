#!/bin/bash

module load cromwell
java -Dconfig.file=../../CROMWELL_CONFIG_MDFY -jar $CROMWELL_JAR run ../../MultiSampleSmartSeq2.wdl --inputs mouse_m107_multiple.json
