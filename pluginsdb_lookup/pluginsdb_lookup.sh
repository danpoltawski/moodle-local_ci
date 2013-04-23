#!/bin/bash

set -e

MOODLEDIR=~/git/integration
WORKSPACE=/tmp
currentexecution=${WORKSPACE}/current-components.txt
lastsuccess=${WORKSPACE}/lastsuccess-components.txt

# Prevent errors on first execution.
[ -f $lastsuccess ] || touch $lastsuccess
# Remove stale current execution file.
[ -f $currentexecution ] && rm $currentexecution

WHITELIST="(mod_book|block_calendar_month)"

# Double sed call ugly, but handling double and single quotes on one regexp + escaping drove me to insanity.
find $MOODLEDIR -name version.php -exec grep component \{} \; | sed "s/\"/'/" | sed "s/.*'\([^']*\)'.*/\1/" | grep -vE "$WHITELIST" | sort > $currentexecution

exitstatus=0
problemplugins=""
for component in $(comm -23 $currentexecution $lastsuccess)
do
    echo -n $component
    pluginstatus=$(curl -w %{http_code} -s --output /dev/null https://moodle.org/plugins/view.php?plugin=${component})
    if [ $pluginstatus != 404 ];
    then
        echo " - FAILED - plugin exists in moodle.org/plugins"
        exitstatus=1
        problemplugins="$problemplugins $component"
    else
        echo " - OK"
    fi
done

echo "Plugins check completed."
if [ $exitstatus ]; then
    mv $currentexecution $lastsuccess
else
    echo "Problem plugins: $problemplugins"
fi

exit $exitstatus
