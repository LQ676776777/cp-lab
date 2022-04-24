 #!/bin/bash
 
 cd src
 make

 read -p '' testcase	
 ./plc $testcase.pas < ../input/$testcase.in.txt
