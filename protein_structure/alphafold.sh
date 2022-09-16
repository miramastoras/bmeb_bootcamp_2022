cd /app/alphafold

/app/run_alphafold.sh \
 --fasta_paths=${FASTA} \
 --uniref90_database_path=${DB}/uniref90/uniref90.fasta \
 --mgnify_database_path=${DB}/mgnify/mgy_clusters_2018_12.fa \
 --pdb70_database_path=${DB}/pdb70/pdb70 \
 --data_dir=${DB} \
 --template_mmcif_dir=${DB}/pdb_mmcif/mmcif_files \
 --obsolete_pdbs_path=${DB}/pdb_mmcif/obsolete.dat \
 --uniclust30_database_path=${DB}/uniclust30/uniclust30_2018_08/uniclust30_2018_08 \
 --bfd_database_path=${DB}/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
 --output_dir=${OUT_PATH} \
 --benchmark=False \
 --max_template_date=2022-05-01 \
 --use_gpu_relax=True \
 --logtostderr
