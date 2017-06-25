COMPILER_HOME="$(dirname "$0")"
COMPILER_HOME=`cd "${COMPILER_HOME}"; pwd`
PROJECT_HOME="${COMPILER_HOME}/../"
DEPENDENCY_TREE_FILE="$COMPILER_HOME/dependency_tree"
RESULT_FILE="$COMPILER_HOME/result_file"
echo "compiler home : $COMPILER_HOME"
echo "project home : $PROJECT_HOME"

echo '' > ${COMPILER_HOME}/total_info
echo '' > ${RESULT_FILE}

cd $PROJECT_HOME
echo "Getting dependency tree ..."
mvn dependency:tree > $DEPENDENCY_TREE_FILE
# todo : stop when failed.
echo "Finish getting dependency tree!"

MODULE_NAME=`grep '\.\.\.\.\. SUCCESS' $DEPENDENCY_TREE_FILE | awk -F ']' '{print $2}' | sed "s/\.\./:/g" | cut -d ':' -f 1 | sed "s/ /_/g"`

for module in ${MODULE_NAME}; do
	module_name=`echo $module | sed "s/_/ /g" | sed 's/^[[:space:]]*//g' | sed 's/[[:space:]]*$//g'`
	echo "processing ${module_name}"
	module="<name>${module_name}</name>"
	_info=`grep "${module}" ${PROJECT_HOME}/* -R | grep -v '\-pom.xml'`
	pom_file=`echo ${_info} | cut -d ':' -f 1`
	jar_name=`cat ${pom_file} | grep '<artifactId>' | head -n 2 | tail -n 1 | cut -d '>' -f 2 | cut -d '<' -f 1`
	count=`cat $DEPENDENCY_TREE_FILE | grep "${jar_name}" -c`
	echo "${module_name}:${pom_file}:${jar_name}:${count}" >> ${COMPILER_HOME}/total_info
	if [ ${count} -eq 2 ]; then
		echo "${pom_file}" | sed 's#'${PROJECT_HOME}/'##g' | sed 's/pom\.xml//g' >> ${RESULT_FILE}
	fi
done
