if [ $# -ne 1 ]
then
	echo "Usage: bash contacts.sh PDB_DIR"
	exit
fi


source ~/.get_contacts

for file in $1/*.pdb
do
    output_name=`echo $file | rev | cut -d  '.' -f 2- | rev`_contacts
    log_name=`echo $file | rev | cut -d  '.' -f 2- | rev`_contacts.out
    echo $output_name
    get_static_contacts.py --structure $file --output $output_name --itypes all

done
