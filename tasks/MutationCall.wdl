version 1.0

task HaplotypeCallerGvcf {
    input {
        String workflowOutputDir
        String bamFileIn
        String dbSNPFile
        String label
        String gvcfFileOut = label+".g.vcf"

        # runtime arguments
        Int alloc_cpu = 1
        Int alloc_mem_gb = 32
        Int runtime_minutes = 720
    }

    command <<<
        set -e

        module load GATK/4.5.0.0

        referenceGenomeString="/data/CDSLSahinalp/chihhao/reference/grcm39/release-m35/GRCm39.primary_assembly.genome.fa"

        gatk --java-options "-Xmx~{alloc_mem_gb}g" HaplotypeCaller \
            -R $referenceGenomeString \
            -I ~{bamFileIn} \
            -O "~{workflowOutputDir}~{gvcfFileOut}" \
            --dont-use-soft-clipped-bases false \
            --standard-min-confidence-threshold-for-calling 20 \
            --dbsnp ~{dbSNPFile} \
            -ERC GVCF
    >>>

    runtime {
        memory: "${alloc_mem_gb} G"
        cpu: alloc_cpu
        runtime_minutes: runtime_minutes
    }

    output {
        File outputGvcf = "~{workflowOutputDir}~{gvcfFileOut}"
        String outputGvcfString = "~{workflowOutputDir}~{gvcfFileOut}"
    }
}

task GenomicsDBImport {
    input {
        String workflowOutputDir
        String collectionName
        Array[String] gvcfFiles

        # runtime arguments
        Int alloc_cpu = 1
        Int alloc_mem_gb = 64
    }

    command <<<
        set -e

        declare -a gvcfFilesArr=(~{sep=' ' gvcfFiles})

        gvcfString=""
        for (( i=0; i<${#gvcfFilesArr[@]}; ++i )); do 
            gvcfString+="-V ${gvcfFilesArr[i]} "
        done

        module load GATK/4.5.0.0 

        gatk --java-options "-Xmx~{alloc_mem_gb-5}g" GenomicsDBImport \
            $gvcfString \
            --genomicsdb-workspace-path "~{workflowOutputDir}db_~{collectionName}" \
            --tmp-dir ~{workflowOutputDir} \
            -L /data/CDSLSahinalp/chihhao/single-cell/Day-2024/interval.list
    >>>

    runtime {
        memory: "${alloc_mem_gb} G"
        cpu: alloc_cpu
    }
    
    output {
        Array[File] directoryContents = glob("~{workflowOutputDir}db_~{collectionName}/*")
        String passToGenotypeGvcfs = "complete"
    }
}

task GenotypeGvcfs {
    input {
        String passToGenotypeGvcfs
        String workflowOutputDir
        String collectionName
        String mergeGvcfDirName = "~{workflowOutputDir}db_~{collectionName}"
        
        # runtime arguments
        Int alloc_cpu = 1
        Int alloc_mem_gb = 64
    }
    
    command <<<
        set -e

        module load GATK/4.5.0.0

        referenceGenomeString="/data/CDSLSahinalp/chihhao/reference/grcm39/release-m35/GRCm39.primary_assembly.genome.fa"

        gatk --java-options "-Xmx~{alloc_mem_gb}g" GenotypeGVCFs \
            -R $referenceGenomeString \
            -V gendb://~{mergeGvcfDirName} \
            -O "~{workflowOutputDir}~{collectionName}.jointcall.vcf.gz"
    >>>

    runtime {
        memory: "${alloc_mem_gb} G"
        cpu: alloc_cpu
    }

    output {
        File outputJointGvcf = "~{workflowOutputDir}~{collectionName}.jointcall.vcf.gz"
    }
}
