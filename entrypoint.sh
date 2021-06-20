#!/bin/bash

set -e

echo ""
echo "##########################################"
echo "#           OJ_DATABASE_DUMPER           #"
echo "##########################################"
echo ""

# default command
COMMAND="dump"
# default output/input file
FILEPATH=/dumps/output.sql

while getopts h:-: OPT; do
  # support long options: https://stackoverflow.com/a/28466267/519360
  if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi
  case "$OPT" in
    h | help )   COMMAND="" ;;
    cmd )        COMMAND="$OPTARG" ;;
    host )       DATABASE_HOST="$OPTARG" ;;
    port )       DATABASE_HOST="$OPTARG" ;;
    user )       DATABASE_USER="$OPTARG" ;;
    pwd )        DATABASE_PWD="$OPTARG" ;;
    db )         DATABASE_NAME="$OPTARG" ;;
    additional ) ADDITIONALS="$OPTARG" ;;
    file )       FILEPATH="$OPTARG" ;;
    ??* )        echo "ERROR: Illegal option --$OPT" >&2; exit 2; ;;  # bad long option
    ? )          exit 2 ;;  # bad short option (error reported via getopts)
  esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list

if [[ "$COMMAND" == "" ]]
then
  echo "######### HELP #########"
  echo "--- CREDENTIALS ---"
  echo "You may set this environment variables:"
  echo " - DATABASE_HOST"
  echo " - DATABASE_PORT"
  echo " - DATABASE_USER"
  echo " - DATABASE_PWD"
  echo " - DATABASE_NAME"
  echo "or you can pass these params:"
  echo " --host=<value> "
  echo " --port=<value> "
  echo " --user=<value> "
  echo " --pwd=<value> "
  echo " --db=<value> "
  echo " --file=<value>  output file (defaults to /dump/output.sql)"
  echo "----------------------------------"
  echo "--- ALTERNATIVE ---"
  echo "Pass --cmd=<value> to run different commands (defaults to 'dump' | allowed values 'dump', 'restore', 'ls' ) "
  echo "Pass --additional=<some additional parameter> that will be appended to end of command line"
  echo ""
  exit 0
fi

echo "[i] given parameter:"
echo "   COMMAND:       ${COMMAND}"
echo "   DATABASE_HOST: ${DATABASE_HOST}"
echo "   DATABASE_PORT: ${DATABASE_PORT}"
echo "   DATABASE_USER: ${DATABASE_USER}"
echo "   DATABASE_PWD:  **********"
echo "   DATABASE_NAME: ${DATABASE_NAME}"
echo "   ADDITIONALS:   ${ADDITIONALS}"
echo ""


if [ "$COMMAND" == "dump" ];
then
  echo "[i] going to dump database"

  # set defaults
  if [ "$DATABASE_NAME" == "" ]
  then
    DATABASE_NAME="--all-databases --ignore-database=information_schema --ignore-database=mysql --ignore-database=performance_schema"
  fi
  if [ "$ADDITIONALS" == "" ]
  then
    ADDITIONALS="--comments --dump-date --single-transaction"
  fi

  mysqldump \
    --host=${DATABASE_HOST} \
    --port=${DATABASE_PORT} \
    --user=${DATABASE_USER} \
    --password=${DATABASE_PWD} \
    --result-file=${FILEPATH} \
    ${ADDITIONALS} \
    ${DATABASE_NAME}

    echo "[i] finished - find result in ${FILEPATH}"
    echo ""

elif [ "$COMMAND" == "restore" ];
then
  echo "[i] going to run mysql query"
  if [ "$DATABASE_NAME" != "" ]
  then
    DATABASE="--database=${DATABASE_NAME}"
  fi
  mysql \
    --host=${DATABASE_HOST} \
    --port=${DATABASE_PORT} \
    --user=${DATABASE_USER} \
    --password=${DATABASE_PWD} \
    ${DATABASE} \
    < ${FILEPATH}

    echo "[i] finished"
    echo ""
else
  ${COMMAND} ${ADDITIONALS}
fi
