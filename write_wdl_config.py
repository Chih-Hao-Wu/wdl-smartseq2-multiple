# write_wdl_config.py

import sys
import os
import json

dir_fastq_paired_end, file_config, collection_name = sys.argv[1:]   

dir_fastq_paired_end = os.path.join(dir_fastq_paired_end, '')

samples = []
fq1 = []
fq2 = []

for i, fastq in enumerate(sorted(os.listdir(dir_fastq_paired_end))):
    label, suffix = fastq.split('_R')
    file_full_path = dir_fastq_paired_end+fastq
    
    if suffix.startswith('2'):
        fq2.append(file_full_path)
    else:
        fq1.append(file_full_path)
        
    if label in samples: continue
    samples.append(label)
    
# assert is type JSON

with open(file_config, "r") as json_file:
    data = json.load(json_file)

print(len(fq1), len(fq2))

data['MultiSampleSmartSeq2.labels'] = samples
data['MultiSampleSmartSeq2.fastqPairedFiles']['left'] = fq1
data['MultiSampleSmartSeq2.fastqPairedFiles']['right'] = fq2
data["MultiSampleSmartSeq2.collectionName"] = collection_name
data["MultiSampleSmartSeq2.workflowOutputDir"] = f"/data/CDSLSahinalp/chihhao/single-cell/Day-2024/run/{collection_name}/workflow-outputs/"

with open(file_config, "w", encoding='utf8') as json_file:
    json.dump(data, json_file, ensure_ascii=False, indent=4)
