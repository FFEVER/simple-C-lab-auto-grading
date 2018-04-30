#!/bin/sh


check_parameter(){
	usage="Usage: 
	./autocheck.sh --help
	./autocheck.sh Lab<lab_number><lab_question> <result>
Example: 
	./autocheck.sh Lab11 20"

	# check if number of argument is exceed 2
	argv=$3
	if [[ "$argv" -ne 1 ]] && [[ "$argv" -ne 2 ]]; then
		echo "$usage"
		echo "Error: Illegal number of parameters (expected 2)"
		return 3
	fi

	# check if $1 if "-help"
	if [[ "$1" = "--help" ]] || [[ "$1" = "-h" ]]; then
		echo "$usage"
		echo
		echo "autocheck -- program that automatically check the score of the student's lab
* the student's codes must store in the manner of Labs/Lab<lab_number>/<student_id>/Lab<lab_number><lab_question>.c
examples:
	Labs/Lab1/5909001/Lab11.c
	Labs/Lab2/5909001/Lab21.c
	Labs/Lab2/5909001/Lab22.c
* the result of the lab will store in the file name resultLab<lab_number><lab_question>.txt at the same location of this program
examples:
	resultLab11.txt
	resultLab21.txt
	resultLab22.txt"
		return 2
	fi

	# check if $1 or $2 is empty
	if [[ "$1" = "" ]] || [[ "$2" = "" ]]; then
		echo "$usage"
		echo "Error: You are missing parameters (expected 2)"
		return 1
	fi
}

remove_file(){
	# check if file exist
	if [[ -f $1 ]]; then
		rm $1
	fi
}

check_score(){
	# function for checking program
	score=1

	# 2>&1 means redirect from stderr to stdout , & indicates that what follows is a file descriptor not a file name.
	# grep -v means select lines those are not matching any of the patterns
	if gcc "$lab.c" -o "$lab" 2>&1 | grep -v ""; then

			echo "Compile Success!"
			score=$((score+1))
			result=$(./$lab)
		if [[ "$result" = $output ]]; then
			echo "Correct"
			score=$((score+1))
		else
			echo "Wrong"
		fi
		# clean up
		remove_file $lab
	else
		echo "Compile Failed!"
	fi
	return $score
}

##=========================================================
## main program goes here.
##=========================================================

# check if parameters is correct
check_parameter $1 $2 $#
return_val=$?
if [ $return_val != 0 ]; then
	# if not then exit
	exit 1
fi

# initialize variables
lab=$1
output=$2
labnum="${lab:3:1}"
question="${lab:4:1}"
labdir="Lab$labnum"
homedir="$(pwd)"

# remove the file
remove_file "result${lab}.txt"

cd Labs

# check if labnumber is present
printf "Checking $labdir... "
if [[ -d $labdir ]]; then
		cd $labdir
		printf "Directory Exist!\n"

		student_count=0
		pass=0
		wrong=0
		fail=0
		unsub=0

		# loop from all directories
		for student_id in $(ls -d */);
			do
				student_count=$((student_count+1))
				echo "=============="
				echo "${student_id%%/}"
				cd ${student_id%%/}

				if [[ -f "$lab.c" ]]; then
						check_score
						# check_score return 1(fail),2(wrong),3(pass)
						score=$?

						# sum up
						echo "score = ${score}"
						if [[ $score = 1 ]]; then
							fail=$((fail+1))
						elif [[ $score = 2 ]]; then
							wrong=$((wrong+1))
						elif [[ $score = 3 ]]; then
							pass=$((pass+1))
						fi
						
						# write a result file
						studir="$(pwd)"
						cd $homedir
						echo "${student_id%%/};$score;" >> result$lab.txt
						cd $studir/..

				else
					echo "Unsubmitted Work"
					unsub=$((unsub+1))
					cd ..
				fi
			done
			# summary
		echo "=============="
		echo "Total students: $student_count"
		echo "Correct: $pass, Wrong: $wrong, Compile Fail: $fail, Unsubmit: $unsub"
	else
		printf "No such Directory\n"
		cd ..
	fi


echo "Done"


