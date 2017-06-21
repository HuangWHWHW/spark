COMPILER_HOME="$(dirname "$0")"
COMPILER_HOME=`cd "${COMPILER_HOME}"; pwd`
PROJECT_HOME="${COMPILER_HOME}/../"
DEPENDENCY_TREE_FILE="$COMPILER_HOME/dependency_tree"
echo "compiler home : $COMPILER_HOME"
echo "project home : $PROJECT_HOME"

cd $PROJECT_HOME
echo "Getting dependency tree ..."
mvn dependency:tree > $DEPENDENCY_TREE_FILE
# todo : stop when failed.
echo "Finish getting dependency tree!"

MODULE_NAME=`grep '\.\.\.\.\. SUCCESS' $DEPENDENCY_TREE_FILE | awk -F ']' '{print $2}' | sed "s/\.\./:/g" | cut -d ':' -f 1 | sed "s/ /_/g"`

for module in ${MODULE_NAME}; do
	module=`echo $module | sed "s/_/ /g" | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'`
	module="<name>${module}</name>"
	grep "${module}" ${PROJECT_HOME}/* -R | grep -v '\-pom.xml'
done
