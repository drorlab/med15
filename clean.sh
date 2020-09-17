
NAMES=(Ace2_53 Aro80_888 Cha4_622 Crz1_252 Gal4 Gln3_63 Leu3_857 Oaf1_1032 Oaf3_846 Pdr1AD Pdr1ADrep Pip2 Ppr1 Pul4_139 Put3_926 Rdr1_525 Rds1_813 Rsf2_586 Rsf2_688 Sef1_1132 Stb4_932 Sum1_1030 Tda9_456 Tec1_227 Tog1_772 Urc2_739 War1_930 YKL222C_669 YLR278C_1327 Yrm1_758)
for NAME in "${NAMES[@]}"
do
    echo $NAME
    ROOT_DIR=/oak/stanford/groups/rondror/projects/med15/ABD1-fixedlen/$NAME
#    rm -rf $ROOT_DIR/cluster
#    rm -rf $ROOT_DIR/analysis
#    rm -rf $ROOT_DIR/rmsd
#    rm -rf $ROOT_DIR/selected
#    rm -rf $ROOT_DIR/prepack
#    rm -rf $ROOT_DIR/fragments
#    rm -rf $ROOT_DIR/docking
#    echo "" >> $ROOT_DIR/start_files/*.fasta
done
