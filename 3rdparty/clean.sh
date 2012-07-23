# Clean all folders

/bin/ls -l | grep ^d > clean.2.sh
cat clean.2.sh | sed 's/d[^ ]* * [^ ]* * [^ ]* * [^ ]* * [^ ]* * [^ ]* * [^ ]* * [^ ]* *//' > clean.3.sh
cat clean.3.sh | sed 's/^/cd /' | sed 's/$/; make clean; cd ../' > clean.2.sh
sh clean.2.sh
rm clean.2.sh
rm clean.3.sh
